import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wics_hackathon_2026/shared/app_theme.dart';

class CreatePostPage extends StatefulWidget {
  final String username;
  const CreatePostPage({super.key, required this.username});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  File? _selectedImage;
  String? _selectedHobby;
  int _level = 1;
  int _xp = 0;

  final List<String> _hobbies = [
    'Gym',
    'Guitar',
    'Painting',
    'Chess',
    'Running',
    'Cooking',
    'Reading',
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _submit() {
    if (_selectedImage == null || _selectedHobby == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a photo and select a hobby')),
      );
      return;
    }

    Navigator.pop(context, {
      'username': widget.username,
      'hobby': _selectedHobby,
      'level': _level,
      'xp': _xp,
      'imagePath': _selectedImage!.path,
      'isFile': true,
    });
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
        title: const Text('New Post', style: AppTextStyles.sectionTitle),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(
              'Share',
              style: AppTextStyles.badgeText.copyWith(color: AppColors.primary),
            ),
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

            const Text('Username', style: AppTextStyles.badgeText),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text('@${widget.username}', style: AppTextStyles.subText),
            ),

            const SizedBox(height: 20),
            const Text('Hobby', style: AppTextStyles.badgeText),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedHobby,
              hint: const Text('Select a hobby', style: AppTextStyles.subText),
              dropdownColor: AppColors.card,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.card,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
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
                  .map(
                    (h) => DropdownMenuItem(
                      value: h,
                      child: Text(h, style: AppTextStyles.body),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedHobby = val),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Level', style: AppTextStyles.badgeText),
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
            const Text('XP Earned', style: AppTextStyles.badgeText),
            const SizedBox(height: 8),
            TextFormField(
              keyboardType: TextInputType.number,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'e.g. 120',
                hintStyle: AppTextStyles.subText,
                filled: true,
                fillColor: AppColors.card,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
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
