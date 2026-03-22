import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wics_hackathon_2026/pages/hobby_selector.dart';
import 'package:wics_hackathon_2026/services/auth.dart';
import 'introduction_screens/onboarding_flow.dart';
import '../shared/app_theme.dart';
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

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerRePassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLogin = widget.initialIsLogin;
  }

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
      setState(() => errorMessage = e.message ?? 'Login failed.');
    } catch (_) {
      setState(() => errorMessage = 'Something went wrong. Please try again.');
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
          content: const Text(
            'Account created — please log in.',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.card,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      setState(() => isLogin = true);
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message ?? 'Sign up failed.');
    } catch (_) {
      setState(() => errorMessage = 'Something went wrong. Please try again.');
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.subText,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      filled: true,
      fillColor: AppColors.bgSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderAccent, width: 1.5),
      ),
      suffixIcon: isPassword
          ? IconButton(
              onPressed: onToggleObscure,
              splashRadius: 18,
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: AppColors.textTertiary,
              ),
            )
          : null,
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscure : false,
      style: AppTextStyles.body.copyWith(fontSize: 14),
      cursorColor: AppColors.textAccent,
      decoration: _inputDecoration(
        label: label,
        isPassword: isPassword,
        obscure: obscure,
        onToggleObscure: onToggleObscure,
      ),
    );
  }

  Widget _errorCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A161A),
        border: Border.all(color: const Color(0xFF7A2E38)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.error_outline_rounded,
              size: 16,
              color: Color(0xFFFF8A80),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              errorMessage ?? '',
              style: AppTextStyles.label.copyWith(
                color: const Color(0xFFFFB4AB),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topIcon() {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: AppColors.bgAccent,
        border: Border.all(color: AppColors.borderAccent, width: 1.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(child: Text('🌟', style: TextStyle(fontSize: 28))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideIn(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const OnboardingFlow()),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Back',
                        style: AppTextStyles.subText.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 26),

              FadeSlideIn(
                delay: const Duration(milliseconds: 60),
                child: _topIcon(),
              ),

              const SizedBox(height: 18),

              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: AppBadge(isLogin ? 'Welcome back' : 'Get started'),
              ),

              const SizedBox(height: 12),

              FadeSlideIn(
                delay: const Duration(milliseconds: 140),
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

              const SizedBox(height: 10),

              FadeSlideIn(
                delay: const Duration(milliseconds: 180),
                child: Text(
                  isLogin
                      ? 'Pick up right where you left off and keep leveling up your hobbies.'
                      : 'Start your journey with a cleaner, smarter hobby tracking experience.',
                  style: AppTextStyles.subText,
                ),
              ),

              const SizedBox(height: 30),

              FadeSlideIn(
                delay: const Duration(milliseconds: 220),
                child: _inputField(
                  label: 'Email address',
                  controller: _controllerEmail,
                ),
              ),

              const SizedBox(height: 12),

              FadeSlideIn(
                delay: const Duration(milliseconds: 280),
                child: _inputField(
                  label: 'Password',
                  controller: _controllerPassword,
                  isPassword: true,
                  obscure: _obscurePassword,
                  onToggleObscure: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),

              if (!isLogin) ...[
                const SizedBox(height: 12),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 340),
                  child: _inputField(
                    label: 'Confirm password',
                    controller: _controllerRePassword,
                    isPassword: true,
                    obscure: _obscureRePassword,
                    onToggleObscure: () {
                      setState(() {
                        _obscureRePassword = !_obscureRePassword;
                      });
                    },
                  ),
                ),
              ],

              if (errorMessage != null && errorMessage!.isNotEmpty) ...[
                const SizedBox(height: 14),
                FadeSlideIn(child: _errorCard()),
              ],

              const SizedBox(height: 24),

              FadeSlideIn(
                delay: const Duration(milliseconds: 400),
                child: PrimaryButton(
                  label: isLogin ? 'Log in →' : 'Create account →',
                  dark: true,
                  onTap: isLogin ? _signIn : _signUp,
                ),
              ),

              const SizedBox(height: 12),

              FadeSlideIn(
                delay: const Duration(milliseconds: 460),
                child: GhostButton(
                  label: isLogin
                      ? "Don't have an account? Sign up"
                      : 'Already have an account? Log in',
                  onTap: () {
                    setState(() {
                      isLogin = !isLogin;
                      errorMessage = null;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
