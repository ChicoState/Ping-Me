import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'authentication/firebase_options.dart';
import 'package:pingme/authentication/login.dart';

// CSCI 430: pingme
// Names: Jorge Munoz, Cole Hopkins, Crispin Gutierrez, Braulio Viveros

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
