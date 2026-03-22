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

  // Logic for calculating XP/Leveling based on your second snippet
  Map<String, dynamic> _buildUpdatedHobbyInfo({
    required Map<String, dynamic> currentInfo,
    required int xpChange,
  }) {
    int xp = (currentInfo['xp'] ?? 0) + xpChange;
    int level = currentInfo['level'] ?? 1;
    int maxXp = currentInfo['maxXp'] ?? 500;

    if (xp < 0) xp = 0;

    while (xp >= maxXp) {
      xp -= maxXp;
      level += 1;
      maxXp += 500;
    }

    return {
      ...currentInfo,
      'xp': xp,
      'level': level,
      'maxXp': maxXp,
      'progress': maxXp == 0 ? 0 : xp / maxXp,
    };
  }

  // Updated to handle sub-collection toggle + XP update
  Future<void> _toggleTask({
    required User user,
    required Map<String, dynamic> task,
    required String collectionName,
  }) async {
    final userRef = firestore.collection('users').doc(user.uid);
    final taskRef = userRef
        .collection('hobbies')
        .doc(widget.hobbyKey)
        .collection(collectionName)
        .doc(task['id']);

    final bool isNowCompleted = !(task['completed'] ?? false);
    final int xpChange = isNowCompleted ? 100 : -100;

    // Get current XP info from the main hobby document
    final hobbyDoc = await userRef.collection('hobbies').doc(widget.hobbyKey).get();
    final currentInfo = (hobbyDoc.data()?['info'] as Map<String, dynamic>?) ?? {};

    final updatedInfo = _buildUpdatedHobbyInfo(
      currentInfo: currentInfo,
      xpChange: xpChange,
    );

    // Batch update: Task status and XP progress
    WriteBatch batch = firestore.batch();
    batch.update(taskRef, {'completed': isNowCompleted});
    batch.set(
      userRef.collection('hobbies').doc(widget.hobbyKey),
      {'info': updatedInfo},
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    final user = Auth().currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: Text('User not logged in', style: AppTextStyles.body)),
      );
    }

    // Streams from sub-collections (Logic from 1st snippet)
    final hobbyPath = firestore.collection('users').doc(user.uid).collection('hobbies').doc(widget.hobbyKey);
    final weeklyStream = hobbyPath.collection('WeeklyTasks').snapshots();
    final dailyStream = hobbyPath.collection('DailyTasks').snapshots();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text('${widget.hobbyKey} Tasks', style: AppTextStyles.pageTitle.copyWith(fontSize: 22)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: weeklyStream,
        builder: (context, weeklySnap) {
          return StreamBuilder<QuerySnapshot>(
            stream: dailyStream,
            builder: (context, dailySnap) {
              if (!weeklySnap.hasData || !dailySnap.hasData) {
                return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
              }

              final weeklyTasks = weeklySnap.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
              final dailyTasks = dailySnap.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

              if (weeklyTasks.isEmpty && dailyTasks.isEmpty) {
                return const Center(child: Text('No tasks for this hobby.', style: AppTextStyles.body));
              }

              final totalItems = weeklyTasks.length + dailyTasks.length + 2;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: totalItems,
                itemBuilder: (context, index) {
                  // --- SECTION HEADERS ---
                  if (index == 0) return _buildHeader('Weekly Tasks');
                  if (index == weeklyTasks.length + 1) return _buildHeader('Daily Tasks');

                  // --- TASK CARDS ---
                  final bool isWeekly = index <= weeklyTasks.length;
                  final taskIndex = isWeekly ? index - 1 : index - weeklyTasks.length - 2;
                  final task = isWeekly ? weeklyTasks[taskIndex] : dailyTasks[taskIndex];
                  final collectionName = isWeekly ? 'WeeklyTasks' : 'DailyTasks';

                  return _buildTaskCard(user, task, collectionName);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: AppTextStyles.sectionTitle),
    );
  }

  Widget _buildTaskCard(User user, Map<String, dynamic> task, String collectionName) {
    final bool isComp = task['completed'] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => _toggleTask(user: user, task: task, collectionName: collectionName),
        title: Text(
          task['title'] ?? 'No Title',
          style: TextStyle(
            color: isComp ? AppColors.textSecondary : AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            decoration: isComp ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Text(task['description'] ?? '', style: AppTextStyles.subText),
        trailing: Icon(
          isComp ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: isComp ? AppColors.secondary : AppColors.textSecondary,
        ),
      ),
    );
  }
}