import 'package:cloud_firestore/cloud_firestore.dart';
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
                return const ListTile(
                title: Text('Weekly Tasks', style: TextStyle(fontWeight: FontWeight.bold),),
              );
              }

              if(index > 0 && index <= weeklyTasks.length) {
                final task = weeklyTasks[index - 1];
                task['completed'] = task['completed'] ?? false;
                
                return ListTile(
                  onTap: () async {
                    setState((){
                      task['completed'] = !task['completed'];
                      });
                      await firestore.collection('users').doc(user.uid).update({
                       'hobbies.${widget.hobbyKey}.WeeklyTasks': weeklyTasks,
                    });
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
                return ListTile(
                title: Text('Daily Tasks', style: TextStyle(fontWeight: FontWeight.bold),),
              );
              }

              final dailyIndex = index - weeklyTasks.length - 2;
              final task = dailyTasks[dailyIndex];
              task['completed'] = task['completed'] ?? false;
              
              return ListTile(
                onTap: () async {
                  setState((){
                    task['completed'] = !task['completed'];
                    });
                    await firestore.collection('users').doc(user.uid).update({
                     'hobbies.${widget.hobbyKey}.DailyTasks': dailyTasks,
                  });
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
          
        },
      ),
    );
  }
}
