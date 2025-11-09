import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../services/deck_service.dart';
import '../../../services/firestore_service.dart';
import '../../auth/services/auth_service.dart';
import '../../study/models/deck_model.dart';
import '../widgets/community_deck_card.dart';
import 'deck_detail_screen.dart';

class CommunityDecksScreen extends StatefulWidget {
  const CommunityDecksScreen({super.key});

  @override
  State<CommunityDecksScreen> createState() => _CommunityDecksScreenState();
}

class _CommunityDecksScreenState extends State<CommunityDecksScreen> {
  final DeckService _deckService = DeckService();
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  List<DeckModel> _allDecks = [];
  List<DeckModel> _filteredDecks = [];
  List<String> _userSelectedDecks = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';

  final List<String> _categories = [
    'all',
    'biology',
    'chemistry',
    'physics',
    'computers',
    'mathematics',
    'history',
    'geography',
    'language',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _loadDecks();
    _loadUserDecks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDecks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final decks = await _deckService.getPublicDecks(limit: 50);

      setState(() {
        _allDecks = decks;
        _filteredDecks = decks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserDecks() async {
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      final selectedDecks = await _firestoreService.getUserSelectedDecks(
        userId,
      );
      setState(() {
        _userSelectedDecks = selectedDecks;
      });
    }
  }

  void _filterDecks() {
    List<DeckModel> filtered = _allDecks;

    // Filter by category
    if (_selectedCategory != 'all') {
      filtered = filtered
          .where((deck) => deck.category == _selectedCategory)
          .toList();
    }

    // Filter by search query
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((deck) {
        return deck.name.toLowerCase().contains(query) ||
            deck.description.toLowerCase().contains(query) ||
            deck.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    setState(() {
      _filteredDecks = filtered;
    });
  }

  Future<void> _addDeckToCollection(DeckModel deck) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    try {
      await _deckService.copyDeckToUser(userId: userId, deckId: deck.id);

      setState(() {
        _userSelectedDecks.add(deck.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${deck.name} added to your collection!'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'STUDY',
              textColor: AppColors.white,
              onPressed: () {
                // Navigate to study session
              },
            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Search bar
            _buildSearchBar(),

            // Category filter
            _buildCategoryFilter(),

            // Deck list
            Expanded(
              child: _isLoading
                  ? const Center(child: LoadingIndicator())
                  : _filteredDecks.isEmpty
                  ? _buildEmptyState()
                  : _buildDeckList(),
            ),
          ],
        ),
      ),
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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Community Decks', style: AppTextStyles.headingLarge),
                Text(
                  '${_allDecks.length} decks available',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDecks),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => _filterDecks(),
        decoration: InputDecoration(
          hintText: 'Search decks...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterDecks();
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                category == 'all'
                    ? 'All'
                    : category[0].toUpperCase() + category.substring(1),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
                _filterDecks();
              },
              backgroundColor: AppColors.white,
              selectedColor: AppColors.primary.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.gray300,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeckList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredDecks.length,
      itemBuilder: (context, index) {
        final deck = _filteredDecks[index];
        final isInCollection = _userSelectedDecks.contains(deck.id);

        return CommunityDeckCard(
          deck: deck,
          isInCollection: isInCollection,
          onTap: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) => DeckDetailScreen(
                      deck: deck,
                      isInCollection: isInCollection,
                    ),
                  ),
                )
                .then((_) {
                  _loadUserDecks();
                });
          },
          onAddToCollection: () => _addDeckToCollection(deck),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: AppColors.gray400),
            const SizedBox(height: 16),
            Text('No Decks Found', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try a different search term'
                  : 'No public decks available yet',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
