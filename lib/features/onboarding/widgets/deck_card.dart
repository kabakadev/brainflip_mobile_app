import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../features/study/models/deck_model.dart';

class DeckCard extends StatelessWidget {
  final DeckModel deck;
  final bool isSelected;
  final VoidCallback onTap;

  const DeckCard({
    super.key,
    required this.deck,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail/Image
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  // Image placeholder
                  Center(
                    child: Text(
                      'IMG',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.gray400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Checkmark indicator
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: AppColors.white,
                          size: 16,
                        ),
                      ),
                    ),

                  // Category badge
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(deck.category),
                        borderRadius: BorderRadius.circular(4),
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
                  Text(
                    '${deck.cardCount} cards',
                    style: AppTextStyles.bodySmall,
                  ),
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
}
