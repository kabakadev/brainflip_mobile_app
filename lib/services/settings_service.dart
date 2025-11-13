// lib/services/settings_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static SharedPreferences? _prefs;

  // --- Keys for storage ---
  static const String _kTimerEnabled = 'timerEnabled';
  static const String _kTimerDuration = 'timerDuration';
  static const String _kDailyGoal = 'dailyGoal';
  static const String _kCardsPerSession = 'cardsPerSession';

  // --- Call this in main.dart ---
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Timer Enabled ---
  static bool isTimerEnabled() {
    // Return the saved value, or 'true' if it's never been set
    return _prefs?.getBool(_kTimerEnabled) ?? true;
  }

  static Future<void> setTimerEnabled(bool isEnabled) async {
    await _prefs?.setBool(_kTimerEnabled, isEnabled);
  }

  // --- Timer Duration ---
  static int getTimerDuration() {
    // Return saved value, or 30 seconds as default
    return _prefs?.getInt(_kTimerDuration) ?? 30;
  }

  static Future<void> setTimerDuration(int seconds) async {
    await _prefs?.setInt(_kTimerDuration, seconds);
  }

  // --- Daily Goal ---
  static int getDailyGoalTarget() {
    // Return saved value, or 20 cards as default
    return _prefs?.getInt(_kDailyGoal) ?? 20;
  }

  static Future<void> setDailyGoalTarget(int cards) async {
    await _prefs?.setInt(_kDailyGoal, cards);
  }

  // --- Cards Per Session ---
  static int getCardsPerSession() {
    // Return saved value, or 5 cards as default
    return _prefs?.getInt(_kCardsPerSession) ?? 5;
  }

  static Future<void> setCardsPerSession(int cards) async {
    await _prefs?.setInt(_kCardsPerSession, cards);
  }
}
