import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_text.dart';
import '../../widgets/shared_widgets.dart';

const _hobbies = [
  (emoji: '🏋️', name: 'Gym',         level: 6, tier: 'Advanced',     pct: 0.72, xp: 720),
  (emoji: '🎸', name: 'Guitar',      level: 3, tier: 'Beginner',     pct: 0.38, xp: 380),
  (emoji: '📸', name: 'Photography', level: 4, tier: 'Intermediate', pct: 0.55, xp: 550),
];

class FeaturesScreen extends StatelessWidget {
  final VoidCallback onNext;
  const FeaturesScreen({super.key, required this.onNext});

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
                child: const SectionHeader(
                  tag: 'Leveling System',
                  heading: 'Every hobby,',
                  italic: 'its own progression',
                  subtitle:
                      'See exactly where you stand and what unlocks next — for every hobby you love.',
                ),
              ),

              const SizedBox(height: 24),

              // Dashboard mockup card
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      // Header row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Your hobbies',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              )),
                          Row(
                            children: [
                              const Text('🔥 ', style: TextStyle(fontSize: 13)),
                              const Text('12',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  )),
                              const SizedBox(width: 3),
                              Text('days',
                                  style: AppTextStyles.label.copyWith(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Hobby rows
                      ...List.generate(
                        _hobbies.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: FadeSlideIn(
                            delay: Duration(milliseconds: 260 + i * 100),
                            child: _HobbyRow(hobby: _hobbies[i]),
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Stat pills
                      Row(
                        children: [
                          Expanded(child: _StatPill(value: '47', label: 'Tasks done')),
                          const SizedBox(width: 10),
                          Expanded(child: _StatPill(value: '3',  label: 'Active hobbies')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              FadeSlideIn(
                delay: const Duration(milliseconds: 540),
                child: PrimaryButton(label: 'See task engine →', onTap: onNext),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HobbyRow extends StatelessWidget {
  final ({String emoji, String name, int level, String tier, double pct, int xp}) hobby;
  const _HobbyRow({required this.hobby});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Emoji icon
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.bgAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(hobby.emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),

          // Name + level + bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(hobby.name, style: AppTextStyles.cardTitle.copyWith(fontSize: 13)),
                    AppBadge('${hobby.xp} XP'),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Lvl ${hobby.level} · ${hobby.tier}',
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: 5),
                XpBar(percent: hobby.pct),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  const _StatPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgAccent,
        border: Border.all(color: AppColors.borderAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: AppColors.textAccent,
              )),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.label),
        ],
      ),
    );
  }
}
