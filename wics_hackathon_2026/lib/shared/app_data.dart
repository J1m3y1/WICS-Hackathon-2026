class Hobby {
  final String name;
  final int level;
  final double progress;
  final int xp;
  final int maxXp;
  final String currentRank;
  final String nextRank;
  final String imagePath;

  Hobby({
    required this.name,
    required this.level,
    required this.progress,
    required this.xp,
    required this.maxXp,
    required this.currentRank,
    required this.nextRank,
    required this.imagePath,
  });

  factory Hobby.fromMap(Map<String, dynamic> infoMap, Map<String, dynamic>? hobbyData) {
    return Hobby(
      name: infoMap['name'] ?? '',
      level: infoMap['level'] ?? 0,
      progress: (infoMap['progress'] ?? 0.0).toDouble(),
      xp: infoMap['xp'] ?? 0,
      maxXp: infoMap['maxXp'] ?? 0,
      currentRank: infoMap['currentRank'] ?? '',
      nextRank: infoMap['nextRank'] ?? '',
      imagePath: infoMap['imagePath'] ?? '',
    );
  }
}


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