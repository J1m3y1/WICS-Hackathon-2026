import 'package:flutter/material.dart';
import '../shared/app_theme.dart';

class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool dark;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = dark
        ? AppColors.primary
        : AppColors.secondary;
    final Color foregroundColor = AppColors.textPrimary;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const GhostButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          foregroundColor: AppColors.textPrimary,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String tag;
  final String heading;
  final String italic;
  final String? subtitle;

  const SectionHeader({
    super.key,
    required this.tag,
    required this.heading,
    required this.italic,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.chipBackground,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            tag,
            style: AppTextStyles.label.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 14),
        RichText(
          text: TextSpan(
            style: AppTextStyles.pageTitle,
            children: [
              TextSpan(text: heading),
              const TextSpan(text: ' '),
              TextSpan(
                text: italic,
                style: AppTextStyles.pageTitle.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(subtitle!, style: AppTextStyles.subText),
        ],
      ],
    );
  }
}

class HobbyChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool active;

  const HobbyChip({
    super.key,
    required this.emoji,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withOpacity(0.18)
            : AppColors.chipBackground,
        border: Border.all(
          color: active ? AppColors.primary : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.chipText),
        ],
      ),
    );
  }
}

class AppBadge extends StatelessWidget {
  final String label;

  const AppBadge(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.16),
        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.badgeText.copyWith(
          color: AppColors.secondary,
          fontSize: 11,
        ),
      ),
    );
  }
}

class XpBar extends StatelessWidget {
  final double percent;

  const XpBar({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 8,
        color: AppColors.progressBackground,
        child: Row(
          children: [
            Flexible(
              flex: (clamped * 1000).round(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.xpStart, AppColors.xpEnd],
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 1000 - (clamped * 1000).round(),
              child: const SizedBox.expand(),
            ),
          ],
        ),
      ),
    );
  }
}
