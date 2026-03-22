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

  final firestore = FirebaseFirestore.instance;

  try {
    final dailySnapshot = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('hobbies')
        .doc(widget.hobbyKey)
        .collection('DailyTasks')
        .get();

    final weeklySnapshot = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('hobbies')
        .doc(widget.hobbyKey)
        .collection('WeeklyTasks')
        .get();

    setState(() {
      dailyTasks = dailySnapshot.docs
          .map((doc) => doc.data())
          .toList();

      weeklyTasks = weeklySnapshot.docs
          .map((doc) => doc.data())
          .toList();
    });

  } catch (e) {
    print("Error fetching tasks: $e");
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

    final weeklyStream = firestore
        .collection('users')
        .doc(user.uid)
        .collection('hobbies')
        .doc(widget.hobbyKey)
        .collection('WeeklyTasks')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

    final dailyStream = firestore
        .collection('users')
        .doc(user.uid)
        .collection('hobbies')
        .doc(widget.hobbyKey)
        .collection('DailyTasks')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

    final weeklyStream = firestore
        .collection('users')
        .doc(user.uid)
        .collection('hobbies')
        .doc(widget.hobbyKey)
        .collection('WeeklyTasks')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

    final dailyStream = firestore
        .collection('users')
        .doc(user.uid)
        .collection('hobbies')
        .doc(widget.hobbyKey)
        .collection('DailyTasks')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: weeklyStream,
        builder: (context, weeklySnapshot) {
          if (!weeklySnapshot.hasData) return Center(child: CircularProgressIndicator());
          final weeklyTasks = weeklySnapshot.data!;

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: dailyStream, 
            builder: (context, dailySnapshot) {
              if (!dailySnapshot.hasData) return Center(child: CircularProgressIndicator());
              final dailyTasks = dailySnapshot.data!;

              if(weeklyTasks.isEmpty && dailyTasks.isEmpty) {
                return Center(child: Text('No tasks for this hobby yet.'));
              }
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
                itemCount: totalItems,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const ListTile(
                    title: Text('Weekly Tasks', style: TextStyle(fontWeight: FontWeight.bold),),
                  );
                  }

                  if(index > 0 && index <= weeklyTasks.length) {
                    final task = weeklyTasks[index - 1];
                    task['completed'] = task['completed'] ?? false;
                    
                    return ListTile(
                      onTap: () async {
                          task['completed'] = !task['completed'];
                          await firestore
                            .collection('users')
                            .doc(user.uid)
                            .collection('hobbies')
                            .doc(widget.hobbyKey)
                            .collection('WeeklyTasks')
                            .doc(task['id']) 
                            .update({'completed': task['completed']});
                        setState(() {});
                      },
                      title: Text(task['title']?? "No Title",
                      style: TextStyle(color: task['completed'] ? Colors.grey : Colors.black),
                    ),
                      subtitle: Text(task['description']?? ""),
                      trailing: task['completed'] 
                      ? const Icon(Icons.check, color: Colors.green) 
                      :null,
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
                  
                  return ListTile(
                    onTap: () async {
                        task['completed'] = !task['completed'];
                        await firestore
                          .collection('users')
                          .doc(user.uid)
                          .collection('hobbies')
                          .doc(widget.hobbyKey)
                          .collection('DailyTasks')
                          .doc(task['id']) 
                          .update({'completed': task['completed']});
                      setState(() {});
                    },
                    title: Text(task['title']?? "No Title", style: TextStyle(color: task['completed'] ? Colors.grey : Colors.black),
                    
                    ),
                    subtitle: Text(task['description']?? ""),
                    trailing: task['completed'] 
                      ? const Icon(Icons.check, color: Colors.green)
                      :null,
                  );
                  
                },
              );
              }
            );
        },
      ),
    );
  }
}
