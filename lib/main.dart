// ignore_for_file: prefer_const_constructors

import 'package:chat/auth/class/controller.dart';
import 'package:chat/auth/phone_login.dart';
import 'package:chat/auth/usercheck.dart';
import 'package:chat/screen/mainpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'utils/loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            titleTextStyle: TextStyle(fontFamily: 'RaleWay'),
          ),
          textTheme: TextTheme(
            bodyText1: GoogleFonts.ubuntu(),
            bodyText2: GoogleFonts.ubuntu(),
          ),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.pink.shade200,
          ),
        ),
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        home: ref.watch(userDataAuthProvider).when(
            data: (user) {
              print("user");
              print(auth.currentUser);
              if (auth.currentUser == null) {
                return MyPhone();
              }
              return MainPage();
            },
            error: (error, trace) {
              return Container();
            },
            loading: () => const Loader())
        // const UserCheck(),
        );
  }
}
