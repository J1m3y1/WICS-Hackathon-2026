import 'package:flutter/material.dart';
import '/theme/app_theme.dart';
import '/theme/app_text.dart';
import '../../widgets/shared_widgets.dart';

const _steps = [
  (num: '01', icon: '🎯', title: 'Pick your hobbies',
   desc: 'Choose up to 5 across physical, skill-based, and social. Each gets its own independent level.'),
  (num: '02', icon: '📋', title: 'Tasks catered to your goals',
   desc: 'Create tasks depending on your goals based on our Hobby Intent Interview'),
  (num: '03', icon: '✅', title: 'Do it, post proof',
   desc: 'Complete the task in real life, snap a photo or write a note. Your progress is real and logged.'),
  (num: '04', icon: '⬆️', title: 'Level up',
   desc: 'Earn XP, keep streaks alive, unlock badges. Watch each hobby grow from beginner to expert.'),
];

class HowItWorksScreen extends StatelessWidget {
  final VoidCallback onNext;
  const HowItWorksScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgPage,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideIn(
                delay: const Duration(milliseconds: 60),
                child: SectionHeader(
                  tag: 'The process',
                  heading: 'Simple loop,',
                  italic: 'real results',
                ),
              ),

              const SizedBox(height: 28),

              ...List.generate(_steps.length, (i) => FadeSlideIn(
                delay: Duration(milliseconds: 120 + i * 90),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _StepCard(step: _steps[i]),
                ),
              )),

              const SizedBox(height: 8),

              FadeSlideIn(
                delay: const Duration(milliseconds: 520),
                child: PrimaryButton(
                  label: 'See the features →',
                  onTap: onNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final ({String num, String icon, String title, String desc}) step;
  const _StepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big italic number
          SizedBox(
            width: 40,
            child: Text(
              step.num,
              style: const TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 36,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                color: AppColors.borderAccent,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(step.icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(step.title, style: AppTextStyles.cardTitle),
                  ],
                ),
                const SizedBox(height: 7),
                Text(step.desc, style: AppTextStyles.body.copyWith(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
