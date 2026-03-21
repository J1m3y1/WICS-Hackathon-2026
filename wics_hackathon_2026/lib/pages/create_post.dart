import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  static const Color _accentColor = Color(0xFFC47A20);

  final List<String> _hobbies = [
    'Gym', 'Guitar', 'Painting', 'Chess', 'Running', 'Cooking', 'Reading'
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

    // Return the new post data back to the feed
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Post',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(
              'Share',
              style: TextStyle(
                color: _accentColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                // aspectRatio: 1,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEDE9DF), width: 1.5),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text('Tap to add photo',
                              style: TextStyle(color: Colors.grey[400])),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Username (auto-filled, read only)
            const Text('Username',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('@${widget.username}',
                  style: const TextStyle(color: Colors.grey)),
            ),

            const SizedBox(height: 20),

            // Hobby dropdown
            const Text('Hobby',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedHobby,
              hint: const Text('Select a hobby'),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEDE9DF)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEDE9DF)),
                ),
              ),
              items: _hobbies
                  .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedHobby = val),
            ),

            const SizedBox(height: 20),

            // Level slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Level',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text('Lvl $_level',
                    style: TextStyle(
                        color: _accentColor, fontWeight: FontWeight.w700)),
              ],
            ),
            Slider(
              value: _level.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: _accentColor,
              onChanged: (val) => setState(() => _level = val.toInt()),
            ),

            const SizedBox(height: 20),

            // XP input
            const Text('XP Earned',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 120',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEDE9DF)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEDE9DF)),
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