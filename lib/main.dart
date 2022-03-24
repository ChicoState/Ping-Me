import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'authentication/firebase_options.dart';
import 'package:pingme/authentication/login.dart';

// CSCI 430: pingme
// Names: Jorge Munoz,

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
        title: 'pingme',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            // Setting the color for all Text widgets
            textTheme:
                const TextTheme(bodyText2: TextStyle(color: Colors.white))),
        home: StartupLogic().getLandingPage(context));
  }
}

// DUMMY HOME PAGE
class SuccessPage extends StatefulWidget {
  const SuccessPage({Key? key}) : super(key: key);
  @override
  State<SuccessPage> createState() => _SuccessPage();
}

class _SuccessPage extends State<SuccessPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _userEmail;

  @override
  void initState() {
    super.initState();
    _userEmail = _prefs.then((SharedPreferences prefs) {
      return (prefs.getString('userEmail') ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('pingme: Home Page'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You have successfully logged in!',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            // Getting userEmail from Shared Preferences
            FutureBuilder<String>(
                future: _userEmail,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const CircularProgressIndicator();
                    default:
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Your sign-in email: ${snapshot.data}',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.black),
                            ),
                          ],
                        );
                      }
                  }
                }),
            const SizedBox(height: 30),
            TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  setState(() {});
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()));
                },
                child: const Text('Log Out',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ))
          ],
        )));
        home: const LoginPage());
  }
}
