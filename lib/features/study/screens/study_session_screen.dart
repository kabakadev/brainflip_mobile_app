import 'package:flutter/material.dart' hide Badge;
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../../services/gamification_service.dart';
import '../../../models/badge.dart';
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
import '../../../services/settings_service.dart';
import '../../../core/constants/spaced_repetition_constants.dart';

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
  List<int> _cardStartTimes = [];

  final GamificationService _gamificationService = GamificationService();

  // Timer fields
  Timer? _cardTimer;
  late int _timeRemaining;
  late int _timeLimit;
  late bool _isTimerEnabled;
  List<int> _cardTimes = [];
  List<Badge> _newBadges = [];

  List<FlashcardModel> _flashcards = [];
  int _currentCardIndex = 0;
  bool _isLoading = true;
  bool _isFlipped = false;
  bool _showAnswer = false;
  String? _userAnswer;
  bool? _isCorrect;
  bool _isPracticeMode = false;

  // Session stats
  int _correctCount = 0;
  int _incorrectCount = 0;
  final DateTime _sessionStartTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    _isTimerEnabled = SettingsService.isTimerEnabled();
    _timeLimit = SettingsService.getTimerDuration();
    _timeRemaining = _timeLimit;

    _loadFlashcards();
  }

  @override
  void dispose() {
    _stopCardTimer();
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  Future<void> _startPracticeMode() async {
    setState(() {
      _isLoading = true;
      _isPracticeMode = true;
    });

    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Get ALL flashcards for the deck (ignore due dates)
      final allFlashcards = await _firestoreService.getFlashcardsByDeck(
        widget.deck.id,
      );

      // Shuffle for variety
      allFlashcards.shuffle();

      // Limit to prevent overwhelm
      final sessionLimit = SettingsService.getCardsPerSession();
      final practiceCards = allFlashcards.take(sessionLimit).toList();

      setState(() {
        _flashcards = practiceCards;
        _userFlashcardMap = {}; // Empty since we're not tracking
        _cardStartTimes = List.filled(practiceCards.length, 0);
        _cardTimes = List.filled(practiceCards.length, 0);
        _isLoading = false;
      });

      // Start timer for first card
      if (practiceCards.isNotEmpty) {
        _cardStartTimes[0] = DateTime.now().millisecondsSinceEpoch;
        _startCardTimer();
      }

      // Auto-focus answer input
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _answerFocusNode.requestFocus();
        }
      });

      if (kDebugMode) {
        print('🏋️ Practice Mode Started:');
        print('   Total cards: ${practiceCards.length}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start practice mode: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
        maxNewCards: SpacedRepetitionConstants.maxNewCardsPerSession,
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

      // Limit total cards per session
      final sessionLimit = SettingsService.getCardsPerSession();
      final finalSessionList = sortedFlashcards.take(sessionLimit).toList();

      setState(() {
        _flashcards = finalSessionList;
        _userFlashcardMap = userCardMap;
        _cardStartTimes = List.filled(finalSessionList.length, 0);
        _cardTimes = List.filled(finalSessionList.length, 0);
        _isLoading = false;
      });

      // Start timer for first card
      if (finalSessionList.isNotEmpty) {
        _cardStartTimes[0] = DateTime.now().millisecondsSinceEpoch;
        _startCardTimer();
      }

      // Auto-focus answer input
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _answerFocusNode.requestFocus();
        }
      });

      if (kDebugMode) {
        print('📚 Study Session Loaded:');
        print('   Due cards: ${studyQueue.dueUserCards.length}');
        print('   New cards: ${studyQueue.newCards.length}');
        print('   Session cards: ${finalSessionList.length}');
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
      if (_timeRemaining > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter an answer first'),
            backgroundColor: AppColors.warning,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    _stopCardTimer();

    final currentCard = _flashcards[_currentCardIndex];
    final isCorrect = Validators.validateFlashcardAnswer(
      _userAnswer ?? '',
      currentCard.correctAnswer,
      currentCard.alternateAnswers,
    );

    // Calculate time taken
    final timeTaken = (_timeLimit - _timeRemaining);
    _cardTimes[_currentCardIndex] = timeTaken;

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

    if (!_isPracticeMode) {
      try {
        // Calculate time spent on this card
        final timeSpent = _cardTimes[_currentCardIndex];

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
          print('   Time: ${timeSpent}s');
          print('   Status: ${userCard.status}');
          if (userCard.isLearning) {
            print('   Learning step: ${userCard.learningStep}');
            print('   Consecutive correct: ${userCard.consecutiveCorrect}');
            if (userCard.nextReview != null) {
              final minutes = userCard.nextReview!
                  .difference(DateTime.now())
                  .inMinutes;
              print('   Next review in: $minutes min');
            }
          } else {
            print('   Next review in: ${userCard.interval} day(s)');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error saving card review: $e');
        }
      }
    } else {
      if (kDebugMode) {
        print('🏋️ Practice Mode - Not saving progress');
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
      _startCardTimer();

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
    _stopCardTimer();

    final duration = DateTime.now().difference(_sessionStartTime);
    final userId = _authService.currentUser?.uid;

    // Save progress to Firestore
    if (userId != null && !_isPracticeMode) {
      try {
        await _progressService.saveStudySession(
          userId: userId,
          deckId: widget.deck.id,
          cardsStudied: _flashcards.length,
          correctAnswers: _correctCount,
          incorrectAnswers: _incorrectCount,
          duration: duration,
        );

        // Update daily goal
        await _gamificationService.updateDailyGoalProgress(
          userId: userId,
          cardsStudied: _flashcards.length,
        );

        // Check for new badges
        final stats = await _progressService.getUserStats(userId);
        final averageTime = _cardTimes.isNotEmpty
            ? _cardTimes.reduce((a, b) => a + b) ~/ _cardTimes.length
            : null;

        _newBadges = await _gamificationService.checkAndUnlockBadges(
          userId: userId,
          stats: stats,
          sessionAverageTime: averageTime,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Error saving progress: $e');
        }
      }
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SessionCompleteScreen(
            deck: widget.deck,
            cardsStudied: _flashcards.length,
            correctCount: _correctCount,
            incorrectCount: _incorrectCount,
            duration: duration,
            newBadges: _newBadges,
            averageTimePerCard: _cardTimes.isNotEmpty
                ? _cardTimes.reduce((a, b) => a + b) ~/ _cardTimes.length
                : 0,
            isPracticeMode: _isPracticeMode,
          ),
        ),
      );
    }
  }

  void _exitSession() {
    _stopCardTimer();
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

  void _startCardTimer() {
    _cardTimer?.cancel();
    _timeRemaining = _timeLimit;

    if (!_isTimerEnabled) return;

    _cardTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          timer.cancel();
          if (!_showAnswer) {
            _handleTimeUp();
          }
        }
      });
    });
  }

  void _handleTimeUp() {
    setState(() {
      _userAnswer = '';
    });
    _flipCard();
  }

  void _stopCardTimer() {
    _cardTimer?.cancel();
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: AppColors.success,
                ),
                const SizedBox(height: 24),
                Text('All caught up!', style: AppTextStyles.headingLarge),
                const SizedBox(height: 8),
                Text(
                  'No cards due right now',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // ===== NEW: Practice Mode Option =====
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Want more practice?',
                        style: AppTextStyles.headingSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Practice mode lets you study all cards without affecting your review schedule',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Start Practice Mode',
                        onPressed: () => _startPracticeMode(),
                        icon: Icons.play_circle_outline,
                      ),
                    ],
                  ),
                ),

                // =====================================
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Back to Home',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icons.home,
                  type: ButtonType.text,
                ),
              ],
            ),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.deck.name),
            if (_isPracticeMode)
              Text(
                'Practice Mode',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getTimerColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 18,
                      color: AppColors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_timeRemaining}s',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
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

            // DEBUG PANEL
            // if (kDebugMode && _currentCardIndex < _flashcards.length) ...[
            //   Container(
            //     margin: const EdgeInsets.all(16),
            //     padding: const EdgeInsets.all(12),
            //     decoration: BoxDecoration(
            //       color: Colors.black.withOpacity(0.8),
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: _buildDebugInfo(),
            //   ),
            // ],

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
            'Status: ${userCard.status}',
            style: TextStyle(
              color: userCard.isLearning
                  ? Colors.orangeAccent
                  : Colors.greenAccent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (userCard.isLearning) ...[
            Text(
              'Learning Step: ${userCard.learningStep + 1}/${SpacedRepetitionConstants.learningSteps.length}',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
            Text(
              'Consecutive Correct: ${userCard.consecutiveCorrect}/${SpacedRepetitionConstants.graduationThreshold}',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ] else ...[
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
          ],
          Text(
            'Accuracy: ${userCard.accuracy.toStringAsFixed(1)}%',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          if (userCard.nextReview != null) ...[
            Text(
              'Next: ${userCard.nextReview!.toLocal().toString().substring(0, 16)}',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
            if (userCard.isLearning) ...[
              Text(
                'Due in: ${userCard.nextReview!.difference(DateTime.now()).inMinutes} min',
                style: TextStyle(color: Colors.yellowAccent, fontSize: 11),
              ),
            ],
          ],
        ] else
          Text(
            'Status: New Card',
            style: TextStyle(color: Colors.greenAccent, fontSize: 11),
          ),
      ],
    );
  }

  Color _getTimerColor() {
    if (_timeRemaining <= 5) return AppColors.error;
    if (_timeRemaining <= 10) return AppColors.warning;
    return AppColors.success;
  }
}
