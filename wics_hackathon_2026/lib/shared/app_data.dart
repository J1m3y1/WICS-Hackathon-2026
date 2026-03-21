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

