import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../study/models/deck_model.dart';

class CommunityDeckCard extends StatelessWidget {
  final DeckModel deck;
  final bool isInCollection;
  final VoidCallback onTap;
  final VoidCallback onAddToCollection;

  const CommunityDeckCard({
    super.key,
    required this.deck,
    required this.isInCollection,
    required this.onTap,
    required this.onAddToCollection,
  });

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with category badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getCategoryColor(deck.category).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(deck.category),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      deck.category.toUpperCase(),
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (deck.rating > 0) ...[
                    Icon(Icons.star, size: 16, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      deck.rating.toStringAsFixed(1),
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Deck name
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          deck.name,
                          style: AppTextStyles.headingMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isInCollection)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: AppColors.success,
                            size: 18,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    deck.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Creator and stats
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        deck.creatorName ?? 'Anonymous',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.style_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${deck.cardCount} cards',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.download_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${deck.downloads}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isInCollection ? null : onAddToCollection,
                      icon: Icon(
                        isInCollection ? Icons.check_circle : Icons.add_circle,
                        size: 20,
                      ),
                      label: Text(
                        isInCollection
                            ? 'In Your Collection'
                            : 'Add to Collection',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isInCollection
                            ? AppColors.gray300
                            : AppColors.primary,
                        foregroundColor: isInCollection
                            ? AppColors.textSecondary
                            : AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
