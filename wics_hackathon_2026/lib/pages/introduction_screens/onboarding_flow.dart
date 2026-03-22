import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../login_signup.dart';
import 'hero.dart';
import 'how_it_works.dart';
import 'features.dart';
import 'task_feed.dart';
import 'social_feed.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _pageCtrl = PageController();
  int _current = 0;

  static const _pageCount = 5;

  void _next() {
    if (_current < _pageCount - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _goToLogin(initialIsLogin: false);
    }
  }

  void _goToLogin({bool initialIsLogin = true}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(initialIsLogin: initialIsLogin),
      ),
    );
  }

  void _goToPage(int index) {
    _pageCtrl.animateToPage(
      index,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (i) => setState(() => _current = i),
              children: [
                HeroScreen(onNext: _next, onSignIn: () => _goToLogin()),
                HowItWorksScreen(onNext: _next),
                FeaturesScreen(onNext: _next),
                TaskFeedScreen(onNext: _next),
                SocialFeedScreen(onNext: _next, onSignIn: () => _goToLogin()),
              ],
            ),
          ),

          _BottomNav(current: _current, total: _pageCount, onDotTap: _goToPage),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int current;
  final int total;
  final ValueChanged<int> onDotTap;
  const _BottomNav({required this.current, required this.total, required this.onDotTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(total, (i) {
            final active = i == current;
            return GestureDetector(
              onTap: () => onDotTap(i),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  width: active ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active ? AppColors.textAccent : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
