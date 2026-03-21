import 'package:flutter/material.dart';

class HobbyTask {
  final String title;
  final String hobby;
  final String frequency;
  bool isCompleted;

  HobbyTask({
    required this.title,
    required this.hobby,
    required this.frequency,
    this.isCompleted = false,
  });
}

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPage();
}

class _TasksPage extends State<TasksPage> {
  final List<HobbyTask> tasks = [
    HobbyTask(
      title: 'Sketch for 10 minutes',
      hobby: 'Drawing',
      frequency: 'Daily',
    ),
    HobbyTask(
      title: 'Practice shading',
      hobby: 'Drawing',
      frequency: 'Daily',
    ),
    HobbyTask(
      title: 'Finish one small drawing',
      hobby: 'Drawing',
      frequency: 'Weekly',
    ),
    HobbyTask(
      title: 'Read 10 pages',
      hobby: 'Reading',
      frequency: 'Daily',
    ),
    HobbyTask(
      title: 'Write down one quote',
      hobby: 'Reading',
      frequency: 'Daily',
    ),
    HobbyTask(
      title: 'Finish one chapter',
      hobby: 'Reading',
      frequency: 'Weekly',
    ),
    HobbyTask(
      title: 'Stretch for 10 minutes',
      hobby: 'Gym',
      frequency: 'Daily',
    ),
    HobbyTask(
      title: 'Complete 3 workouts',
      hobby: 'Gym',
      frequency: 'Weekly',
    ),
  ];

  void toggleTask(int index, bool? value) {
    if (value == null) return;

    setState(() {
      tasks[index].isCompleted = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final incompleteTasks = tasks.where((task) => !task.isCompleted).toList();
    final completedTasks = tasks.where((task) => task.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              '${incompleteTasks.length} tasks left',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            ...incompleteTasks.map((task) {
              final index = tasks.indexOf(task);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) => toggleTask(index, value),
                  ),
                  title: Text(task.title),
                  subtitle: Text('${task.hobby} • ${task.frequency}'),
                ),
              );
            }),

            if (completedTasks.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Completed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),

              ...completedTasks.map((task) {
                final index = tasks.indexOf(task);

                return Card(
                  color: Colors.grey[100],
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) => toggleTask(index, value),
                    ),
                    title: Text(
                      task.title,
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                    subtitle: Text(
                      '${task.hobby} • ${task.frequency}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}