class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Basic email regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // Confirm password validation
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Display name validation
  static String? displayName(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 30) {
      return 'Name must be less than 30 characters';
    }

    return null;
  }

  // Generic required field
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // --- ADD THE NEW METHOD HERE ---

  // Answer validation for flashcards
  static bool validateFlashcardAnswer(
    String userInput,
    String correctAnswer,
    List<String> alternateAnswers,
  ) {
    // Normalize user input
    String normalized = userInput.toLowerCase().trim();

    // Remove extra spaces
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

    // Normalize correct answer
    String normalizedCorrect = correctAnswer.toLowerCase().trim();

    // Check if matches correct answer
    if (normalized == normalizedCorrect) {
      return true;
    }

    // Check against alternate answers
    for (final alternate in alternateAnswers) {
      String normalizedAlternate = alternate.toLowerCase().trim();
      if (normalized == normalizedAlternate) {
        return true;
      }
    }

    return false;
  }
} // <-- This is the final closing brace for the class
