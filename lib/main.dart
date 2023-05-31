// ignore_for_file: prefer_const_constructors

import 'package:chat/auth/class/controller.dart';
import 'package:chat/auth/phone_login.dart';
import 'package:chat/auth/usercheck.dart';
import 'package:chat/screen/mainpage.dart';
import 'package:chat/utils/keyboard_dismiss.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'utils/loader.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', 'High Importance Notifications',
    importance: Importance.high, playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up :  ${message.messageId}');
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  await FirebaseMessaging.instance.getInitialMessage();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  MyApp({super.key});

  // This widget is the root of the application.
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DismissKeyboard(
      child: MaterialApp(
          theme: ThemeData(
            appBarTheme: AppBarTheme(
              titleTextStyle: TextStyle(fontFamily: 'RaleWay'),
            ),
            textTheme: TextTheme(
              bodyText1: GoogleFonts.openSans(),
              bodyText2: GoogleFonts.openSans(),
            ),
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: Color(0xFFFDCEDF),
            ),
          ),
          debugShowCheckedModeBanner: false,
          title: 'Flutter Chat',
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
          ),
    );
  }
}
