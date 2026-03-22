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

  Map<String, dynamic> _buildUpdatedHobbyInfo({
    required Map<String, dynamic> currentInfo,
    required int xpChange,
  }) {
    int xp = (currentInfo['xp'] ?? 0) + xpChange;
    int level = currentInfo['level'] ?? 1;
    int maxXp = currentInfo['maxXp'] ?? 500;
    String currentRank = currentInfo['currentRank'] ?? 'Beginner';
    String nextRank = currentInfo['nextRank'] ?? 'Intermediate';

    if (xp < 0) {
      xp = 0;
    }

    while (xp >= maxXp) {
      xp -= maxXp;
      level += 1;
      maxXp += 500;
    }

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
    final bool isNowCompleted = !wasCompleted;

    updatedTask['completed'] = isNowCompleted;
    updatedTasks[index] = updatedTask;

    final int xpChange = isNowCompleted ? 100 : -100;

    final updatedInfo = _buildUpdatedHobbyInfo(
      currentInfo: currentInfo,
      xpChange: xpChange,
    );

    await userRef.update({
      'hobbies.${widget.hobbyKey}.$taskFieldName': updatedTasks,
      'hobbies.${widget.hobbyKey}.info': updatedInfo,
    });
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
