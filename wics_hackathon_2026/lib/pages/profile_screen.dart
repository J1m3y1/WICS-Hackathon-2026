import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wics_hackathon_2026/pages/login_signup.dart';
import 'package:wics_hackathon_2026/services/auth.dart';
import '../shared/app_theme.dart';
import '../shared/app_data.dart';
import '../shared/setting_buttons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.background,
              AppColors.card,
              AppColors.background,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _buildTopBar(),
              const SizedBox(height: 20),
              _buildProfileCard(),
              const SizedBox(height: 24),
              _buildSectionTitle("Account"),
              const SizedBox(height: 12),
              SettingTile(
                icon: Icons.person_outline_rounded,
                title: "Edit Profile",
                subtitle: "Update your username, bio, and profile photo",
                onTap: () {},
              ),
              SettingTile(
                icon: Icons.lock_outline_rounded,
                title: "Change Password",
                subtitle: "Update your password for account security",
                onTap: () {},
              ),
              SettingTile(
                icon: Icons.email_outlined,
                title: "Email Preferences",
                subtitle: "Manage email updates and reminders",
                onTap: () {},
              ),
              const SizedBox(height: 18),
              _buildSectionTitle("App Settings"),
              const SizedBox(height: 12),
              SettingTile(
                icon: Icons.notifications_none_rounded,
                title: "Notifications",
                subtitle: "Daily reminders, streak alerts, and XP updates",
                trailing: Switch(
                  value: notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      notificationsEnabled = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionTitle("Support"),
              const SizedBox(height: 12),
              SettingTile(
                icon: Icons.help_outline_rounded,
                title: "Help Center",
                subtitle: "No Help For You",
                onTap: () {},
              ),
              SettingTile(
                icon: Icons.feedback_outlined,
                title: "Send Feedback",
                subtitle: "Don't Speak To Us",
                onTap: () {},
              ),
              SettingTile(
                icon: Icons.info_outline_rounded,
                title: "About",
                subtitle: "Version 1.0.0",
                onTap: () {},
              ),
              const SizedBox(height: 24),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        const Text("Profile", style: AppTextStyles.pageTitle),
        const Spacer(),
        const SizedBox(width: 46),
      ],
    );
  }

  final List<String> _traitOrder = hobbyCategories;

  Stream<List<Hobby>> _userHobbiesStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
          final data = doc.data();
          if (data == null) return <Hobby>[];

          final hobbiesMap = data['hobbies'] as Map<String, dynamic>? ?? {};

          return hobbiesMap.entries.map((entry) {
            final hobbyData = Map<String, dynamic>.from(entry.value);
            final info = Map<String, dynamic>.from(hobbyData['info'] ?? {});
            final merged = {...info, ...hobbyData};
            return Hobby.fromMap(entry.key, merged);
          }).toList();
        });
  }

  Map<String, double> _calculateCategoryScores(List<Hobby> hobbies) {
    final scores = {for (final trait in _traitOrder) trait: 0.0};

    for (final hobby in hobbies) {
      if (scores.containsKey(hobby.category)) {
        scores[hobby.category] = scores[hobby.category]! + 1.0;
      }
    }

    return scores;
  }

  String _getIdentityLabel(Map<String, double> scores) {
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top = sorted.first;

    if (top.value == 0) return 'New Explorer';

    switch (top.key) {
      case 'Creativity':
        return 'Creative Explorer';
      case 'Discipline':
        return 'Driven Builder';
      case 'Focus':
        return 'Deep Thinker';
      case 'Strategy':
        return 'Strategic Mind';
      case 'Consistency':
        return 'Steady Achiever';
      default:
        return 'Balanced Hobbyist';
    }
  }

  String _getIdentityDescription(Map<String, double> scores) {
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top = sorted.first;

    if (top.value == 0) {
      return 'Choose hobbies to start building your hobby identity.';
    }

    return 'Most of your hobbies fall under ${top.key.toLowerCase()}, so that is the strongest part of your current hobby identity.';
  }

  Widget _buildProfileCard() {
    return StreamBuilder<List<Hobby>>(
      stream: _userHobbiesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [AppColors.card, AppColors.card],
              ),
              border: Border.all(color: AppColors.border, width: 1.3),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final hobbies = snapshot.data ?? [];
        final scores = _calculateCategoryScores(hobbies);
        final identityLabel = _getIdentityLabel(scores);
        final identityDescription = _getIdentityDescription(scores);
        final totalLevel = hobbies.fold<int>(
          0,
          (sum, hobby) => sum + hobby.level,
        );

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(colors: [AppColors.card, AppColors.card]),
            border: Border.all(color: AppColors.border, width: 1.3),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withAlpha(40), blurRadius: 20),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                  ),
                ),
                child: const CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.card,
                  child: Icon(
                    Icons.person,
                    size: 42,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text("Cardini Panini", style: AppTextStyles.cardTitle),
              const SizedBox(height: 6),
              Text(identityLabel, style: AppTextStyles.body),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _StatChip(label: "Level $totalLevel"),
                  _StatChip(label: "${hobbies.length} Active Hobbies"),
                  const _StatChip(label: "0 Day Streak"),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.chipBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(identityLabel, style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 8),
                    Text(
                      identityDescription,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subText,
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        height: 230,
                        child: RadarChart(
                          RadarChartData(
                            radarShape: RadarShape.polygon,
                            tickCount: 5,
                            ticksTextStyle: const TextStyle(
                              color: Colors.transparent,
                            ),
                            tickBorderData: const BorderSide(
                              color: AppColors.border,
                            ),
                            gridBorderData: const BorderSide(
                              color: AppColors.border,
                            ),
                            titleTextStyle: AppTextStyles.subText.copyWith(
                              fontSize: 12,
                            ),
                            getTitle: (index, angle) {
                              return RadarChartTitle(text: _traitOrder[index]);
                            },
                            dataSets: [
                              RadarDataSet(
                                fillColor: AppColors.primary.withAlpha(80),
                                borderColor: AppColors.primary,
                                entryRadius: 3,
                                dataEntries: _traitOrder
                                    .map(
                                      (trait) =>
                                          RadarEntry(value: scores[trait] ?? 0),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.sectionTitle.copyWith(
          fontSize: 14,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      height: 58,
      child: ElevatedButton.icon(
        onPressed: () async {
          try {
            await Auth().signOut();
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to sign out. Try again.')),
            );
          }
        },
        icon: const Icon(Icons.logout_rounded, color: AppColors.textPrimary),
        label: const Text("Log Out", style: AppTextStyles.badgeText),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  const _StatChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: AppTextStyles.chipText),
    );
  }
}
