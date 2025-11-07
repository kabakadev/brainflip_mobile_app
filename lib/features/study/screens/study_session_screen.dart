import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/utils/validators.dart';
import '../../../services/firestore_service.dart';
import '../models/deck_model.dart';
import '../models/flashcard_model.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/answer_input.dart';
import 'session_complete_screen.dart';
import '../../../services/progress_service.dart';
import '../../auth/services/auth_service.dart';

import '../../../services/user_flashcard_service.dart';
import '../services/spaced_repetition_service.dart';
import '../../../models/user_flashcard.dart';

class StudySessionScreen extends StatefulWidget {
  final DeckModel deck;

  const StudySessionScreen({super.key, required this.deck});

  @override
  State<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends State<StudySessionScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();

  final ProgressService _progressService = ProgressService();
  final AuthService _authService = AuthService();

  final UserFlashcardService _userFlashcardService = UserFlashcardService();
  final SpacedRepetitionService _spacedRepetitionService =
      SpacedRepetitionService();

  Map<String, UserFlashcard> _userFlashcardMap = {};
  List<int> _cardStartTimes = []; // Track time per card

  List<FlashcardModel> _flashcards = [];
  int _currentCardIndex = 0;
  bool _isLoading = true;
  bool _isFlipped = false;
  bool _showAnswer = false;
  String? _userAnswer;
  bool? _isCorrect;

