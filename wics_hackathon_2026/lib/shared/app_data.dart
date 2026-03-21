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

final List<Hobby> hobbiesList = [
  Hobby(
    name: 'Guitar',
    level: 6,
    progress: 0.75,
    xp: 1800,
    maxXp: 2000,
    currentRank: 'Advanced Strummer',
    nextRank: 'Master Strummer',
    imagePath: 'lib/images/gamescene1.jpg',
  ),
  Hobby(
    name: 'Reading',
    level: 4,
    progress: 0.60,
    xp: 200,
    maxXp: 300,
    currentRank: 'Novice Reader',
    nextRank: 'Intermediate Reader',
    imagePath: 'lib/images/gamescene2.jpg',
  ),
  Hobby(
    name: 'Cooking',
    level: 5,
    progress: 0.80,
    xp: 400,
    maxXp: 500,
    currentRank: 'Intermediate Cook',
    nextRank: 'Advanced Cook',
    imagePath: 'lib/images/gamescene1.jpg',
  ),
];
