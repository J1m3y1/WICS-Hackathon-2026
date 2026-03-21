import 'package:flutter/material.dart';
import '/theme/app_theme.dart';
import 'hero.dart';
import 'how_it_works.dart';
//import 'features.dart';
//import 'task_feed.dart';
//import 'social_feed.dart';

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
    }
  }

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          // PageView
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (i) => setState(() => _current = i),
              children: [
                HeroScreen(onNext: _next),
                HowItWorksScreen(onNext: _next),
                //FeaturesScreen(onNext: _next),
                //TaskFeedScreen(onNext: _next),
                //SocialFeedScreen(onNext: _next),
              ],
            ),
          ),

          // Bottom dot indicator + nav bar
          _BottomNav(current: _current, total: _pageCount),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int current;
  final int total;
  const _BottomNav({required this.current, required this.total});

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
            return AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? AppColors.textAccent : AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ),
    );
  }
}
