import 'package:chat/auth/phone_login.dart';
import 'package:chat/screen/mainpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserCheck extends StatelessWidget {
  const UserCheck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print('has data');
            return MainPage();
          } else {
            print('no data');
            return const MyPhone();
          }
        },
      ),
    );
  }
}
