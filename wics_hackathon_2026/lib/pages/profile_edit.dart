import 'package:flutter/material.dart';
import '../shared/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentBio;

  const EditProfileScreen({super.key,required this.currentName, required this.currentBio, });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController bioController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    bioController = TextEditingController(text: widget.currentBio);
  }

  void saveProfile() {
    Navigator.pop(context, {
      "name": nameController.text,
      "bio": bioController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, AppColors.card, AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
      ), 
      child: SafeArea(
        child:ListView(
          padding:const EdgeInsets.fromLTRB(20,16,20,28),
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                
                  child:IconButton(
                  onPressed: () => Navigator.pop(context), 
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                ),
              ),
            const Spacer(), 
            const Text("Edit Profile", style: AppTextStyles.pageTitle,textAlign: TextAlign.center),
            const Spacer(), 
            const SizedBox(width: 40),
            ],
          ),

          const SizedBox(height: 30),
          const Center(
             child: CircleAvatar(
              radius: 60, 
              backgroundColor: Color(0xFF7C4DFF),
              child: Icon(Icons.person),
             ),
           ),
           const SizedBox(height: 20),
           const Center(
             child: Text("Change Profile Picture", style: AppTextStyles.body),
           ),
          const SizedBox(height: 40),
          TextField(
            controller: nameController,
            cursorColor: const Color(0xFF7C4DFF),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Username", labelStyle: TextStyle(color: Colors.white70),
              filled: true, fillColor: AppColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color:AppColors.border),
              ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: AppColors.primary),

              )
            ),
          ),
           const SizedBox(height: 40),
          TextField(
            controller: bioController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Bio", labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color:AppColors.border),
              ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: AppColors.primary),  
              )
            ),
          ),
          
          const SizedBox(height: 40),
          SizedBox(
            height:58,
            child: ElevatedButton(
              onPressed:saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text("Save", style: AppTextStyles.badgeText,)
            ),
          )
            ]
          ),
        ),
      ),
    );
  }
}