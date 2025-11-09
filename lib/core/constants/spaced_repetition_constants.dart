/// Spaced Repetition Configuration Constants
class SpacedRepetitionConstants {
  // ==================== LEARNING PHASE ====================
  // Short intervals (in minutes) for cards being learned
  static const List<int> learningSteps = [
    1, // 1 minute - if wrong on first attempt
    10, // 10 minutes - if correct once
  ];

  // Number of times a card must be answered correctly to "graduate"
  static const int graduationThreshold = 2;

  // ==================== REVIEW PHASE ====================
  // Starting interval for graduated cards (in days)
  static const int graduatingInterval = 1; // 1 day after graduation

  // Easy interval multiplier (when user finds card very easy)
  static const double easyIntervalMultiplier = 4.0;

  // ==================== EASE FACTORS ====================
  static const double startingEaseFactor = 2.5;
  static const double minimumEaseFactor = 1.3;
  static const double easyBonus = 0.15;
  static const double intervalModifier = 1.0;

  // ==================== RELEARNING ====================
  // When a review card is failed, it goes back to learning
  // with these steps (in minutes)
  static const List<int> relearnSteps = [
    10, // 10 minutes to retry
  ];

  // ==================== SESSION LIMITS ====================
  // Maximum new cards to introduce per session
  static const int maxNewCardsPerSession = 20;

  // Maximum cards total in a single session
  static const int maxCardsPerSession = 5;

  // If there are this many review cards due, limit new cards
  static const int reviewCardThresholdForNewCards = 50;

  // ==================== QUALITY RATINGS ====================
  // Enum-like constants for answer quality
  static const int qualityAgain = 0; // Wrong answer
  static const int qualityHard = 1; // Correct but difficult
  static const int qualityGood = 2; // Correct, normal difficulty
  static const int qualityEasy = 3; // Correct, very easy

  // ==================== TIME-BASED QUALITY ====================
  // Seconds to determine quality based on response time
  static const int perfectResponseTime = 3; // <= 3s = Perfect
  static const int goodResponseTime = 8; // <= 8s = Good
  static const int hardResponseTime = 15; // <= 15s = Hard
  // > 15s = Hard (even if correct)
}
