import 'package:flutter/material.dart';
import 'package:wics_hackathon_2026/shared/app_theme.dart';

class AIRecommendationCard extends StatelessWidget {
  final String hobby;
  final String taskTitle;
  final double score;

  const AIRecommendationCard({
    super.key,
    required this.hobby,
    required this.taskTitle,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final int confidence = (score * 100).round();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Recommendation',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 8),
          Text(
            'Try $hobby',
            style: AppTextStyles.cardTitle.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 6),
          Text(
            taskTitle,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 10),
          Text(
            'Confidence: $confidence%',
            style: AppTextStyles.subText,
          ),
        ],
      ),
    );
  }
}