import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wics_hackathon_2026/services/auth.dart';

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
  Widget build(BuildContext context) {
    final user = Auth().currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.hobbyKey} Tasks'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: firestore.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final weeklyTasks = List<Map<String, dynamic>>.from(
                data['hobbies']?[widget.hobbyKey]?['WeeklyTasks'] ?? []
              );
          final dailyTasks = List<Map<String, dynamic>>.from(
            data['hobbies']?[widget.hobbyKey]?['DailyTasks'] ?? []
          );

          if (weeklyTasks.isEmpty && dailyTasks.isEmpty) {
            return Center(child: Text('No tasks for this hobby yet.'));
          }

          final totalItems = weeklyTasks.length + dailyTasks.length + 2;

          return ListView.builder(
            itemCount: totalItems,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                title: Text('Weekly Tasks', style: TextStyle(fontWeight: FontWeight.bold),),
              );
              }

              if(index > 0 && index <= weeklyTasks.length) {
                final task = weeklyTasks[index - 1];
                return ListTile(
                  title: Text(task['title']?? "No Title"),
                  subtitle: Text(task['description']?? ""),
                );
              }

              if (index == weeklyTasks.length + 1) {
                return ListTile(
                title: Text('Daily Tasks', style: TextStyle(fontWeight: FontWeight.bold),),
              );
              }

              final task = dailyTasks[index - weeklyTasks.length - 2];
              return ListTile(
                title: Text(task['title']?? "No Title"),
                subtitle: Text(task['description']?? ""),
              );
              
            },
          );
          
        },
      ),
    );
  }
}
