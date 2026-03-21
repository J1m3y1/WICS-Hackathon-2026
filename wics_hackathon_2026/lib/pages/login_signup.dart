import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wics_hackathon_2026/main_navigation.dart';
import 'package:wics_hackathon_2026/services/auth.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final CollectionReference users = FirebaseFirestore.instance.collection(
    "users",
  );
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerRePassword = TextEditingController();

  //Calls from "auth.dart" to verify and if successful it updates local state to change to main navigation screen
  Future<void> signInWithEmailPassword() async {
    try {
      await Auth().signInWithEmailPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      setState(() {
        isLogin = true;
        errorMessage = '';
      });

      _controllerEmail.clear();
      _controllerPassword.clear();

      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => MainNavigation()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }
  //Calls from "auth.dart" to create a user, saves to firebase, and switches to login view.
  Future<void> createUserWithEmailPassword() async {
    final email = _controllerEmail.text.trim();
    final password = _controllerPassword.text.trim();
    final repassword = _controllerRePassword.text.trim();

    if (password != repassword) {
      setState(() {
        errorMessage = 'Passwords do not match!';
      });
      return;
    }

    try {
      UserCredential userCredential = await Auth().createUserWithEmailPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'role': 'user',
      });

      _controllerEmail.clear();
      _controllerPassword.clear();
      _controllerRePassword.clear();

      setState(() {
        isLogin = true;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Account created, Login.")));
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _entryField(
    String title,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: title,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : '$errorMessage');
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLogin
            ? signInWithEmailPassword
            : createUserWithEmailPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          isLogin ? 'Login' : 'Register',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(
        isLogin ? 'Register Instead' : 'Login Instead',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.only(
          right: 32,
          top: 128,
          bottom: 128,
          left: 32,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              isLogin ? 'Login' : 'SignUp',
              style: const TextStyle(fontSize: 32, color: Colors.white),
            ),
            const SizedBox(height: 32),
            _entryField('Email', _controllerEmail, isPassword: false),
            const SizedBox(height: 4),
            _entryField('Password', _controllerPassword, isPassword: true),
            const SizedBox(height: 4),
            if (!isLogin)
              _entryField(
                'ReEnter Password',
                _controllerRePassword,
                isPassword: true,
              ),
            if (!isLogin) const SizedBox(height: 4),
            _errorMessage(),
            const SizedBox(height: 12),
            _submitButton(),
            _loginOrRegisterButton(),
          ],
        ),
      ),
    );
  }
}
