import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wics_hackathon_2026/services/auth.dart';
import 'package:wics_hackathon_2026/shared/app_theme.dart';

class HomePage extends StatefulWidget {
  final String hobbyKey;
  const HomePage({super.key, required this.hobbyKey});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> dailyTasks = [];
  List<Map<String, dynamic>> weeklyTasks = [];

  @override
  void initState() {
    super.initState();
    getUserHobbyTasks();
  }

  void getUserHobbyTasks() async {
    final User? user = Auth().currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      final userData = userDoc.data();
      final dTasks =
          userData?['hobbies']?[widget.hobbyKey]?['DailyTasks'] ?? [];
      final wTasks =
          userData?['hobbies']?[widget.hobbyKey]?['WeeklyTasks'] ?? [];

      setState(() {
        dailyTasks = List<Map<String, dynamic>>.from(dTasks);
        weeklyTasks = List<Map<String, dynamic>>.from(wTasks);
      });
    }
  }

  String _getRankFromLevel(int level) {
    if (level >= 5) return 'Legend';
    if (level >= 4) return 'Master';
    if (level >= 3) return 'Expert';
    if (level >= 2) return 'Intermediate';
    if (level >= 1) return 'Novice';
    return 'Beginner';
  }

  Map<String, dynamic> _buildUpdatedHobbyInfo({
    required Map<String, dynamic> currentInfo,
    required int xpChange,
  }) {
    int xp = (currentInfo['xp'] ?? 0) + xpChange;
    int level = currentInfo['level'] ?? 0;
    int maxXp = currentInfo['maxXp'] ?? 100;

    if (xp < 0) {
      xp = 0;
    }

    while (xp >= maxXp) {
      xp -= maxXp;
      level += 1;
      maxXp += 200;
    }

    final String currentRank = _getRankFromLevel(level);
    final String nextRank = _getRankFromLevel(level + 1);
    final double progress = maxXp == 0 ? 0 : xp / maxXp;

    return {
      ...currentInfo,
      'xp': xp,
      'level': level,
      'maxXp': maxXp,
      'progress': progress,
      'currentRank': currentRank,
      'nextRank': nextRank,
    };
  }

  Future<void> _showRankUpDialog({
    required String hobbyName,
    required int newLevel,
    required String newRank,
  }) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Rank Up',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.7),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 22,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.16),
                      border: Border.all(color: AppColors.secondary, width: 2),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.secondary,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Rank Up!',
                    style: AppTextStyles.pageTitle.copyWith(
                      fontSize: 28,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$hobbyName reached Level $newLevel',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      newRank,
                      style: AppTextStyles.badgeText.copyWith(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You are building real momentum. Keep going — every completed task strengthens your hobby identity.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.subText.copyWith(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('Keep the streak alive'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return Transform.scale(
          scale: curved.value,
          child: Opacity(opacity: animation.value, child: child),
        );
      },
    );
  }

  Future<bool> _showCompleteTaskDialog({
    required String title,
    required String description,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.55),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.16),
                    border: Border.all(color: AppColors.secondary, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.secondary,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Mark task complete?',
                  style: AppTextStyles.pageTitle.copyWith(
                    fontSize: 24,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (description.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: AppTextStyles.subText.copyWith(height: 1.45),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  'You’ll earn progress toward your next rank.',
                  style: AppTextStyles.subText.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Not yet', style: AppTextStyles.body),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(true),
                        label: const Text('Yes, completed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  Future<void> _toggleTaskAndUpdateProgress({
    required User user,
    required List<Map<String, dynamic>> tasks,
    required int index,
    required String taskFieldName,
  }) async {
    final userRef = firestore.collection('users').doc(user.uid);
    final snapshot = await userRef.get();

    final data = snapshot.data() ?? {};
    final hobbyData =
        (data['hobbies']?[widget.hobbyKey] as Map<String, dynamic>?) ?? {};
    final currentInfo = (hobbyData['info'] as Map<String, dynamic>?) ?? {};

    final updatedTasks = List<Map<String, dynamic>>.from(tasks);
    final updatedTask = Map<String, dynamic>.from(updatedTasks[index]);

    final bool wasCompleted = updatedTask['completed'] ?? false;

    if (wasCompleted) {
      return;
    }

    final bool confirmed = await _showCompleteTaskDialog(
      title: updatedTask['title'] ?? 'Complete task',
      description: updatedTask['description'] ?? '',
    );

    if (!confirmed) {
      return;
    }

    updatedTask['completed'] = true;
    updatedTasks[index] = updatedTask;

    const int xpChange = 100;

    final int oldLevel = currentInfo['level'] ?? 1;

    final updatedInfo = _buildUpdatedHobbyInfo(
      currentInfo: currentInfo,
      xpChange: xpChange,
    );

    final int newLevel = updatedInfo['level'] ?? oldLevel;
    final String newRank = updatedInfo['currentRank'] ?? 'Beginner';

    await userRef.update({
      'hobbies.${widget.hobbyKey}.$taskFieldName': updatedTasks,
      'hobbies.${widget.hobbyKey}.info': updatedInfo,
    });

    if (!mounted) return;

    if (newLevel > oldLevel) {
      await _showRankUpDialog(
        hobbyName: widget.hobbyKey,
        newLevel: newLevel,
        newRank: newRank,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Auth().currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: Text('User not logged in', style: AppTextStyles.body),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          '${widget.hobbyKey} Tasks',
          style: AppTextStyles.pageTitle.copyWith(fontSize: 22),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: firestore.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: AppTextStyles.body,
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          final weeklyTasks = List<Map<String, dynamic>>.from(
            data['hobbies']?[widget.hobbyKey]?['WeeklyTasks'] ?? [],
          );

          final dailyTasks = List<Map<String, dynamic>>.from(
            data['hobbies']?[widget.hobbyKey]?['DailyTasks'] ?? [],
          );

          if (weeklyTasks.isEmpty && dailyTasks.isEmpty) {
            return const Center(
              child: Text(
                'No tasks for this hobby yet.',
                style: AppTextStyles.body,
              ),
            );
          }

          final totalItems = weeklyTasks.length + dailyTasks.length + 2;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: totalItems,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    'Weekly Tasks',
                    style: AppTextStyles.sectionTitle,
                  ),
                );
              }

              if (index > 0 && index <= weeklyTasks.length) {
                final task = weeklyTasks[index - 1];
                task['completed'] = task['completed'] ?? false;

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    onTap: () async {
                      await _toggleTaskAndUpdateProgress(
                        user: user,
                        tasks: weeklyTasks,
                        index: index - 1,
                        taskFieldName: 'WeeklyTasks',
                      );
                    },
                    title: Text(
                      task['title'] ?? 'No Title',
                      style: TextStyle(
                        color: task['completed']
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        decoration: task['completed']
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: AppColors.textSecondary,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        task['description'] ?? '',
                        style: AppTextStyles.subText,
                      ),
                    ),
                    trailing: task['completed']
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.secondary,
                          )
                        : const Icon(
                            Icons.radio_button_unchecked_rounded,
                            color: AppColors.textSecondary,
                          ),
                  ),
                );
              }

              if (index == weeklyTasks.length + 1) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Daily Tasks', style: AppTextStyles.sectionTitle),
                );
              }

              final dailyIndex = index - weeklyTasks.length - 2;
              final task = dailyTasks[dailyIndex];
              task['completed'] = task['completed'] ?? false;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  onTap: () async {
                    await _toggleTaskAndUpdateProgress(
                      user: user,
                      tasks: dailyTasks,
                      index: dailyIndex,
                      taskFieldName: 'DailyTasks',
                    );
                  },
                  title: Text(
                    task['title'] ?? 'No Title',
                    style: TextStyle(
                      color: task['completed']
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      decoration: task['completed']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: AppColors.textSecondary,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      task['description'] ?? '',
                      style: AppTextStyles.subText,
                    ),
                  ),
                  trailing: task['completed']
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.secondary,
                        )
                      : const Icon(
                          Icons.radio_button_unchecked_rounded,
                          color: AppColors.textSecondary,
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
