import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wics_hackathon_2026/services/auth.dart';
import 'package:wics_hackathon_2026/shared/app_data.dart';
import 'create_post.dart';
import 'dart:io';
import 'package:wics_hackathon_2026/shared/app_theme.dart';



class CommunityFeed extends StatefulWidget {
  final String hobbyKey;
  const CommunityFeed({super.key, required this.hobbyKey});

  @override
  State<CommunityFeed> createState() => _CommunityFeedState();
}

class _CommunityFeedState extends State<CommunityFeed> {
  late Stream<List<HobbyPost>> _postStream;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static const Color _accentColor = Color(0xFFC47A20);
  static const Color _subtleText = Color(0xFFAAAAAA);
  static const Color _borderColor = Color(0xFFEDE9DF);

  @override
  void initState() {
    super.initState();
    final user = Auth().currentUser;
    if (user != null) {
      _postStream = getPostStream();
    }
  }
  
  Stream<List<HobbyPost>> getPostStream() {
  final user = Auth().currentUser;
  if (user == null) return Stream.value([]);

  return firestore.collection('posts').doc(user.uid).snapshots().map((snapshot) {
    if (!snapshot.exists) return [];
    
    final data = snapshot.data() as Map<String, dynamic>;
    
    final allHobbies = data['post'] as Map<String, dynamic>?;
    
    final specificHobby = allHobbies?[widget.hobbyKey] as Map<String, dynamic>?;
    
    final List<dynamic> rawPosts = specificHobby?['Post'] ?? [];

    return rawPosts
        .map((item) => HobbyPost.fromMap(item as Map<String, dynamic>))
        .where((post) => post.hobby == widget.hobbyKey) 
        .toList()
        .reversed 
        .toList();
  });
}
  

  @override
  Widget build(BuildContext context) {
    final user = Auth().currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreatePostPage(username: user?.displayName ?? "Anonymous",
                hobbyKey: widget.hobbyKey, ),
            ),
          );
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
              child: StreamBuilder<List<HobbyPost>>(
                stream: _postStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting){
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final posts = snapshot.data ??[];

                  if (posts.isEmpty) {
                    return const Center(child: Text('No posts yet.'));
                  }
                  
                  return ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: posts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _PostCard(
                        post: posts[index],
                      );
                    },
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

// Entry point

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CommunityFeed(hobbyKey: ''),
    ),
  );
}