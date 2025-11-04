// lib/core/constants/app_constants.dart
class AppConstants {
  // App Info
  static const String appName = 'FlashLearn';
  static const String appVersion = '1.0.0';

  // Onboarding
  static const int minDeckSelection = 2;
  static const int maxDeckSelection = 3;
  static const int initialVisibleDecks = 4;

  // Study Session
  static const int defaultTimePerCard = 30; // seconds
  static const int cardsPerSession = 20;

  // Spaced Repetition (SM-2 Algorithm defaults)
  static const double initialEaseFactor = 2.5;
  static const double minEaseFactor = 1.3; // <-- FIXED (double, not int)
  static const int easyBonusDays = 2;

  // Streaks & Gamification
  static const int streakResetHours = 48; // 2 days grace period
  static const int minCardsForStreak =
      5; // Minimum cards to count toward streak

  // Validation
  static const int minPasswordLength = 6;
  static const int maxUsernameLength = 30;

  // Animation Durations (milliseconds)
  static const int cardFlipDuration = 400;
  static const int pageTransitionDuration = 300;
  static const int loadingMinDuration = 500; // Minimum loading screen time

  // Pagination
  static const int decksPerPage = 10;
  static const int cardsPerLoad = 50;

  // Sharing
  static const String deepLinkPrefix = 'https://brainflip.page.link';
  static const String dynamicLinkDomain = 'brainflip.page.link';
}
