import 'package:flutter/material.dart';

class FeedPage extends StatefulWidget {
  final String hobbyKey;
  const FeedPage({super.key, required this.hobbyKey});

  @override
  State<FeedPage> createState() => _FeedPage();
}

class _FeedPage extends State<FeedPage> {
  

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed'),
      ),
      body: Column(
        children: [
          Container(
            
          ),
        ],
      )
    );
  }
}