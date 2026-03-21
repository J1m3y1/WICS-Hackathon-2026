import 'package:flutter/material.dart';
import 'create_post.dart';
import 'dart:io';

// Data Model

class HobbyPost {
  final String username;
  final String hobby;
  final int level;
  final int xp;
  final String timeAgo;
  final String? imagePath;
  final bool isFile;

  const HobbyPost({
    required this.username,
    required this.hobby,
    required this.level,
    required this.xp,
    required this.timeAgo,
    this.imagePath,
    this.isFile = false,
  });
}

// Sample Data

final List<HobbyPost> samplePosts = [
  HobbyPost(
    username: 'alex',
    hobby: 'Gym',
    level: 5,
    xp: 80,
    timeAgo: '2 min ago',
    imagePath: 'assets/images/gympost.avif',
  ),
  HobbyPost(
    username: 'mia',
    hobby: 'Guitar',
    level: 2,
    xp: 40,
    timeAgo: '18 min ago',
    imagePath: 'assets/images/guitar.jpg',
  ),
  HobbyPost(
    username: 'jordan',
    hobby: 'Painting',
    level: 3,
    xp: 60,
    timeAgo: '45 min ago',
    imagePath: 'assets/images/painting.webp',
  ),
  HobbyPost(
    username: 'sam',
    hobby: 'Chess',
    level: 7,
    xp: 120,
    timeAgo: '1 hr ago',
    imagePath: 'assets/images/chess.avif',
  ),
];

// Main Widget

class CommunityFeed extends StatefulWidget {
  final String hobbyKey;
  const CommunityFeed({super.key, required this.hobbyKey});

  @override
  State<CommunityFeed> createState() => _CommunityFeedState();
}


class _CommunityFeedState extends State<CommunityFeed> {
  late List<HobbyPost> _posts;

  static const Color _accentColor = Color(0xFFC47A20);
  static const Color _subtleText = Color(0xFFAAAAAA);
  static const Color _borderColor = Color(0xFFEDE9DF);

  @override
  void initState() {
    super.initState();
    _posts = List.from(samplePosts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: _accentColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreatePostPage(username: 'alex'),
            ),
          );
          if (result != null) {
            setState(() {
              _posts.insert(
                0,
                HobbyPost(
                  username: result['username'],
                  hobby: result['hobby'],
                  level: result['level'],
                  xp: result['xp'],
                  timeAgo: 'Just now',
                  imagePath: result['imagePath'],
                  isFile: true,
                ),
              );
            });
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                'Community',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // Feed
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: _posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _PostCard(
                    post: _posts[index],
                    accentColor: _accentColor,
                    subtleText: _subtleText,
                    borderColor: _borderColor,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Post Card
class _PostCard extends StatelessWidget {
  final HobbyPost post;
  final Color accentColor;
  final Color subtleText;
  final Color borderColor;

  const _PostCard({
    required this.post,
    required this.accentColor,
    required this.subtleText,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner image
          AspectRatio(
            aspectRatio: 1 / 1,
            child: post.isFile
                ? Image.file(File(post.imagePath!), fit: BoxFit.cover)
                : Image.asset(post.imagePath!, fit: BoxFit.cover),
          ),

          // Info row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username + hobby badge
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 15),
                    children: [
                      TextSpan(
                        text: '@${post.username} ',
                        style: TextStyle(
                          color: subtleText,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const TextSpan(
                        text: 'completed ',
                        style: TextStyle(color: Color(0xFFAAAAAA)),
                      ),
                      TextSpan(
                        text: '${post.hobby} · Lvl ${post.level}',
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // Time + XP
                Text(
                  '${post.timeAgo} · +${post.xp} XP',
                  style: TextStyle(
                    fontSize: 13,
                    color: subtleText,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Entry point

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CommunityFeed(hobbyKey: ''),
    ),
  );
}