  // Session stats
  int _correctCount = 0;
  int _incorrectCount = 0;
  final DateTime _sessionStartTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  @override
  void dispose() {
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadFlashcards() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Get all flashcards for the deck
      final allFlashcards = await _firestoreService.getFlashcardsByDeck(
        widget.deck.id,
      );

      // Get study queue (due cards + new cards)
      final studyQueue = await _userFlashcardService.getStudyQueue(
        userId: userId,
        deckId: widget.deck.id,
        allFlashcards: allFlashcards,
        maxNewCards: 10,
      );

      // Load user flashcard data for due cards
      final Map<String, UserFlashcard> userCardMap = {};
      for (final userCard in studyQueue.dueUserCards) {
        userCardMap[userCard.flashcardId] = userCard;
      }

      // Sort by spaced repetition priority
      final sortedQueue = _spacedRepetitionService.sortCardsByPriority(
        studyQueue.dueUserCards,
      );

      // Map back to flashcard models in priority order
      final List<FlashcardModel> sortedFlashcards = [];
      for (final userCard in sortedQueue) {
        final flashcard = studyQueue.allCards.firstWhere(
          (f) => f.id == userCard.flashcardId,
        );
        sortedFlashcards.add(flashcard);
      }

      // Add new cards at the end
      sortedFlashcards.addAll(studyQueue.newCards);

      setState(() {
        _flashcards = sortedFlashcards;
        _userFlashcardMap = userCardMap;
        _cardStartTimes = List.filled(sortedFlashcards.length, 0);
        _isLoading = false;
      });

      // Start timer for first card
      if (sortedFlashcards.isNotEmpty) {
        _cardStartTimes[0] = DateTime.now().millisecondsSinceEpoch;
      }

      // Auto-focus answer input
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _answerFocusNode.requestFocus();
        }
      });

      if (kDebugMode) {
        print('📚 Study Queue:');
        print('   Due cards: ${studyQueue.dueUserCards.length}');
        print('   New cards: ${studyQueue.newCards.length}');
        print('   Total: ${sortedFlashcards.length}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load flashcards: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _flipCard() {
    if (_userAnswer == null || _userAnswer!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an answer first'),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final currentCard = _flashcards[_currentCardIndex];
    final isCorrect = Validators.validateFlashcardAnswer(
      _userAnswer!,
      currentCard.correctAnswer,
      currentCard.alternateAnswers,
    );

    setState(() {
      _isFlipped = true;
      _showAnswer = true;
      _isCorrect = isCorrect;

      if (isCorrect) {
        _correctCount++;
      } else {
        _incorrectCount++;
      }
    });
  }

  void _nextCard() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    final currentCard = _flashcards[_currentCardIndex];

    try {
      // Calculate time spent on this card
      final timeSpent = (_cardStartTimes[_currentCardIndex] > 0)
          ? (DateTime.now().millisecondsSinceEpoch -
                    _cardStartTimes[_currentCardIndex]) ~/
                1000
          : 0;

      // Get or create user flashcard
      UserFlashcard userCard =
          _userFlashcardMap[currentCard.id] ??
          await _userFlashcardService.getUserFlashcard(
            userId: userId,
            flashcardId: currentCard.id,
            deckId: widget.deck.id,
          );

      // Convert answer to quality rating
      final quality = _spacedRepetitionService.convertAnswerToQuality(
        isCorrect: _isCorrect ?? false,
        timeSpentSeconds: timeSpent,
      );

      // Calculate next review
      userCard = _spacedRepetitionService.calculateNextReview(
        userCard: userCard,
        quality: quality,
      );

      // Save to Firestore
      await _userFlashcardService.updateUserFlashcard(userCard);

      if (kDebugMode) {
        print('💾 Card review saved:');
        print('   Card: ${currentCard.correctAnswer}');
        print('   Quality: $quality');
        print('   Next review in: ${userCard.interval} days');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving card review: $e');
      }
    }

    // Move to next card
    if (_currentCardIndex < _flashcards.length - 1) {
      setState(() {
        _currentCardIndex++;
        _isFlipped = false;
        _showAnswer = false;
        _userAnswer = null;
        _isCorrect = null;
        _answerController.clear();
      });

      // Start timer for next card
      _cardStartTimes[_currentCardIndex] =
          DateTime.now().millisecondsSinceEpoch;

      // Re-focus input
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _answerFocusNode.requestFocus();
        }
      });
    } else {
      _completeSession();
    }
  }

  void _completeSession() async {
    final duration = DateTime.now().difference(_sessionStartTime);
    final userId = _authService.currentUser?.uid;

    // Save progress to Firestore
    if (userId != null) {
      try {
        await _progressService.saveStudySession(
          userId: userId,
          deckId: widget.deck.id,
          cardsStudied: _flashcards.length,
          correctAnswers: _correctCount,
          incorrectAnswers: _incorrectCount,
          duration: duration,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Error saving progress: $e');
        }
      }
    }

    if (!mounted) return; // Check if the widget is still in the tree

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SessionCompleteScreen(
          deck: widget.deck,
          cardsStudied: _flashcards.length,
          correctCount: _correctCount,
          incorrectCount: _incorrectCount,
          duration: duration,
        ),
      ),
    );
  }

  void _exitSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Study Session?'),
        content: const Text('Your progress will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Exit session
            },
            child: const Text('Exit', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: LoadingIndicator()));
    }

    if (_flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study Session')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.info_outline,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No flashcards available',
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'This deck is empty',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentCard = _flashcards[_currentCardIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exitSession,
        ),
        title: Text(widget.deck.name),
        actions: [
          // Timer placeholder
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '43s', // This is still a placeholder
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Progress bar
            _buildProgressBar(),

            // ===== DEBUG PANEL ADDED =====
            if (kDebugMode && _currentCardIndex < _flashcards.length) ...[
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildDebugInfo(),
              ),
            ],
            // =============================

            // Progress text
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${_currentCardIndex + 1} / ${_flashcards.length} cards',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FlashcardWidget(
                key: ValueKey(currentCard.id),
                flashcard: currentCard,
                isFlipped: _isFlipped,
                showAnswer: _showAnswer,
                userAnswer: _userAnswer,
                isCorrect: _isCorrect,
              ),
            ),
            const SizedBox(height: 24),

            // Answer input
            if (!_showAnswer)
              AnswerInput(
                controller: _answerController,
                focusNode: _answerFocusNode,
                onSubmit: _flipCard,
                enabled: !_showAnswer,
              ),

            const SizedBox(height: 24),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _showAnswer ? _buildNextButton() : _buildFlipButton(),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentCardIndex + 1) / _flashcards.length;

    return Container(
      height: 4,
      color: AppColors.gray200,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(color: AppColors.primary),
      ),
    );
  }

  Widget _buildFlipButton() {
    return CustomButton(
      text: 'Flip Card',
      onPressed: () {
        setState(() {
          _userAnswer = _answerController.text.trim();
        });
        _flipCard();
      },
      icon: Icons.flip,
    );
  }

  Widget _buildNextButton() {
    return CustomButton(
      text: _currentCardIndex < _flashcards.length - 1
          ? 'Next Card'
          : 'Complete Session',
      onPressed: _nextCard,
      icon: _currentCardIndex < _flashcards.length - 1
          ? Icons.arrow_forward
          : Icons.check_circle,
    );
  }

  // ===== NEW DEBUG WIDGET ADDED =====
  Widget _buildDebugInfo() {
    final currentCard = _flashcards[_currentCardIndex];
    final userCard = _userFlashcardMap[currentCard.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🐛 DEBUG INFO',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Card: ${_currentCardIndex + 1}/${_flashcards.length}',
          style: TextStyle(color: Colors.white70, fontSize: 11),
        ),
        if (userCard != null) ...[
          Text(
            'Ease Factor: ${userCard.easeFactor.toStringAsFixed(2)}',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Text(
            'Interval: ${userCard.interval} days',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Text(
            'Repetitions: ${userCard.repetitions}',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Text(
            'Accuracy: ${userCard.accuracy.toStringAsFixed(1)}%',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          if (userCard.nextReview != null)
            Text(
              'Next: ${userCard.nextReview!.toLocal().toString().substring(0, 16)}',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
        ] else
          Text(
            'Status: New Card',
            style: TextStyle(color: Colors.greenAccent, fontSize: 11),
          ),
      ],
    );
  }

  // ==================================
}
