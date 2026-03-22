import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wics_hackathon_2026/shared/app_theme.dart';
import 'package:wics_hackathon_2026/services/auth.dart';

class CreatePostPage extends StatefulWidget {
  final String username;
  final String hobbyKey;
  const CreatePostPage({super.key, required this.username, required this.hobbyKey});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  File? _selectedImage;
  int _level = 1;
  int _xp = 0;
  bool _isUploading = false;
  bool _isLoadingLevel = true;

  static const Color _accentColor = Color(0xFFC47A20);

  @override
  void initState() {
    super.initState();
    _xp = Random().nextInt(11) + 10; 
    _fetchCurrentLevel();
  }

  Future<void> _fetchCurrentLevel() async {
    try {
      final user = Auth().currentUser;
      if(user != null) {
        final doc = await FirebaseFirestore.instance.collection('hobbies').doc(user.uid).get();

        if(doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          final hobbyData = data[widget.hobbyKey] as Map<String, dynamic>?;
          final currentLevel = hobbyData?['info']?['level'];

          if(currentLevel != null) {
            setState(() {
              _level = currentLevel;
              _isLoadingLevel = false;
            });
          }
        }
      } 
    } catch (e) {
      debugPrint("Error fetching level: $e");
    } finally {
      if(mounted) setState(() => _isLoadingLevel = false);
    }
    }
  

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _submit() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a photo first!')),
      );
      return; 
    }

    setState(() => _isUploading = true);

    try {
      final user = Auth().currentUser;
      if (user == null) throw Exception("User not logged in");

      final newPost = {
        'username': widget.username,
        'hobby': widget.hobbyKey,
        'level': _level,
        'xp': _xp,
        'timeAgo': "Just now",
        'imagePath': _selectedImage!.path,
        'isFile': true,
      };

      await FirebaseFirestore.instance.collection('posts').doc(user.uid).set({
        'post': {
          widget.hobbyKey: {
            'Post': FieldValue.arrayUnion([newPost])
          }
        }
      }, SetOptions(merge: true));

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Post',
          style: AppTextStyles.sectionTitle,
        ),
        actions: [
          _isUploading 
          ? const Center(child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ))
          : TextButton(
              onPressed: _submit,
              child: const Text('Share', style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.2),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to add photo',
                              style: AppTextStyles.subText,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Username',
              style: AppTextStyles.badgeText,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                '@${widget.username}',
                style: AppTextStyles.subText,
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Hobby',
              style: AppTextStyles.badgeText,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedHobby,
              hint: const Text(
                'Select a hobby',
                style: AppTextStyles.subText,
              ),
              dropdownColor: AppColors.card,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.card,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              items: _hobbies
                  .map((h) => DropdownMenuItem(
                        value: h,
                        child: Text(
                          h,
                          style: AppTextStyles.body,
                        ),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedHobby = val),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Level',
                  style: AppTextStyles.badgeText,
                ),
                Text(
                  'Lvl $_level',
                  style: AppTextStyles.badgeText.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: _level.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.progressBackground,
              onChanged: (val) => setState(() => _level = val.toInt()),
            ),

            const SizedBox(height: 20),
            const Text(
              'XP Earned',
              style: AppTextStyles.badgeText,
            ),
            const SizedBox(height: 8),
            TextFormField(
              keyboardType: TextInputType.number,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'e.g. 120',
                hintStyle: AppTextStyles.subText,
                filled: true,
                fillColor: AppColors.card,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              onChanged: (val) => setState(() => _xp = int.tryParse(val) ?? 0),
            ),
          ],
        ),
      ),
    );
  }
}