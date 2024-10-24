import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/my_day.dart';
import 'package:todo_app/screen/login_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //usuario logeado o no 
          if(snapshot.hasData){
            return MyDayScreen();
          }
          else{
            return  LoginScreen();
          }
        },
        ),
    );
  }
}