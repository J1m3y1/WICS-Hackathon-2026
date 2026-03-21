import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../shared/app_theme.dart';
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

  Widget _buildProfileCard() {
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
              child: Icon(Icons.person, size: 42, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 14),
          const Text("Cardini Panini", style: AppTextStyles.cardTitle),
          const SizedBox(height: 6),
          const Text("He Tries", style: AppTextStyles.body),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: const [
              _StatChip(label: "Level 9"),
              _StatChip(label: "3 Active Hobbies"),
              _StatChip(label: "0 Day Streak"),
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
                const Text("Your Identity", style: AppTextStyles.sectionTitle),
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
                          switch (index) {
                            case 0:
                              return const RadarChartTitle(text: 'Creativity');
                            case 1:
                              return const RadarChartTitle(text: 'Discipline');
                            case 2:
                              return const RadarChartTitle(text: 'Focus');
                            case 3:
                              return const RadarChartTitle(text: 'Strategy');
                            case 4:
                              return const RadarChartTitle(text: 'Consist.');
                            default:
                              return const RadarChartTitle(text: '');
                          }
                        },
                        dataSets: [
                          RadarDataSet(
                            fillColor: AppColors.primary.withAlpha(80),
                            borderColor: AppColors.primary,
                            entryRadius: 3,
                            dataEntries: const [
                              RadarEntry(value: 80),
                              RadarEntry(value: 65),
                              RadarEntry(value: 75),
                              RadarEntry(value: 50),
                              RadarEntry(value: 90),
                            ],
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
        onPressed: () {},
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
