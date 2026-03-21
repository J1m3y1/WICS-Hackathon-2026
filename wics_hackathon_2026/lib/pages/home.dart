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
  void initState() {
    super.initState();
    getUserHobbyTasks();
  }

  
  void getUserHobbyTasks() async {
    final User? user = Auth().currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    if (userDoc.exists) {
      final userData = userDoc.data();
      final dTasks = userData?['hobbies']?[widget.hobbyKey]?['Daily_tasks']??[];
      final wTasks = userData?['hobbies']?[widget.hobbyKey]?['Weekly_tasks']??[];

      setState(() {
        dailyTasks = List<Map<String,dynamic>>.from(dTasks);
        weeklyTasks = List<Map<String,dynamic>>.from(wTasks);
      });
    }
  }

  Future<void> addThreeTasks() async {
  final User? user = Auth().currentUser;
  if (user == null) return;

  final timestamp = Timestamp.now();

  final wTasks = [
    {
      'title': 'Dribble practice',
      'description': 'Practice dribbling for 30 minutes',
      'createdAt': timestamp,
    },
    {
      'title': 'Shoot hoops',
      'description': 'Take 20 shots from free throw line',
      'createdAt': timestamp,
    },
    {
      'title': 'Passing practice',
      'description': 'Work on passing accuracy',
      'createdAt': timestamp,
    },
  ];

  final dTasks = [
    {
      'title': 'Dribble ',
      'description': 'Practice dribbling for 30 minutes',
      'createdAt': timestamp,
    },
    {
      'title': 'Shoot ',
      'description': 'Take 20 shots from free throw line',
      'createdAt': timestamp,
    },
    {
      'title': 'Passing ',
      'description': 'Work on passing accuracy',
      'createdAt': timestamp,
    },
  ];

  final userDocRef = firestore.collection('users').doc(user.uid);

  await userDocRef.set({
    'hobbies': {
      widget.hobbyKey: {
        'WeeklyTasks': FieldValue.arrayUnion(wTasks)
      }
    }
  }, SetOptions(merge: true));

  await userDocRef.set({
    'hobbies': {
      widget.hobbyKey: {
        'DailyTasks': FieldValue.arrayUnion(dTasks)
      }
    }
  }, SetOptions(merge: true));

  getUserHobbyTasks(); // Refresh the list
}

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
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: addThreeTasks, // Add 3 tasks on button press
          ),
        ],
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
