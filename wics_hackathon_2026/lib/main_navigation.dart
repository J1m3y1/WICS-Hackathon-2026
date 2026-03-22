import 'package:flutter/material.dart';
import 'package:wics_hackathon_2026/pages/community_feed.dart';
import 'package:wics_hackathon_2026/pages/home.dart';
import 'package:wics_hackathon_2026/shared/app_theme.dart';

class MainNavigation extends StatefulWidget {
  final String hobbyKey;
  const MainNavigation({super.key, required this.hobbyKey});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int myIndex = 0;
  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      HomePage(hobbyKey: widget.hobbyKey),
      CommunityFeed(hobbyKey: widget.hobbyKey),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: screens[myIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.card,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: AppTextStyles.chipText.copyWith(fontSize: 12),
          unselectedLabelStyle: AppTextStyles.chipText.copyWith(fontSize: 12),
          currentIndex: myIndex,
          onTap: (index) {
            setState(() {
              myIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.feed_rounded),
              activeIcon: Icon(Icons.feed_rounded),
              label: 'Feed',
            ),
          ],
        ),
      ),
    );
  }
}
