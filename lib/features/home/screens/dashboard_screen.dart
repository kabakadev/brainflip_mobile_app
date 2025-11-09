import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../services/firestore_service.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../study/models/deck_model.dart';
import '../../study/screens/study_session_screen.dart';
import '../widgets/deck_carousel.dart';
import '../widgets/stats_card.dart';

import '../../../services/progress_service.dart';
import '../../../models/user_stats.dart';
import '../../../models/deck_progress.dart';
import '../../../services/user_flashcard_service.dart';

import '../../profile/screens/profile_screen.dart';

import '../../../services/gamification_service.dart';
import '../../../models/daily_goal.dart';
import '../widgets/daily_goal_widget.dart';

import '../screens/settings_screen.dart';

import '../../../core/widgets/streak_dialog.dart';

// ===== NEW IMPORTS ADDED =====
import '../../sharing/screens/create_deck_screen.dart';
import '../../sharing/screens/community_decks_screen.dart';
import '../../sharing/screens/deck_detail_screen.dart';
import '../../../services/deck_service.dart';
// =============================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  final ProgressService _progressService = ProgressService();
  UserStats _userStats = UserStats();
  Map<String, DeckProgress> _deckProgressMap = {};

  final UserFlashcardService _userFlashcardService = UserFlashcardService();
  Map<String, int> _dueCardsCount = {};

  final GamificationService _gamificationService = GamificationService();
  DailyGoal? _dailyGoal;

  bool _hasShownStreakDialog = false;

  List<DeckModel> _userDecks = [];
  bool _isLoading = true;
  int _selectedBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserDecks();
  }

  Future<void> _loadUserDecks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return;

      // Get user's selected deck IDs
      final selectedDeckIds = await _firestoreService.getUserSelectedDecks(
        userId,
      );

      // Fetch deck details
      final List<DeckModel> decks = [];
      final Map<String, int> dueCards = {};

      for (final deckId in selectedDeckIds) {
        final deck = await _firestoreService.getDeckById(deckId);
        if (deck != null) {
          decks.add(deck);

          // Get due cards count
          final due = await _userFlashcardService.getDueCards(
            userId: userId,
            deckId: deckId,
          );
          dueCards[deckId] = due.length;
        }
      }

      // Load user stats
      final stats = await _progressService.getUserStats(userId);

      // Load deck progress
      final deckProgress = await _progressService.getAllDeckProgress(userId);

      // Load daily goal
      final dailyGoal = await _gamificationService.getTodayGoal(userId);

      setState(() {
        _userDecks = decks;
        _userStats = stats;
        _deckProgressMap = deckProgress;
        _dueCardsCount = dueCards;
        _dailyGoal = dailyGoal;
        _isLoading = false;
      });

      // Show streak dialog for milestones
      if (!_hasShownStreakDialog && stats.currentStreak > 0) {
        _hasShownStreakDialog = true;

        // Show dialog for streak milestones
        if ([3, 7, 14, 30, 50, 100].contains(stats.currentStreak)) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              StreakDialog.show(
                context,
                streakCount: stats.currentStreak,
                message: _gamificationService.getStreakMessage(
                  stats.currentStreak,
                ),
              );
            }
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  void _startStudySession(DeckModel deck) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => StudySessionScreen(deck: deck)),
    );
  }

  int _getTotalDueCards() {
    return _dueCardsCount.values.fold(0, (sum, count) => sum + count);
  }

  void _startQuickReview() {
    // Find deck with most due cards
    String? deckId;
    int maxDue = 0;

    _dueCardsCount.forEach((id, count) {
      if (count > maxDue) {
        maxDue = count;
        deckId = id;
      }
    });

    if (deckId != null) {
      final deck = _userDecks.firstWhere((d) => d.id == deckId);
      _startStudySession(deck);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading ? _buildLoadingState() : _buildContent(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: LoadingIndicator());
  }

  Widget _buildContent() {
    final user = _authService.currentUser;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),

          const SizedBox(height: 24),

          // Daily Goal
          if (_dailyGoal != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: DailyGoalWidget(goal: _dailyGoal!),
            ),

          const SizedBox(height: 24),

          // Your Decks Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your Decks', style: AppTextStyles.headingMedium),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    // TODO: Navigate to all decks
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Deck carousel
          if (_userDecks.isEmpty)
            _buildEmptyDecks()
          else
            DeckCarousel(
              decks: _userDecks,
              deckProgressMap: _deckProgressMap,
              dueCardsCount: _dueCardsCount,
              onDeckTap: _startStudySession,
            ),

          const SizedBox(height: 32),

          // Study Stats Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('Study Stats', style: AppTextStyles.headingMedium),
          ),

          const SizedBox(height: 16),

          // Stats cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: StatsCard(
                    value: '${_userStats.cardsStudiedToday}',
                    label: 'Cards Today',
                    icon: Icons.style_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    value: _userStats.currentStreak > 0
                        ? '${_userStats.currentStreak} 🔥'
                        : '0',
                    label: 'Day Streak',
                    icon: Icons.local_fire_department,
                    color: AppColors.streakOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    value: '${_userStats.overallAccuracy.toInt()}%',
                    label: 'Accuracy',
                    icon: Icons.show_chart,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ===== UPDATED: Shared Decks Section =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Community Decks', style: AppTextStyles.headingMedium),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (context) => const CommunityDecksScreen(),
                          ),
                        )
                        .then((_) => _loadUserDecks());
                  },
                  icon: const Icon(Icons.explore),
                  label: const Text('Explore'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _buildCommunityDecksPreview(),

          // =========================================
          const SizedBox(height: 32),

          // Quick study buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Review due cards button
                if (_getTotalDueCards() > 0)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _startQuickReview(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.notifications_active, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            'Review ${_getTotalDueCards()} Due Cards',
                            style: AppTextStyles.button.copyWith(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // Start study button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _userDecks.isNotEmpty
                        ? () => _startStudySession(_userDecks.first)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          _getTotalDueCards() > 0
                              ? 'Start New Session'
                              : 'Start Quick Study',
                          style: AppTextStyles.button.copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final user = _authService.currentUser;

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
          // ===== UPDATED: Menu button with popup =====
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (value) {
              if (value == 'create_deck') {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => const CreateDeckScreen(),
                      ),
                    )
                    .then((_) => _loadUserDecks());
              } else if (value == 'settings') {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    )
                    .then((_) => _loadUserDecks());
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'create_deck',
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline),
                    SizedBox(width: 8),
                    Text('Create Custom Deck'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),

          // ===========================================
          const Spacer(),

          // App title
          Text('Dashboard', style: AppTextStyles.headingLarge),

          const Spacer(),

          // Profile button
          GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  )
                  .then((_) => _loadUserDecks());
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child: Text(
                user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                style: AppTextStyles.button.copyWith(color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDecks() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray300),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.style_outlined,
              size: 64,
              color: AppColors.gray400,
            ),
            const SizedBox(height: 16),
            Text('No Decks Yet', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Text(
              'Add some decks to get started',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== NEW: Community Decks Preview =====
  Widget _buildCommunityDecksPreview() {
    return SizedBox(
      height: 140,
      child: FutureBuilder<List<DeckModel>>(
        future: DeckService().getPublicDecks(limit: 5),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final decks = snapshot.data!;

          if (decks.isEmpty) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'No community decks yet',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 12),
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
                child: InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (context) => DeckDetailScreen(
                              deck: deck,
                              isInCollection: _userDecks.any(
                                (d) => d.id == deck.id,
                              ),
                            ),
                          ),
                        )
                        .then((_) => _loadUserDecks());
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.gray200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: deck.thumbnailUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    deck.thumbnailUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text(
                                          'IMG',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                color: AppColors.gray400,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    'IMG',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.gray400,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          deck.name,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                deck.creatorName ?? 'Anonymous',
                                style: AppTextStyles.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  // ========================================

  // ===== UPDATED: Bottom Navigation =====
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedBottomNavIndex,
      onTap: (index) {
        if (index == 2) {
          // Explore/Shared tab
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => const CommunityDecksScreen(),
                ),
              )
              .then((_) => _loadUserDecks());
        } else if (index == 3) {
          // Profile tab
          Navigator.of(context)
              .push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              )
              .then((_) {
                _loadUserDecks();
                setState(() {
                  _selectedBottomNavIndex = 0;
                });
              });
        } else {
          setState(() {
            _selectedBottomNavIndex = index;
          });
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.style), label: 'Study'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  // ======================================
}
