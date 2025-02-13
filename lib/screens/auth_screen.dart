import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_management/models/color.dart';
import 'task_list_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLogin = true;

  void authenticate() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      if (isLogin) {
        await auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        await auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TaskListScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? "Login" : "Sign Up", style: TextStyle(color: Colors.white),),
      backgroundColor: AppColors.bgColor1,),
      backgroundColor: AppColors.bgColor2,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email',
                floatingLabelStyle: TextStyle(color: Colors.black),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Bottom line black when focused
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // Bottom line grey when not focused
                ),
              ),
          cursorColor: Colors.black,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password',
                floatingLabelStyle: TextStyle(color: Colors.black),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Bottom line black when focused
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // Bottom line grey when not focused
                ),
              ),
              cursorColor: Colors.black,
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: authenticate,
              child: Text(isLogin ? "Login" : "Sign Up", style: TextStyle(color: Colors.black),),
              style:ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppColors.bgColor3),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(isLogin ? "Create an account" : "Already have an account? Login", style: TextStyle(color: Colors.black),),
            ),
          ],
        ),
      ),
    );
  }
}
