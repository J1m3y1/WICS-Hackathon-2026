import 'dart:async';
import 'package:flutter/material.dart';
import '/theme/app_theme.dart';
import '/theme/app_text.dart';
import '/widgets/shared_widgets.dart';

const _morphWords = [
  'hobbies', 'guitar', 'cooking', 'fitness',
  'chess', 'photography', 'yoga', 'coding', 'painting',
];

class HeroScreen extends StatefulWidget {
  final VoidCallback onNext;
  const HeroScreen({super.key, required this.onNext});

  @override
  State<HeroScreen> createState() => _HeroScreenState();
}

class _HeroScreenState extends State<HeroScreen>
    with SingleTickerProviderStateMixin {
  int _wordIdx = 0;
  bool _wordVisible = true;
  Timer? _timer;

  late AnimationController _underlineCtrl;
  late Animation<double> _underline;

  @override
  void initState() {
    super.initState();
    // Underline draw-in animation
    _underlineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _underline = CurvedAnimation(parent: _underlineCtrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _underlineCtrl.forward();
    });

    // Word morph timer
    _timer = Timer.periodic(const Duration(milliseconds: 2600), (_) {
      if (!mounted) return;
      setState(() => _wordVisible = false);
      Future.delayed(const Duration(milliseconds: 280), () {
        if (!mounted) return;
        setState(() {
          _wordIdx = (_wordIdx + 1) % _morphWords.length;
          _wordVisible = true;
        });
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _underlineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;

    final logoSize = w * 0.16;
    final headlineFontSize = w * 0.075;

    return Container(
      color: AppColors.bgPage,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: w * 0.06),
          child: Column(
            children: [
              SizedBox(height: h * 0.04),

              // Logo
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    Container(
                      width: logoSize, height: logoSize,
                      decoration: BoxDecoration(
                        color: AppColors.bgAccent,
                        border: Border.all(color: AppColors.borderAccent, width: 1.5),
                        borderRadius: BorderRadius.circular(logoSize * 0.28),
                      ),
                      child: Center(child: Text('🌟', style: TextStyle(fontSize: logoSize * 0.46))),
                    ),
                    SizedBox(height: h * 0.018),
                    const Text('HobbyUp', style: AppTextStyles.pageTitle),
                  ],
                ),
              ),

              SizedBox(height: h * 0.03),

              // Hero headline with morphing word
              FadeSlideIn(
                delay: const Duration(milliseconds: 320),
                child: Column(
                  children: [
                    Text(
                      'Turn your',
                      style: AppTextStyles.pageTitle.copyWith(fontSize: headlineFontSize),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: h * 0.003),
                    AnimatedOpacity(
                      opacity: _wordVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 260),
                      child: AnimatedSlide(
                        offset: _wordVisible ? Offset.zero : const Offset(0, 0.08),
                        duration: const Duration(milliseconds: 260),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Text(
                              _morphWords[_wordIdx],
                              style: AppTextStyles.pageTitle.copyWith(
                                fontSize: headlineFontSize,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textAccent,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            // Underline
                            Positioned(
                              bottom: -4, left: 0, right: 0,
                              child: AnimatedBuilder(
                                animation: _underline,
                                builder: (_, __) => FractionallySizedBox(
                                  widthFactor: _underline.value,
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [AppColors.xpStart, AppColors.xpEnd],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: h * 0.003),
                    Text(
                      'into a superpower',
                      style: AppTextStyles.pageTitle.copyWith(fontSize: headlineFontSize),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.025),

              // Subtitle
              FadeSlideIn(
                delay: const Duration(milliseconds: 420),
                child: Text(
                  'Pick hobbies, complete daily tasks, earn XP, and level up — one day at a time.',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: h * 0.038),

              // Hobby chips
              FadeSlideIn(
                delay: const Duration(milliseconds: 480),
                child: Wrap(
                  spacing: w * 0.02, runSpacing: w * 0.02,
                  alignment: WrapAlignment.center,
                  children: const [
                    HobbyChip(emoji: '🏋️', label: 'Gym',    active: true),
                    HobbyChip(emoji: '🎸', label: 'Guitar', active: false),
                    HobbyChip(emoji: '📸', label: 'Photo',  active: true),
                    HobbyChip(emoji: '♟',  label: 'Chess',  active: false),
                    HobbyChip(emoji: '🍳', label: 'Cook',   active: true),
                  ],
                ),
              ),

              SizedBox(height: h * 0.05),

              // CTA buttons
              FadeSlideIn(
                delay: const Duration(milliseconds: 560),
                child: Column(
                  children: [
                    PrimaryButton(
                      label: 'Get started free →',
                      dark: true,
                      onTap: widget.onNext,
                    ),
                    SizedBox(height: h * 0.014),
                    GhostButton(label: 'Sign in instead', onTap: widget.onNext),
                  ],
                ),
              ),

              SizedBox(height: h * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 1, end: 1.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _scale,
    builder: (_, __) => Transform.scale(
      scale: _scale.value,
      child: Container(
        width: 6, height: 6,
        decoration: const BoxDecoration(
          color: AppColors.xpEnd,
          shape: BoxShape.circle,
        ),
      ),
    ),
  );
}





