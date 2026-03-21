import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String hobbyKey;
  const ProfilePage({super.key, required this.hobbyKey});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
    );
  }
}