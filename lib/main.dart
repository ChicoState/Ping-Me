import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'authentication/firebase_options.dart';
import 'package:pingme/authentication/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// CSCI 430: pingme
// Names: Jorge Munoz, Crispin Gutierrez, Cole Hopkins, Braulio Viveros
// ~TODO(mvp): Get a home page with google maps intigration.
// ~TODO: Bottom menu bar to navigate between pages
// TODO: Friends page
// TODO: location plugin
// TODO: ????

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

// This widget is the root of your application.
class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'PingMe',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            // Setting the color for all Text widgets
            textTheme:
                const TextTheme(bodyText2: TextStyle(color: Colors.white))),
        home: const LoginPage());
  }
}
