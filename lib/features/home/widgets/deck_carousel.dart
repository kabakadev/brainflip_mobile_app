import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../study/models/deck_model.dart';
// ===== IMPORT ADDED =====
import '../../../models/deck_progress.dart';

class DeckCarousel extends StatelessWidget {
  final List<DeckModel> decks;
  // ===== PARAMETER ADDED =====
  final Map<String, DeckProgress> deckProgressMap;
  final Function(DeckModel) onDeckTap;

  // ===== CONSTRUCTOR UPDATED =====
  const DeckCarousel({
    super.key,
    required this.decks,
    this.deckProgressMap = const {},
    required this.onDeckTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: decks.length,
        itemBuilder: (context, index) {
          final deck = decks[index];
          return _buildDeckCard(deck);
        },
      ),
    );
  }

  Widget _buildDeckCard(DeckModel deck) {
    return GestureDetector(
      onTap: () => onDeckTap(deck),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: _getCategoryColor(deck.category),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _getCategoryIcon(deck.category),
                      size: 48,
                      color: AppColors.white.withOpacity(0.5),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        deck.category.toUpperCase(),
                        style: AppTextStyles.overline.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Deck info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deck.name,
                    style: AppTextStyles.headingSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // ===== PROGRESS BAR SECTION UPDATED =====
                  Row(
                    children: [
                      Text(
                        '${deck.cardCount} cards',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.gray200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _getProgressFactor(deck.id),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // ======================================
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'biology':
        return const Color(0xFF10B981); // Green
      case 'chemistry':
        return const Color(0xFF8B5CF6); // Purple
      case 'physics':
        return const Color(0xFF3B82F6); // Blue
      case 'computers':
        return const Color(0xFFF59E0B); // Orange
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
      default:
        return Icons.style;
    }
  }

  // ===== HELPER METHOD ADDED =====
  double _getProgressFactor(String deckId) {
    final progress = deckProgressMap[deckId];
    if (progress == null) return 0.0;
    // Handle division by zero if totalCards is 0
    if (progress.totalCards == 0) return 0.0;

    // Assuming you add a 'cardsCompleted' field to DeckProgress
    // If not, we'll use progressPercentage as instructed
    // If DeckProgress only has 'progressPercentage':
    return (progress.progressPercentage / 100).clamp(0.0, 1.0);

    /* // If DeckProgress has 'cardsCompleted' and 'totalCards':
    return (progress.cardsCompleted / progress.totalCards).clamp(0.0, 1.0);
    */
  }

  // ===============================
}
