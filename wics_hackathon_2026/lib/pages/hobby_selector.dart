import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wics_hackathon_2026/main_navigation.dart';
import 'package:wics_hackathon_2026/pages/profile_screen.dart';
import 'package:wics_hackathon_2026/services/auth.dart';
import '../../shared/app_data.dart';
import '../../shared/app_theme.dart';
import '../services/bandit_algorithm.dart';

class HobbyPage extends StatefulWidget {
  const HobbyPage({super.key});

  @override
  State<HobbyPage> createState() => _HobbyPageState();
}

class _HobbyPageState extends State<HobbyPage> {
  String selectedFilter = 'All';

  final List<String> filters = ['All', 'Creative', 'Relax', 'Level Up'];
  final CollectionReference users = FirebaseFirestore.instance.collection(
    "users",
  );
  Stream<DocumentSnapshot>? _userStream;
  final BanditService _banditService = BanditService();

  @override
  void initState() {
    super.initState();
    final user = Auth().currentUser;
    if (user != null) {
      _userStream = users.doc(user.uid).snapshots();
    }
  }

  List<Hobby> applyFilter(List<Hobby> hobbies) {
    switch (selectedFilter) {
      case 'Creative':
        return hobbies
            .where((hobby) => hobby.category == 'Creativity')
            .toList();
      case 'Relax':
        return hobbies.where((hobby) => hobby.category == 'Focus').toList();
      case 'Level Up':
        return hobbies.where((hobby) => hobby.progress >= 0.75).toList();
      case 'All':
      default:
        return hobbies;
    }
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

  String getRecommendationReason(Hobby hobby) {
    if (hobby.progress >= 0.75) {
      return '${hobby.name} is a strong choice right now because you already have momentum in it.';
    } else if (hobby.level <= 2) {
      return '${hobby.name} is being suggested to help you build consistency in a newer hobby.';
    } else {
      return '${hobby.name} is being recommended because your activity suggests it has a good chance of boosting engagement.';
    }
  }

  String getRecommendationTag(Hobby hobby) {
    if (hobby.progress >= 0.75) {
      return 'High momentum';
    } else if (hobby.level <= 2) {
      return 'Growth pick';
    } else {
      return 'AI pick';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userStream == null) {
      return const Scaffold(
        body: Center(child: Text('No signed-in user found.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: StreamBuilder<DocumentSnapshot>(
            stream: _userStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final doc = snapshot.data;
              final data = doc?.data() as Map<String, dynamic>? ?? {};

              final hobbiesMap = data['hobbies'] as Map<String, dynamic>? ?? {};
              final banditStats = Map<String, dynamic>.from(
                data['banditStats'] ?? {},
              );
              final lastRecommendation = data['lastRecommendation'] as String?;

              final hobbies = hobbiesMap.entries.map((entry) {
                final hobbyData = entry.value as Map<String, dynamic>? ?? {};
                final info = hobbyData['info'] as Map<String, dynamic>? ?? {};
                final merged = {...info, ...hobbyData};
                return Hobby.fromMap(merged);
              }).toList();

              if (hobbies.isEmpty) {
                return const Center(child: Text('No hobbies found.'));
              }

              final filteredHobbies = applyFilter(hobbies);

              Hobby recommendedHobby;
              if (lastRecommendation != null &&
                  hobbies.any((h) => h.name == lastRecommendation)) {
                recommendedHobby = hobbies.firstWhere(
                  (h) => h.name == lastRecommendation,
                );
              } else {
                recommendedHobby = _banditService.pickRecommendation(
                  hobbies: hobbies,
                  banditStats: banditStats,
                );
              }

              if (lastRecommendation == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final user = Auth().currentUser;
                  if (user == null) return;

                  await users.doc(user.uid).set({
                    'lastRecommendation': recommendedHobby.name,
                  }, SetOptions(merge: true));
                });
              }

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
                            onTap: () async {
                              final user = Auth().currentUser;

                              if (user != null &&
                                  hobby.name == recommendedHobby.name) {
                                final updatedBanditStats = _banditService
                                    .rewardHobby(
                                      hobbies: hobbies,
                                      banditStats: banditStats,
                                      hobbyName: hobby.name,
                                      reward: 1.0,
                                    );

                                await users.doc(user.uid).set({
                                  'banditStats': updatedBanditStats,
                                  'lastRecommendation': null,
                                }, SetOptions(merge: true));
                              }

                              if (!context.mounted) return;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MainNavigation(hobbyKey: hobby.name),
                                ),
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
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text('HobbyUp', style: AppTextStyles.pageTitle),
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
    return Container(
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
    );
  }
}
