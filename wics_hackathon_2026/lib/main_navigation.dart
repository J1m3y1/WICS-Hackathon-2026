import 'package:flutter/material.dart';
import 'package:wics_hackathon_2026/pages/home.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int myIndex = 0;
  final screens = [HomePage(),];

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        body: screens[myIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: myIndex,
          onTap: (index) {
            setState(() {
              myIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.task),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: '+',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.collections),
              label: 'Collection',
            ),
          ],
        ),
      );
    }
}

