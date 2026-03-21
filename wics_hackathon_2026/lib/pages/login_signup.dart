import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wics_hackathon_2026/pages/hobby_selector.dart';
import 'package:wics_hackathon_2026/services/auth.dart';
import 'introduction_screens/onboarding_flow.dart';
import '../theme/app_theme.dart';
import '../theme/app_text.dart';
import '../widgets/shared_widgets.dart';

class LoginPage extends StatefulWidget {
  final bool initialIsLogin;
  const LoginPage({super.key, this.initialIsLogin = true});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late bool isLogin;
  String? errorMessage;
  bool _obscurePassword = true;
  bool _obscureRePassword = true;

  final _controllerEmail = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLogin = widget.initialIsLogin;
  }
  final _controllerPassword = TextEditingController();
  final _controllerRePassword = TextEditingController();

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    _controllerRePassword.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => errorMessage = null);
    try {
      await Auth().signInWithEmailPassword(
        email: _controllerEmail.text.trim(),
        password: _controllerPassword.text.trim(),
      );
      _controllerEmail.clear();
      _controllerPassword.clear();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HobbyPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    }
  }

  Future<void> _signUp() async {
    setState(() => errorMessage = null);
    final email = _controllerEmail.text.trim();
    final password = _controllerPassword.text.trim();
    final repassword = _controllerRePassword.text.trim();

    if (password != repassword) {
      setState(() => errorMessage = 'Passwords do not match.');
      return;
    }

    try {
      final userCredential = await Auth().createUserWithEmailPassword(
        email: email,
        password: password,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({'role': 'user'});

      _controllerEmail.clear();
      _controllerPassword.clear();
      _controllerRePassword.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created — please log in.'),
          backgroundColor: AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      setState(() => isLogin = true);
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    }
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    bool? obscure,
    VoidCallback? onToggleObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure ?? false,
      style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.body,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: AppColors.bgSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.borderAccent, width: 1.5),
        ),
        suffixIcon: isPassword
            ? GestureDetector(
                onTap: onToggleObscure,
                child: Icon(
                  obscure! ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              FadeSlideIn(
                delay: const Duration(milliseconds: 0),
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const OnboardingFlow()),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 5),
                      Text('Back', style: AppTextStyles.body),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Tag badge
              FadeSlideIn(
                delay: const Duration(milliseconds: 60),
                child: AppBadge(isLogin ? 'Welcome back' : 'Get started'),
              ),

              const SizedBox(height: 10),

              // Heading
              FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.pageTitle,
                    children: [
                      TextSpan(text: isLogin ? 'Log in to\n' : 'Create your\n'),
                      TextSpan(
                        text: isLogin ? 'your account' : 'account',
                        style: AppTextStyles.pageTitle.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.textAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              FadeSlideIn(
                delay: const Duration(milliseconds: 140),
                child: Text(
                  isLogin
                      ? 'Pick up right where you left off.'
                      : 'Start tracking the hobbies you love.',
                  style: AppTextStyles.body,
                ),
              ),

              const SizedBox(height: 36),

              // Email
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: _inputField(
                  label: 'Email address',
                  controller: _controllerEmail,
                ),
              ),

              const SizedBox(height: 10),

              // Password
              FadeSlideIn(
                delay: const Duration(milliseconds: 260),
                child: _inputField(
                  label: 'Password',
                  controller: _controllerPassword,
                  isPassword: true,
                  obscure: _obscurePassword,
                  onToggleObscure: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              // Confirm password (sign-up only)
              if (!isLogin) ...[
                const SizedBox(height: 10),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 320),
                  child: _inputField(
                    label: 'Confirm password',
                    controller: _controllerRePassword,
                    isPassword: true,
                    obscure: _obscureRePassword,
                    onToggleObscure: () =>
                        setState(() => _obscureRePassword = !_obscureRePassword),
                  ),
                ),
              ],

              // Error message
              if (errorMessage != null && errorMessage!.isNotEmpty) ...[
                const SizedBox(height: 12),
                FadeSlideIn(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F1),
                      border: Border.all(color: const Color(0xFFFFCDD2)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 15, color: Color(0xFFD32F2F)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: AppTextStyles.label.copyWith(
                              color: const Color(0xFFD32F2F),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Primary action
              FadeSlideIn(
                delay: const Duration(milliseconds: 360),
                child: PrimaryButton(
                  label: isLogin ? 'Log in →' : 'Create account →',
                  dark: true,
                  onTap: isLogin ? _signIn : _signUp,
                ),
              ),

              const SizedBox(height: 12),

              // Toggle
              FadeSlideIn(
                delay: const Duration(milliseconds: 400),
                child: GhostButton(
                  label: isLogin
                      ? "Don't have an account? Sign up"
                      : 'Already have an account? Log in',
                  onTap: () => setState(() {
                    isLogin = !isLogin;
                    errorMessage = null;
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
