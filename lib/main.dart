import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'services/firebase_service.dart';
import 'package:brainflip/services/settings_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService.init();

  // Initialize Firebase
  await FirebaseService.initialize();

  runApp(const MyApp());
}
