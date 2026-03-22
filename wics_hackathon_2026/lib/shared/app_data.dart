class TaskItem {
  final String title;
  final String description;
  final int xpReward;
  bool isCompleted;

  TaskItem({
    required this.title,
    this.description = '',
    this.xpReward = 10,
    this.isCompleted = false,
  });

  /// Factory to handle both Map objects (Guitar) and raw Strings (Gardening)
  factory TaskItem.fromMap(dynamic data) {
    if (data is String) {
      return TaskItem(
        title: data,
        description: 'No description available.',
      );
    } else if (data is Map) {
      return TaskItem(
        title: data['task'] ?? '',
        description: data['description'] ?? '',
        // You can add logic here to determine XP based on task type
        xpReward: 15, 
      );
    }
    return TaskItem(title: 'Unknown Task');
  }

  Map<String, dynamic> toMap() {
    return {
      'task': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }
}

/// Main Hobby model containing metadata and categorized task lists
class Hobby {
  final String name;
  final int level;
  final double progress;
  final int xp;
  final int maxXp;
  final String currentRank;
  final String nextRank;
  final String imagePath;
  final String category;
  
  // Tasks categorized by frequency
  final List<TaskItem> dailyTasks;
  final List<TaskItem> weeklyTasks;

  Hobby({
    required this.name,
    required this.level,
    required this.progress,
    required this.xp,
    required this.maxXp,
    required this.currentRank,
    required this.nextRank,
    required this.imagePath,
    required this.category,
    required this.dailyTasks,
    required this.weeklyTasks,
  });

  /// standardizes the hobby entry where the 'name' is the key in the JSON
  factory Hobby.fromMap(String hobbyName, Map<String, dynamic> data) {
    return Hobby(
      name: hobbyName,
      level: data['level'] ?? 1,
      progress: (data['progress'] ?? 0.0).toDouble(),
      xp: data['xp'] ?? 0,
      maxXp: data['maxXp'] ?? 100,
      currentRank: data['currentRank'] ?? 'Novice',
      nextRank: data['nextRank'] ?? 'Apprentice',
      imagePath: data['imagePath'] ?? 'assets/images/default_hobby.png',
      category: hobbyCategoryMap[hobbyName] ?? 'Focus',
      
      // Parse Daily Tasks
      dailyTasks: (data['daily'] as List? ?? [])
          .map((t) => TaskItem.fromMap(t))
          .toList(),
          
      // Parse Weekly Tasks
      weeklyTasks: (data['weekly'] as List? ?? [])
          .map((t) => TaskItem.fromMap(t))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'progress': progress,
      'xp': xp,
      'maxXp': maxXp,
      'currentRank': currentRank,
      'nextRank': nextRank,
      'imagePath': imagePath,
      'category': category,
      'daily': dailyTasks.map((t) => t.toMap()).toList(),
      'weekly': weeklyTasks.map((t) => t.toMap()).toList(),
    };
  }
}

// --- Configuration Constants ---

const List<String> hobbyCategories = [
  'Creativity',
  'Discipline',
  'Focus',
  'Strategy',
  'Consistency',
];

const Map<String, String> hobbyCategoryMap = {
  'Cooking': 'Creativity',
  'Guitar': 'Creativity',
  'Reading': 'Focus',
  'Gardening': 'Discipline',
};

// --- Helper for parsing the raw log output ---

List<Hobby> parseHobbiesFromLog(Map<String, dynamic> logData) {
  return logData.entries.map((entry) {
    return Hobby.fromMap(entry.key, entry.value as Map<String, dynamic>);
  }).toList();
}

class HobbyPost {
  final String username;
  final String hobby;
  final int level;
  final int xp;
  final String timeAgo;
  final String? imagePath;
  final bool isFile;

  const HobbyPost({
    required this.username,
    required this.hobby,
    required this.level,
    required this.xp,
    required this.timeAgo,
    this.imagePath,
    this.isFile = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'hobby': hobby,
      'level': level,
      'xp': xp,
      'timeAgo': timeAgo,
      'imagePath': imagePath,
      'isFile': isFile,
    };
  }

  factory HobbyPost.fromMap(Map<String, dynamic> map) {
    return HobbyPost(
      username: map['username'] ?? 'Anonymous',
      hobby: map['hobby'] ?? 'Unknown',
      level: (map['level'] as num?)?.toInt() ?? 0,
      xp: (map['xp'] as num?)?.toInt() ?? 0,
      timeAgo: map['timeAgo'] ?? '',
      imagePath: map['imagePath'],
      isFile: map['isFile'] ?? false,
    );
  }
}