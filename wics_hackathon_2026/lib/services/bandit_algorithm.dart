import 'dart:math';
import '../shared/app_data.dart';

class BanditService {
  static const double _explorationWeight = 1.4;

  Map<String, dynamic> normalizeStats({
    required List<Hobby> hobbies,
    required Map<String, dynamic> banditStats,
  }) {
    final normalized = <String, dynamic>{};

    for (final hobby in hobbies) {
      final raw = banditStats[hobby.name];
      if (raw is Map<String, dynamic>) {
        normalized[hobby.name] = {
          'pulls': _toInt(raw['pulls']),
          'reward': _toDouble(raw['reward']),
        };
      } else {
        normalized[hobby.name] = {'pulls': 0, 'reward': 0.0};
      }
    }

    return normalized;
  }

  Hobby pickRecommendation({
    required List<Hobby> hobbies,
    required Map<String, dynamic> banditStats,
  }) {
    if (hobbies.isEmpty) {
      throw Exception('Cannot pick a recommendation from an empty hobby list.');
    }

    final stats = normalizeStats(hobbies: hobbies, banditStats: banditStats);

    int totalPulls = 0;
    for (final hobby in hobbies) {
      final hobbyStats = Map<String, dynamic>.from(stats[hobby.name]);
      totalPulls += _toInt(hobbyStats['pulls']);
    }

    final untried = hobbies.where((h) {
      final hobbyStats = Map<String, dynamic>.from(stats[h.name]);
      return _toInt(hobbyStats['pulls']) == 0;
    }).toList();

    if (untried.isNotEmpty) {
      untried.sort((a, b) {
        final scoreA = _coldStartScore(a);
        final scoreB = _coldStartScore(b);
        return scoreB.compareTo(scoreA);
      });
      return untried.first;
    }

    Hobby bestHobby = hobbies.first;
    double bestScore = double.negativeInfinity;

    for (final hobby in hobbies) {
      final hobbyStats = Map<String, dynamic>.from(stats[hobby.name]);

      final pulls = _toInt(hobbyStats['pulls']);
      final reward = _toDouble(hobbyStats['reward']);

      final avgReward = pulls == 0 ? 0.0 : reward / pulls;
      final explorationBonus =
          _explorationWeight * sqrt(log(max(totalPulls, 1)) / pulls);

      final momentumBonus = _momentumScore(hobby);

      final finalScore = avgReward + explorationBonus + momentumBonus;

      if (finalScore > bestScore) {
        bestScore = finalScore;
        bestHobby = hobby;
      }
    }

    return bestHobby;
  }

  Map<String, dynamic> recordRecommendationOutcome({
    required List<Hobby> hobbies,
    required Map<String, dynamic> banditStats,
    required String recommendedHobbyName,
    required String chosenHobbyName,
  }) {
    final updated = normalizeStats(hobbies: hobbies, banditStats: banditStats);

    if (recommendedHobbyName == chosenHobbyName) {
      _applyReward(
        stats: updated,
        hobbyName: recommendedHobbyName,
        reward: 1.0,
      );
    } else {
      _applyReward(
        stats: updated,
        hobbyName: recommendedHobbyName,
        reward: 0.0,
      );

      _applyReward(stats: updated, hobbyName: chosenHobbyName, reward: 0.35);
    }

    return updated;
  }
  
  Map<String, dynamic> rewardHobby({
    required List<Hobby> hobbies,
    required Map<String, dynamic> banditStats,
    required String hobbyName,
    required double reward,
  }) {
    final updated = normalizeStats(hobbies: hobbies, banditStats: banditStats);
    _applyReward(stats: updated, hobbyName: hobbyName, reward: reward);
    return updated;
  }

  bool isUntried({
    required String hobbyName,
    required Map<String, dynamic> banditStats,
  }) {
    final hobbyStats = banditStats[hobbyName];
    if (hobbyStats is! Map<String, dynamic>) return true;
    return _toInt(hobbyStats['pulls']) == 0;
  }

  double averageReward({
    required String hobbyName,
    required Map<String, dynamic> banditStats,
  }) {
    final hobbyStats = banditStats[hobbyName];
    if (hobbyStats is! Map<String, dynamic>) return 0.0;

    final pulls = _toInt(hobbyStats['pulls']);
    final reward = _toDouble(hobbyStats['reward']);

    if (pulls == 0) return 0.0;
    return reward / pulls;
  }

  void _applyReward({
    required Map<String, dynamic> stats,
    required String hobbyName,
    required double reward,
  }) {
    final current = Map<String, dynamic>.from(
      (stats[hobbyName] as Map<String, dynamic>? ??
          {'pulls': 0, 'reward': 0.0}),
    );

    final pulls = _toInt(current['pulls']) + 1;
    final totalReward = _toDouble(current['reward']) + reward;

    stats[hobbyName] = {'pulls': pulls, 'reward': totalReward};
  }

  double _coldStartScore(Hobby hobby) {
    return (hobby.progress * 0.7) + (min(hobby.level / 10.0, 1.0) * 0.3);
  }

  double _momentumScore(Hobby hobby) {
    final progressBoost = hobby.progress * 0.12;
    final levelBoost = min(hobby.level / 10.0, 1.0) * 0.08;
    return progressBoost + levelBoost;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return 0.0;
  }
}
