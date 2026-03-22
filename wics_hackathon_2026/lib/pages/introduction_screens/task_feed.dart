import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_text.dart';
import '../../widgets/shared_widgets.dart';

const _tasks = [
  (emoji: '🏋️', title: '30 min cardio session',         hobby: 'Gym',         mins: 30, xp: 80),
  (emoji: '🎸', title: 'Practice G major transitions',  hobby: 'Guitar',      mins: 15, xp: 45),
  (emoji: '📸', title: 'Golden hour outdoor shoot',     hobby: 'Photography', mins: 45, xp: 60),
];

class TaskFeedScreen extends StatefulWidget {
  final VoidCallback onNext;
  const TaskFeedScreen({super.key, required this.onNext});

  @override
  State<TaskFeedScreen> createState() => _TaskFeedScreenState();
}

class _TaskFeedScreenState extends State<TaskFeedScreen>
    with SingleTickerProviderStateMixin {
  double _dragY = 0;
  bool _completed = false;
  late AnimationController _checkCtrl;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _checkScale = CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() { _checkCtrl.dispose(); super.dispose(); }

  void _onComplete() {
    setState(() => _completed = true);
    _checkCtrl.forward();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _checkCtrl.reverse();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() { _completed = false; _dragY = 0; });
      });
    });
  }

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
                  tag: 'Task Engine',
                  heading: 'Tasks that fit',
                  italic: 'your day',
                  subtitle: 'Swipe the top card up to complete, or down to skip.',
                ),
              ),

              const SizedBox(height: 28),


              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: SizedBox(
                  height: 210,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      ...[2, 1].map((depth) => Positioned(
                        top: depth * 6.0,
                        left: depth * 5.0,
                        right: depth * 5.0,
                        child: Opacity(
                          opacity: 0.35 + depth * 0.2,
                          child: Transform.scale(
                            scale: 1 - depth * 0.03,
                            alignment: Alignment.topCenter,
                            child: _TaskCardContent(
                              task: _tasks[depth],
                              isTop: false,
                            ),
                          ),
                        ),
                      )),

                      Positioned(
                        top: 0, left: 0, right: 0,
                        child: GestureDetector(
                          onVerticalDragUpdate: (d) {
                            if (_completed) return;
                            setState(() => _dragY = d.localPosition.dy < 0
                                ? d.localPosition.dy
                                : d.localPosition.dy * 0.2);
                          },
                          onVerticalDragEnd: (d) {
                            if (_completed) return;
                            if (_dragY < -50 ||
                                (d.primaryVelocity != null &&
                                    d.primaryVelocity! < -600)) {
                              _onComplete();
                            } else {
                              setState(() => _dragY = 0);
                            }
                          },
                          child: AnimatedContainer(
                            duration: _dragY == 0
                                ? const Duration(milliseconds: 380)
                                : Duration.zero,
                            curve: Curves.easeOutCubic,
                            transform: Matrix4.translationValues(0, _dragY, 0)
                              ..rotateZ(_dragY * 0.0008),
                            child: _TaskCardContent(
                              task: _tasks[0],
                              isTop: true,
                              completed: _completed,
                              checkScale: _checkScale,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              FadeSlideIn(
                delay: const Duration(milliseconds: 320),
                child: Center(
                  child: Text(
                    '↑ swipe up to complete · ↓ swipe down to skip',
                    style: AppTextStyles.label.copyWith(fontSize: 11),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              FadeSlideIn(
                delay: const Duration(milliseconds: 380),
                child: GestureDetector(
                  onTap: _completed ? null : _onComplete,
                  child: Container(
                    width: double.infinity, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '↑ Tap to simulate complete',
                        style: AppTextStyles.body.copyWith(fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              FadeSlideIn(
                delay: const Duration(milliseconds: 440),
                child: PrimaryButton(label: 'See community feed →', onTap: widget.onNext),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskCardContent extends StatelessWidget {
  final ({String emoji, String title, String hobby, int mins, int xp}) task;
  final bool isTop;
  final bool completed;
  final Animation<double>? checkScale;

  const _TaskCardContent({
    required this.task,
    this.isTop = false,
    this.completed = false,
    this.checkScale,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: completed ? AppColors.bgAccent : AppColors.bgPage,
        border: Border.all(
          color: completed ? AppColors.borderAccent : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isTop
            ? [BoxShadow(color: AppColors.xpStart.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 4))]
            : null,
      ),
      child: completed
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                ScaleTransition(
                  scale: checkScale!,
                  child: const Text('✓', style: TextStyle(fontSize: 32, color: AppColors.textAccent)),
                ),
                const SizedBox(height: 8),
                const Text('Task completed!',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textAccent)),
                const SizedBox(height: 4),
                const Text('+80 XP earned 🎉',
                    style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                const SizedBox(height: 16),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task.title,
                              style: AppTextStyles.cardTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(
                            '${task.emoji} ${task.hobby} · ~${task.mins} min',
                            style: AppTextStyles.label,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    AppBadge('+${task.xp} XP'),
                  ],
                ),
                if (isTop) ...[
                  const SizedBox(height: 12),
                  Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('↑ complete', style: AppTextStyles.label.copyWith(fontSize: 10)),
                      Text('↓ skip', style: AppTextStyles.label.copyWith(fontSize: 10)),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}
