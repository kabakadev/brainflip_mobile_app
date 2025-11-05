import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/validators.dart';
import '../services/auth_service.dart';
import '../widgets/google_sign_in_button.dart';
import '../../home/screens/dashboard_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignUp() async {
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
      final user = await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : null,
      );

      if (user != null && mounted) {
        // Navigate to dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
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

  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null && mounted) {
        // Navigate to dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
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

  void _navigateBack() {
    Navigator.of(context).pop();
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
                const SizedBox(height: 20),

                // Back Button and Header
                _buildHeader(),

                const SizedBox(height: 32),

                // Logo Placeholder
                _buildLogoPlaceholder(),

                const SizedBox(height: 32),

                // Page Title
                Text(
                  'Create Account',
                  style: AppTextStyles.headingLarge,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'Sign up to start learning',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Name Input (Optional)
                CustomTextField(
                  controller: _nameController,
                  label: 'Name (Optional)',
                  hintText: 'Enter your name',
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: Validators.displayName,
                  enabled: !_isLoading,
                ),

                const SizedBox(height: 16),

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
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  validator: Validators.password,
                  enabled: !_isLoading,
                ),

                const SizedBox(height: 16),

                // Confirm Password Input
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  validator: (value) => Validators.confirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  enabled: !_isLoading,
                  onSubmitted: (_) => _handleEmailSignUp(),
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

                // Sign Up Button
                CustomButton(
                  text: 'Sign Up',
                  onPressed: _isLoading ? null : _handleEmailSignUp,
                  isLoading: _isLoading,
                  icon: Icons.person_add,
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

                // Google Sign Up Button
                GoogleSignInButton(
                  onPressed: _isLoading ? null : _handleGoogleSignUp,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 24),

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: _isLoading ? null : _navigateBack,
                      child: Text(
                        'Sign in',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
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
        // Back button
        Container(
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
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _isLoading ? null : _navigateBack,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        // App Icon
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
      ],
    );
  }

  Widget _buildLogoPlaceholder() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray300, width: 2),
        ),
        child: Center(
          child: Text(
            'LOGO',
            style: AppTextStyles.headingMedium.copyWith(
              color: AppColors.gray400,
            ),
          ),
        ),
      ),
    );
  }
}
