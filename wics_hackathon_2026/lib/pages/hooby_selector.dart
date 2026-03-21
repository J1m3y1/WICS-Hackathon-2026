import 'package:flutter/material.dart';
import 'package:wics_hackathon_2026/main_navigation.dart';

class HobbyPage extends StatefulWidget {
  const HobbyPage({super.key});

  @override
  State<HobbyPage> createState() => _HobbyPage();
}

class _HobbyPage extends State<HobbyPage> {
  final Map<String,String> hobbies = {'Gym': 'lib/images/gym.jpg', 'Tennis': 'lib/images/tennis.png', 'Soccer': 'lib/images/soccer.jpg', 'Boxing': 'lib/images/boxing.jpg', 'Picketball': 'lib/images/picketball.jpg', 'Gaming': 'lib/images/gaming.jpg',};
  
  Widget _hobbyBoxes() {
    return SizedBox(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Wrap(
          children: hobbies.entries.map((entry) {
            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainNavigation()),
                );
                },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                side: BorderSide.none,
                backgroundColor: Colors.cyanAccent
              ), 
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    entry.value,
                    height: 200,
                    width: 200,
                  ),
                  SizedBox(height: 25),
                  Text(entry.key)
                ],
              ));
          }).toList(),
        ),
      ),
    );
  }

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome back!'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _hobbyBoxes(),
            )
            )
        ],
      ),
    );
  }
}