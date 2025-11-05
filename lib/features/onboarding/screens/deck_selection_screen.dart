import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../services/firestore_service.dart';
import '../../../features/auth/services/auth_service.dart';
import '../../study/models/deck_model.dart';
import '../widgets/deck_card.dart';
import '../../home/screens/dashboard_screen.dart';

class DeckSelectionScreen extends StatefulWidget {
  const DeckSelectionScreen({super.key});

  @override
  State<DeckSelectionScreen> createState() => _DeckSelectionScreenState();
}

class _DeckSelectionScreenState extends State<DeckSelectionScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  List<DeckModel> _allDecks = [];
  List<String> _selectedDeckIds = [];
  bool _isLoading = true;
  bool _isSaving = false;
  bool _showAllDecks = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final decks = await _firestoreService.getAllDecks();

      setState(() {
        _allDecks = decks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load decks. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _toggleDeckSelection(String deckId) {
    setState(() {
      if (_selectedDeckIds.contains(deckId)) {
        _selectedDeckIds.remove(deckId);
      } else {
        // Check if max selection reached
        if (_selectedDeckIds.length < AppConstants.maxDeckSelection) {
          _selectedDeckIds.add(deckId);
        } else {
          // Show snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You can only select up to ${AppConstants.maxDeckSelection} decks',
              ),
              backgroundColor: AppColors.warning,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  Future<void> _saveSelection() async {
    // Validate selection
    if (_selectedDeckIds.length < AppConstants.minDeckSelection) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select at least ${AppConstants.minDeckSelection} decks',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userId = _authService.currentUser?.uid;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Save selected decks to user profile
      await _firestoreService.updateUserDecks(userId, _selectedDeckIds);

      if (mounted) {
        // Navigate to dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save selection. Please try again.';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading ? _buildLoadingState() : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingIndicator(),
          SizedBox(height: 16),
          Text('Loading decks...'),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null && _allDecks.isEmpty) {
      return _buildErrorState();
    }

    return Column(
      children: [
        // Header
        _buildHeader(),

        // Deck grid
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Deck grid
                _buildDeckGrid(),

                // Show more button
                if (_allDecks.length > AppConstants.initialVisibleDecks) ...[
                  const SizedBox(height: 16),
                  _buildShowMoreButton(),
                ],

                const SizedBox(height: 24),

                // Error message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Start button
                CustomButton(
                  text: _isSaving
                      ? 'Saving...'
                      : 'Start Studying (${_selectedDeckIds.length}/${AppConstants.maxDeckSelection})',
                  onPressed:
                      _selectedDeckIds.length >= AppConstants.minDeckSelection
                      ? _saveSelection
                      : null,
                  isLoading: _isSaving,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
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
          // App branding
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.layers,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text('FlashLearn', style: AppTextStyles.headingLarge),
              const Spacer(),
              const Icon(
                Icons.local_fire_department,
                color: AppColors.streakOrange,
                size: 28,
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.gray200,
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Title
          Text('Choose Your Study Decks', style: AppTextStyles.headingLarge),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Select ${AppConstants.minDeckSelection}-${AppConstants.maxDeckSelection} decks to get started',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckGrid() {
    final visibleDecks = _showAllDecks
        ? _allDecks
        : _allDecks.take(AppConstants.initialVisibleDecks).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: visibleDecks.length,
      itemBuilder: (context, index) {
        final deck = visibleDecks[index];
        final isSelected = _selectedDeckIds.contains(deck.id);

        return DeckCard(
          deck: deck,
          isSelected: isSelected,
          onTap: () => _toggleDeckSelection(deck.id),
        );
      },
    );
  }

  Widget _buildShowMoreButton() {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _showAllDecks = !_showAllDecks;
        });
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: AppColors.gray300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _showAllDecks
                ? 'Show Less'
                : 'Show ${_allDecks.length - AppConstants.initialVisibleDecks} More Decks',
            style: AppTextStyles.button.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
          Icon(
            _showAllDecks ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 64),
            const SizedBox(height: 16),
            Text('Failed to Load Decks', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An error occurred',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Try Again',
              onPressed: _loadDecks,
              isFullWidth: false,
              width: 150,
            ),
          ],
        ),
      ),
    );
  }
}
