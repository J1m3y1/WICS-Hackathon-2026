import 'package:flutter/material.dart';
import 'package:wics_hackathon_2026/pages/profile.dart';
import 'package:wics_hackathon_2026/pages/home.dart';
import 'package:wics_hackathon_2026/pages/feed.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int myIndex = 0;
  final screens = [HomePage(), FeedPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[myIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.cyan,
        currentIndex: myIndex,
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
