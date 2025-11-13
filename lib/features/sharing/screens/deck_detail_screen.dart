import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../services/deck_service.dart';
import '../../../services/firestore_service.dart';
import '../../auth/services/auth_service.dart';
import '../../study/models/deck_model.dart';
import '../../study/models/flashcard_model.dart';
import '../../study/screens/study_session_screen.dart';

class DeckDetailScreen extends StatefulWidget {
  final DeckModel deck;
  final bool isInCollection;

  const DeckDetailScreen({
    super.key,
    required this.deck,
    required this.isInCollection,
  });

  @override
  State<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  final DeckService _deckService = DeckService();
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  List<FlashcardModel> _flashcards = [];
  bool _isLoading = true;
  bool _isInCollection = false;
  double _userRating = 0;

  @override
  void initState() {
    super.initState();
    _isInCollection = widget.isInCollection;
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final flashcards = await _firestoreService.getFlashcardsByDeck(
        widget.deck.id,
      );

      setState(() {
        _flashcards = flashcards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addToCollection() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    try {
      await _deckService.copyDeckToUser(userId: userId, deckId: widget.deck.id);

      setState(() {
        _isInCollection = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to your collection!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _rateDeck() async {
    if (_userRating == 0) return;

    try {
      await _deckService.rateDeck(deckId: widget.deck.id, rating: _userRating);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanks for your rating!'),
            backgroundColor: AppColors.success,
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showShareDialog() {
    final shareLink = _deckService.generateShareableLink(widget.deck.id);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Share Deck', style: AppTextStyles.headingLarge),

              const SizedBox(height: 24),

              // QR Code
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gray300),
                ),
                child: QrImageView(
                  data: shareLink,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),

              const SizedBox(height: 24),

              // Share link
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        shareLink,
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: shareLink));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Link copied to clipboard!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              CustomButton(
                text: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                type: ButtonType.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Rate this Deck'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How helpful was this deck?',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starValue = index + 1.0;
                    return IconButton(
                      icon: Icon(
                        starValue <= _userRating
                            ? Icons.star
                            : Icons.star_border,
                        color: AppColors.warning,
                        size: 40,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          _userRating = starValue;
                        });
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _userRating > 0 ? _rateDeck : null,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.deck.name,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getCategoryColor(widget.deck.category),
                      _getCategoryColor(widget.deck.category).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(widget.deck.category),
                    size: 80,
                    color: AppColors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _showShareDialog,
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  _buildStatsRow(),

                  const SizedBox(height: 24),

                  // Description
                  Text('Description', style: AppTextStyles.headingMedium),
                  const SizedBox(height: 8),
                  Text(
                    widget.deck.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Creator info
                  _buildCreatorInfo(),

                  const SizedBox(height: 24),

                  // Preview cards
                  Text('Preview Cards', style: AppTextStyles.headingMedium),
                  const SizedBox(height: 12),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildCardPreview(),

                  const SizedBox(height: 24),

                  // Action buttons
                  if (_isInCollection) ...[
                    CustomButton(
                      text: 'Start Studying',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                StudySessionScreen(deck: widget.deck),
                          ),
                        );
                      },
                      icon: Icons.play_arrow,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Rate this Deck',
                      onPressed: _showRatingDialog,
                      type: ButtonType.outline,
                      icon: Icons.star_outline,
                    ),
                  ] else ...[
                    CustomButton(
                      text: 'Add to Collection',
                      onPressed: _addToCollection,
                      icon: Icons.add_circle,
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            Icons.style_outlined,
            '${widget.deck.cardCount}',
            'Cards',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.download_outlined,
            '${widget.deck.downloads}',
            'Downloads',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.star,
            widget.deck.rating > 0
                ? widget.deck.rating.toStringAsFixed(1)
                : 'New',
            'Rating',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.headingSmall),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: Text(
              (widget.deck.creatorName ?? 'A')[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Created by',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  widget.deck.creatorName ?? 'Anonymous',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getCategoryColor(widget.deck.category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.deck.category.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                color: _getCategoryColor(widget.deck.category),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPreview() {
    final previewCards = _flashcards.take(3).toList();

    if (previewCards.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No cards available',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      children: previewCards.map((card) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.image_outlined, color: AppColors.gray400),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.correctAnswer,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (card.hint != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        card.hint!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(card.difficulty).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  card.difficulty.toUpperCase(),
                  style: AppTextStyles.overline.copyWith(
                    color: _getDifficultyColor(card.difficulty),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'biology':
        return const Color(0xFF10B981);
      case 'chemistry':
        return const Color(0xFF8B5CF6);
      case 'physics':
        return const Color(0xFF3B82F6);
      case 'computers':
        return const Color(0xFFF59E0B);
      case 'mathematics':
        return Colors.red;
      case 'history':
        return Colors.brown;
      case 'geography':
        return Colors.teal;
      case 'language':
        return Colors.pink;
      default:
        return AppColors.gray500;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'biology':
        return Icons.science;
      case 'chemistry':
        return Icons.biotech;
      case 'physics':
        return Icons.flash_on;
      case 'computers':
        return Icons.computer;
      case 'mathematics':
        return Icons.functions;
      case 'history':
        return Icons.history_edu;
      case 'geography':
        return Icons.public;
      case 'language':
        return Icons.translate;
      default:
        return Icons.style;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.gray500;
    }
  }
}
