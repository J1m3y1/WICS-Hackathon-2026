import 'package:flutter/material.dart';
import 'create_post.dart';
import 'dart:io';
import 'package:wics_hackathon_2026/shared/app_theme.dart';

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

class CommunityFeed extends StatefulWidget {
  final String hobbyKey;
  const CommunityFeed({super.key, required this.hobbyKey});

  @override
  State<CommunityFeed> createState() => _CommunityFeedState();
}

class _CommunityFeedState extends State<CommunityFeed> {
  late List<HobbyPost> _posts;

  @override
  void initState() {
    super.initState();
    _posts = List.from(samplePosts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
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
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text('Community', style: AppTextStyles.pageTitle),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                itemCount: _posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _PostCard(post: _posts[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final HobbyPost post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1 / 1,
            child: post.isFile
                ? Image.file(File(post.imagePath!), fit: BoxFit.cover)
                : Image.asset(post.imagePath!, fit: BoxFit.cover),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 15),
                    children: [
                      TextSpan(
                        text: '@${post.username} ',
                        style: AppTextStyles.subText,
                      ),
                      const TextSpan(
                        text: 'completed ',
                        style: AppTextStyles.subText,
                      ),
                      TextSpan(
                        text: '${post.hobby} · Lvl ${post.level}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  '${post.timeAgo} · +${post.xp} XP',
                  style: AppTextStyles.subText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CommunityFeed(hobbyKey: ''),
    ),
  );
}
