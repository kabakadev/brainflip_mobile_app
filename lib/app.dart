import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/widgets/custom_button.dart';
import 'core/widgets/custom_text_field.dart';
import 'core/widgets/loading_indicator.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const WidgetTestScreen(),
    );
  }
}

class WidgetTestScreen extends StatelessWidget {
  const WidgetTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Test')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Custom Text Fields',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const CustomTextField(
              label: 'Email',
              hintText: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icon(Icons.email),
            ),
            const SizedBox(height: 16),
            const CustomTextField(
              label: 'Password',
              hintText: 'Enter your password',
              obscureText: true,
              prefixIcon: Icon(Icons.lock),
            ),
            const SizedBox(height: 32),
            const Text(
              'Custom Buttons',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomButton(text: 'Primary Button', onPressed: () {}),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Secondary Button',
              type: ButtonType.secondary,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Outline Button',
              type: ButtonType.outline,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Loading Button',
              isLoading: true,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Button with Icon',
              icon: Icons.login,
              onPressed: () {},
            ),
            const SizedBox(height: 32),
            const Text(
              'Loading Indicator',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const LoadingIndicator(),
          ],
        ),
      ),
    );
  }
}
