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
  });

  factory Hobby.fromMap(Map<String, dynamic> data) {
    return Hobby(
      name: data['name'] ?? '',
      level: data['level'] ?? 0,
      progress: (data['progress'] ?? 0.0).toDouble(),
      xp: data['xp'] ?? 0,
      maxXp: data['maxXp'] ?? 0,
      currentRank: data['currentRank'] ?? '',
      nextRank: data['nextRank'] ?? '',
      imagePath: data['imagePath'] ?? '',
      category: data['category'] ?? 'Focus',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'level': level,
      'progress': progress,
      'xp': xp,
      'maxXp': maxXp,
      'currentRank': currentRank,
      'nextRank': nextRank,
      'imagePath': imagePath,
      'category': category,
    };
  }
}

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
};

class TaskItem {
  final String title;
  final int xpReward;
  final bool isCompleted;

  TaskItem({
    required this.title,
    required this.xpReward,
    this.isCompleted = false,
  });
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