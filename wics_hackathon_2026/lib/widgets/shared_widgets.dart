import 'package:flutter/material.dart';
import '/theme/app_theme.dart';
import '/theme/app_text.dart';


class XpBar extends StatefulWidget {
  final double percent; 
  final double height;

  const XpBar({super.key, required this.percent, this.height = 5});

  @override
  State<XpBar> createState() => _XpBarState();
}

class _XpBarState extends State<XpBar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _ctrl.animateTo(widget.percent);
    });
  }

  @override
  void didUpdateWidget(XpBar old) {
    super.didUpdateWidget(old);
    if (old.percent != widget.percent) _ctrl.animateTo(widget.percent);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(99),
        ),
        clipBehavior: Clip.antiAlias,
        child: FractionallySizedBox(
          widthFactor: _anim.value,
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.xpStart, AppColors.xpEnd]),
              borderRadius: BorderRadius.all(Radius.circular(99)),
            ),
          ),
        ),
      ),
    );
  }
}

//Badge pill
class AppBadge extends StatelessWidget {
  final String text;
  final Color? bg;
  final Color? borderColor;
  final Color? textColor;

  const AppBadge(this.text, {super.key, this.bg, this.borderColor, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg ?? AppColors.bgAccent,
        border: Border.all(color: borderColor ?? AppColors.borderAccent),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: AppTextStyles.badge.copyWith(color: textColor ?? AppColors.textAccent),
      ),
    );
  }
}

//Hobby Chip
class HobbyChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool active;

  const HobbyChip({super.key, required this.emoji, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.bgAccent : AppColors.bgSurface,
        border: Border.all(color: active ? AppColors.borderAccent : AppColors.border),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: active ? FontWeight.w500 : FontWeight.w400,
              color: active ? AppColors.textAccent : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

//Primary Button
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool dark;

  const PrimaryButton({super.key, required this.label, this.onTap, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: dark ? AppColors.textPrimary : AppColors.bgAccent,
          border: dark ? null : Border.all(color: AppColors.borderAccent),
          borderRadius: BorderRadius.circular(13),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: dark ? Colors.white : AppColors.textAccent,
          ),
        ),
      ),
    );
  }
}

//Ghost Button
class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const GhostButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(13),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

//Section header
class SectionHeader extends StatelessWidget {
  final String tag;
  final String heading;
  final String? italic;
  final String? subtitle;

  const SectionHeader({
    super.key,
    required this.tag,
    required this.heading,
    this.italic,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBadge(tag),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(
            style: AppTextStyles.sectionHeading,
            children: [
              TextSpan(text: heading),
              if (italic != null) ...[
                const TextSpan(text: '\n'),
                TextSpan(
                  text: italic,
                  style: AppTextStyles.sectionHeading.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textAccent,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(subtitle!, style: AppTextStyles.body),
        ],
      ],
    );
  }
}

//Fade+slide reveal
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}
