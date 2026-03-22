import 'package:flutter/material.dart';
import '../../shared/app_theme.dart';
import '../../widgets/shared_widgets.dart';

const _posts = [
  (
    user: '@alex',
    emoji: '🏋️',
    hobby: 'Gym',
    level: 5,
    xp: 80,
    ago: '2 min ago',
    gradA: Color(0xFFFFE5B4),
    gradB: Color(0xFFFFD580),
  ),
  (
    user: '@mia',
    emoji: '🎸',
    hobby: 'Guitar',
    level: 2,
    xp: 45,
    ago: '18 min ago',
    gradA: Color(0xFFE8F4E8),
    gradB: Color(0xFFC5E0C5),
  ),
  (
    user: '@sam',
    emoji: '📸',
    hobby: 'Photography',
    level: 4,
    xp: 60,
    ago: '1 hr ago',
    gradA: Color(0xFFE8E8F4),
    gradB: Color(0xFFC5C5E0),
  ),
  (
    user: '@riko',
    emoji: '🍳',
    hobby: 'Cooking',
    level: 3,
    xp: 55,
    ago: '3 hr ago',
    gradA: Color(0xFFFCE4D6),
    gradB: Color(0xFFF9C6A4),
  ),
];

class SocialFeedScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onSignIn;

  const SocialFeedScreen({super.key, required this.onNext, this.onSignIn});

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
                  tag: 'Community',
                  heading: 'Do it together,',
                  italic: 'grow faster',
                  subtitle:
                      'See what friends are completing right now and cheer them on.',
                ),
              ),
              const SizedBox(height: 24),
              ...List.generate(
                _posts.length,
                (i) => FadeSlideIn(
                  delay: Duration(milliseconds: 100 + i * 90),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PostCard(post: _posts[i]),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeSlideIn(
                delay: const Duration(milliseconds: 500),
                child: PrimaryButton(
                  label: 'Join HobbyUp — it\'s free 🌟',
                  dark: true,
                  onTap: onNext,
                ),
              ),
              const SizedBox(height: 10),
              FadeSlideIn(
                delay: const Duration(milliseconds: 580),
                child: GhostButton(
                  label: 'Already have an account? Sign in',
                  onTap: onSignIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final ({
    String user,
    String emoji,
    String hobby,
    int level,
    int xp,
    String ago,
    Color gradA,
    Color gradB,
  })
  post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [post.gradA, post.gradB],
              ),
            ),
            child: Center(
              child: Text(post.emoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 13),
                          children: [
                            TextSpan(
                              text: '${post.user} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const TextSpan(
                              text: 'completed ',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            TextSpan(
                              text: '${post.hobby} · Lvl ${post.level}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(post.ago, style: AppTextStyles.label),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AppBadge('+${post.xp} XP'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
