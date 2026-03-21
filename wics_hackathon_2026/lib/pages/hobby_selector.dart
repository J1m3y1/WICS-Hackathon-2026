import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wics_hackathon_2026/main_navigation.dart';
import 'package:wics_hackathon_2026/pages/profile_screen.dart';
import 'package:wics_hackathon_2026/services/auth.dart';
import '../../shared/app_data.dart';
import '../../shared/app_theme.dart';

class HobbyPage extends StatefulWidget {
  const HobbyPage({super.key});

  @override
  State<HobbyPage> createState() => _HobbyPageState();
}

class _HobbyPageState extends State<HobbyPage> {
  String selectedFilter = 'All';

  final List<String> filters = ['All', 'Creative', 'Relax', 'Level Up'];
  final CollectionReference users = FirebaseFirestore.instance.collection("users");
  late Stream<List<Hobby>> _hobbyStream;

  @override
  void initState() {
    super.initState();
    // 2. Initialize the stream once
    final user = Auth().currentUser;
    if (user != null) {
      _hobbyStream = getUserHobbies(user.uid);
    }
  }

  Stream<List<Hobby>> getUserHobbies(String userID) {
    return users.doc(userID).snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      final hobbiesMap = data['hobbies'] as Map<String, dynamic>? ?? {};

      return hobbiesMap.entries.map((entry) {
        final hobbyData = entry.value as Map<String, dynamic>? ?? {};
        final info = hobbyData['info'] as Map<String, dynamic>? ?? {};
        return Hobby.fromMap(info, hobbyData);
      }).toList();
    });
  }


  List<Hobby> applyFilter(List<Hobby> hobbies) {
    switch (selectedFilter) {
      case 'Creative':
        return hobbies
            .where((hobby) => hobby.name == 'Guitar' || hobby.name == 'Cooking')
            .toList();
      case 'Relax':
        return hobbies.where((hobby) => hobby.name == 'Reading').toList();
      case 'Level Up':
        return hobbies.where((hobby) => hobby.progress >= 0.75).toList();
      case 'All':
      default:
        return hobbies;
    }
  }

  Hobby getRecommendedHobby(List<Hobby> hobbies) {
    if (hobbies.isEmpty) {
      throw Exception("No hobbies available to recommend");
   }

    final sorted = [...hobbies];

    sorted.sort((a, b) {
      final aScore = _recommendationScore(a);
      final bScore = _recommendationScore(b);
      return bScore.compareTo(aScore);
    });

    return sorted.first;
  }

  double _recommendationScore(Hobby hobby) {
    double score = 0;

    score += hobby.progress * 100;
    score += hobby.level * 4;

    if (hobby.progress >= 0.75) {
      score += 20;
    }

    if (hobby.progress >= 0.90) {
      score += 10;
    }

    return score;
  }

  String getRecommendationReason(Hobby hobby) {
    if (hobby.progress >= 0.85) {
      return 'You are extremely close to leveling up. A short session now could feel the most rewarding.';
    } else if (hobby.progress >= 0.70) {
      return 'You already have strong momentum here. This is a great hobby to continue for a happiness boost.';
    } else if (hobby.progress >= 0.50) {
      return 'This hobby has good progress already, so returning to it can help you feel productive without much friction.';
    } else {
      return 'This could be a refreshing hobby to revisit and build momentum with today.';
    }
  }

  String getRecommendationTag(Hobby hobby) {
    if (hobby.progress >= 0.85) return 'Almost There';
    if (hobby.progress >= 0.70) return 'Strong Momentum';
    if (hobby.progress >= 0.50) return 'Steady Growth';
    return 'Fresh Restart';
  }

  IconData getFilterIcon(String filter) {
    switch (filter) {
      case 'Creative':
        return Icons.palette_outlined;
      case 'Relax':
        return Icons.self_improvement_outlined;
      case 'Quick Win':
        return Icons.bolt_outlined;
      case 'Level Up':
        return Icons.trending_up_outlined;
      case 'All':
      default:
        return Icons.grid_view_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Auth().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: StreamBuilder<List<Hobby>>(
            stream: _hobbyStream, 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting){
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final hobbies = snapshot.data ?? [];
              if (hobbies.isEmpty) {
                return const Center(child: Text('No hobbies found.'));
              }

              final filteredHobbies = applyFilter(hobbies);
              final recommendedHobby = getRecommendedHobby(filteredHobbies);

              return Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildHappinessCard(recommendedHobby),
                    const SizedBox(height: 16),
                    _buildFilterRow(),
                    const SizedBox(height: 18),
                    ...filteredHobbies.map(
                      (hobby) => GestureDetector(
                        onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MainNavigation(hobbyKey: hobby.name)),
                            );
                        },
                        child: _buildHobbyCard(hobby),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
            }
            )
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text('Hobby Lobby', style: AppTextStyles.pageTitle),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
        ),
      ],
    );
  }

  Widget _buildHappinessCard(Hobby hobby) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF5B5FEF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recommended: ${hobby.name}', style: AppTextStyles.heroTitle),
          const SizedBox(height: 10),
          Text(
            getRecommendationReason(hobby),
            style: AppTextStyles.body.copyWith(
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildInfoChip(
                Icons.local_fire_department_outlined,
                getRecommendationTag(hobby),
              ),
              _buildInfoChip(
                Icons.trending_up_outlined,
                '${(hobby.progress * 100).toInt()}% progress',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(text, style: AppTextStyles.chipText),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final bool isSelected = selectedFilter == filter;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = filter;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.chipBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(getFilterIcon(filter), size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    filter,
                    style: AppTextStyles.chipText.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHobbyCard(Hobby hobby) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainNavigation(hobbyKey: hobby.name)),
        );
      },
      child: Container(
        height: 230,
        margin: const EdgeInsets.only(bottom: 18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(hobby.imagePath, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.20),
                      Colors.black.withValues(alpha: 0.40),
                      Colors.black.withValues(alpha: 0.72),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.40),
                    width: 1.2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          'Level ${hobby.level}',
                          style: AppTextStyles.badgeText.copyWith(fontSize: 12),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      hobby.name,
                      style: AppTextStyles.cardTitle.copyWith(
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hobby.currentRank,
                            style: AppTextStyles.subText.copyWith(
                              color: Colors.white.withValues(alpha: 0.82),
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hobby.nextRank,
                            textAlign: TextAlign.right,
                            style: AppTextStyles.subText.copyWith(
                              color: Colors.white.withValues(alpha: 0.82),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: hobby.progress,
                        minHeight: 12,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'XP: ${hobby.xp} / ${hobby.maxXp}',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
