class AssetPaths {
  // Base paths
  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';
  static const String _animations = 'assets/animations';

  // App Logo & Branding
  static const String appLogo = '$_images/logo.png';
  static const String appLogoWhite = '$_images/logo_white.png';
  static const String splashLogo = '$_images/splash_logo.png';

  // Icons
  static const String googleIcon = '$_icons/google_icon.png';
  static const String fireIcon = '$_icons/fire_icon.png';
  static const String starIcon = '$_icons/star_icon.png';

  // Empty States
  static const String emptyDecks = '$_images/empty_decks.png';
  static const String emptyShared = '$_images/empty_shared.png';
  static const String noInternet = '$_images/no_internet.png';

  // Badges (Trophy icons for achievements)
  static const String badge1 = '$_icons/badge_1.png';
  static const String badge2 = '$_icons/badge_2.png';
  static const String badge3 = '$_icons/badge_3.png';

  // Placeholder (used during development)
  static const String imagePlaceholder = '$_images/placeholder.png';
  static const String deckThumbnailPlaceholder =
      '$_images/deck_placeholder.png';

  // Animations (if using Lottie/Rive)
  static const String confettiAnimation = '$_animations/confetti.json';
  static const String loadingAnimation = '$_animations/loading.json';
}
