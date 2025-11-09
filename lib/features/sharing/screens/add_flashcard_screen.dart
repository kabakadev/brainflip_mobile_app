import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../services/deck_service.dart';
import '../../home/screens/dashboard_screen.dart';

class AddFlashcardScreen extends StatefulWidget {
  final String deckId;
  final String deckName;

  const AddFlashcardScreen({
    super.key,
    required this.deckId,
    required this.deckName,
  });

  @override
  State<AddFlashcardScreen> createState() => _AddFlashcardScreenState();
}

class _AddFlashcardScreenState extends State<AddFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _answerController = TextEditingController();
  final _hintController = TextEditingController();
  final _alternateController = TextEditingController();
  final DeckService _deckService = DeckService();

  String _difficulty = 'medium';
  bool _isLoading = false;
  int _cardsAdded = 0;

  @override
  void dispose() {
    _answerController.dispose();
    _hintController.dispose();
    _alternateController.dispose();
    super.dispose();
  }

  Future<void> _addFlashcard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse alternate answers
      final alternates = _alternateController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      await _deckService.addFlashcard(
        deckId: widget.deckId,
        correctAnswer: _answerController.text.trim(),
        alternateAnswers: alternates,
        hint: _hintController.text.trim().isNotEmpty
            ? _hintController.text.trim()
            : null,
        difficulty: _difficulty,
      );

      setState(() {
        _cardsAdded++;
        _isLoading = false;
      });

      // Clear form
      _answerController.clear();
      _hintController.clear();
      _alternateController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Card added! Total: $_cardsAdded'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

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

  void _finishDeck() {
    if (_cardsAdded < 5) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add More Cards'),
          content: Text(
            'Your deck only has $_cardsAdded cards. We recommend at least 5 cards for an effective study session.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Add More'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToDashboard();
              },
              child: const Text('Finish Anyway'),
            ),
          ],
        ),
      );
    } else {
      _navigateToDashboard();
    }
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Deck "${widget.deckName}" created with $_cardsAdded cards!',
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.deckName),
        actions: [
          TextButton.icon(
            onPressed: _cardsAdded > 0 ? _finishDeck : null,
            icon: const Icon(Icons.check),
            label: const Text('Finish'),
            style: TextButton.styleFrom(foregroundColor: AppColors.success),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.style, color: AppColors.white, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_cardsAdded Cards Added',
                            style: AppTextStyles.headingMedium.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _cardsAdded < 5
                                ? 'Add at least ${5 - _cardsAdded} more'
                                : 'Great progress! Keep adding.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Image placeholder info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.image_outlined, color: AppColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Image upload coming soon! For now, placeholder images will be used.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Answer (what's on the image)
              CustomTextField(
                controller: _answerController,
                label: 'Answer',
                hintText: 'e.g., Mitochondria',
                prefixIcon: const Icon(Icons.check_circle_outline),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an answer';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),

              const SizedBox(height: 16),

              // Alternate answers (optional)
              CustomTextField(
                controller: _alternateController,
                label: 'Alternate Answers (Optional)',
                hintText: 'e.g., powerhouse of the cell, energy producer',
                prefixIcon: const Icon(Icons.list),
                maxLines: 2,
                enabled: !_isLoading,
              ),

              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Separate multiple answers with commas',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Hint (optional)
              CustomTextField(
                controller: _hintController,
                label: 'Hint (Optional)',
                hintText: 'e.g., Found in cells, produces ATP',
                prefixIcon: const Icon(Icons.lightbulb_outline),
                enabled: !_isLoading,
              ),

              const SizedBox(height: 16),

              // Difficulty
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Difficulty', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDifficultyChip(
                          'easy',
                          'Easy',
                          Icons.sentiment_satisfied,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDifficultyChip(
                          'medium',
                          'Medium',
                          Icons.sentiment_neutral,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDifficultyChip(
                          'hard',
                          'Hard',
                          Icons.sentiment_dissatisfied,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Add card button
              CustomButton(
                text: 'Add Card',
                onPressed: _isLoading ? null : _addFlashcard,
                isLoading: _isLoading,
                icon: Icons.add,
              ),

              const SizedBox(height: 12),

              // Finish button
              if (_cardsAdded > 0)
                CustomButton(
                  text: 'Finish Deck ($_cardsAdded cards)',
                  onPressed: _finishDeck,
                  type: ButtonType.outline,
                  icon: Icons.check_circle,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String value, String label, IconData icon) {
    final isSelected = _difficulty == value;
    Color color;

    switch (value) {
      case 'easy':
        color = AppColors.success;
        break;
      case 'medium':
        color = AppColors.warning;
        break;
      case 'hard':
        color = AppColors.error;
        break;
      default:
        color = AppColors.gray500;
    }

    return GestureDetector(
      onTap: _isLoading
          ? null
          : () {
              setState(() {
                _difficulty = value;
              });
            },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : AppColors.gray400, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
