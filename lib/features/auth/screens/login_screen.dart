import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/validators.dart';
import '../services/auth_service.dart';
import '../widgets/google_sign_in_button.dart';
import 'signup_screen.dart';
import '../../home/screens/dashboard_screen.dart';
import '../../onboarding/screens/deck_selection_screen.dart';
import 'package:flutter/foundation.dart';
import '../../../core/utils/database_seeder.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignIn() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Find this section in _handleEmailSignIn method:
      if (user != null && mounted) {
        // Check if user has selected decks
        final selectedDecks = await _authService.getUserData(user.uid);

        if (mounted) {
          if (selectedDecks != null && selectedDecks.selectedDecks.isNotEmpty) {
            // User has decks, go to dashboard
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          } else {
            // New user, go to deck selection
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const DeckSelectionScreen(),
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // THIS IS YOUR NEW, UPDATED METHOD
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final user = await _authService.signInWithGoogle();

      // Find this section in _handleEmailSignIn method:
      if (user != null && mounted) {
        // Check if user has selected decks
        final selectedDecks = await _authService.getUserData(user.uid);

        if (mounted) {
          if (selectedDecks != null && selectedDecks.selectedDecks.isNotEmpty) {
            // User has decks, go to dashboard
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          } else {
            // New user, go to deck selection
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const DeckSelectionScreen(),
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToSignUp() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SignUpScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // App Logo and Title
                _buildHeader(),

                const SizedBox(height: 48),

                // Logo Placeholder
                _buildLogoPlaceholder(),

                const SizedBox(height: 48),

                // Email Input
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: Validators.email,
                  enabled: !_isLoading,
                ),

                const SizedBox(height: 16),

                // Password Input
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Enter your password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  validator: Validators.password,
                  enabled: !_isLoading,
                  onSubmitted: (_) => _handleEmailSignIn(),
                ),

                const SizedBox(height: 24),

                // Error Message
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

                // Sign In Button
                CustomButton(
                  text: 'Sign In',
                  onPressed: _isLoading ? null : _handleEmailSignIn,
                  isLoading: _isLoading,
                  icon: Icons.login,
                ),

                const SizedBox(height: 24),

                // Divider with "or"
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 24),

                // Google Sign In Button
                GoogleSignInButton(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 24),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyles.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: _isLoading ? null : _navigateToSignUp,
                      child: Text(
                        'Sign up',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                // ... existing code ...
                const SizedBox(height: 24),

                // TEMPORARY: Seed Database Button (REMOVE AFTER SEEDING)
                if (kDebugMode)
                  TextButton(
                    onPressed: () async {
                      try {
                        await DatabaseSeeder.seedStarterDecks();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Database seeded successfully!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ Seeding failed: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('🌱 Seed Database (Dev Only)'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // App Icon (stacked layers icon)
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.layers, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Text('FlashLearn', style: AppTextStyles.headingLarge),
        const Spacer(),
        // Flame icon (streak indicator - could be interactive later)
        const Icon(
          Icons.local_fire_department,
          color: AppColors.streakOrange,
          size: 28,
        ),
        const SizedBox(width: 8),
        // Profile icon placeholder
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_outline,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoPlaceholder() {
    return Image.asset(
      'assets/images/app_logo.png', // Use the .png file
      width: 100,
      height: 100,
    );
  }
}
