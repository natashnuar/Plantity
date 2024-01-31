import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Plantity/utils.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'learn_more.dart';
import 'signup_page.dart';
import 'plantPage.dart';
import 'profilePage.dart';
import 'picture.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  tz.initializeTimeZones(); // Initialize time zones
  // Call this function to initialize time zones

  AwesomeNotifications().initialize(
    null, // null means you're using default settings
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic notifications',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
      ),
    ],
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const routeName = '/homePage';
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: Utils.messengerKey,
      title: 'Plantity',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: const MyHomePage(title: 'Register'),
      routes: {
        SignUpPageRoute.routeName: (_) => const SignUpPageRoute(),
        PlantPageRoute.routeName: (_) => const PlantPageRoute(),
        ProfilePageRoute.routeName: (_) => const ProfilePageRoute(),
        PicturePageRoute.routeName: (_) => const PicturePageRoute(),
        MyHomePageRoute.routeName: (_) => const MyHomePage(
              title: '',
            ),
        LearnMorePageRoute.routeName: (_) => const LearnMorePageRoute(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool isLoading = false;

  Future<void> _login() async {
    try {
      setState(() {
        isLoading = true;
      });

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      Navigator.pushNamed(context, PlantPageRoute.routeName);
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Incorrect Email or Password. \nPlease try again.";

      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        errorMessage = "Invalid email or password.";
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Login Error"),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.lightGreen,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: size.height * 0.05,
            ),
            const SizedBox(
              height: 65,
              child: Text(
                'Plantity',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            SizedBox(
              height: size.height * 0.3,
              width: size.width * 0.6,
              child: Center(
                child: Image.asset(
                  'images/plantity.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
              height: size.height * 0.7,
              width: size.width,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 70,
                    width: 300,
                    child: Center(
                      child: TextFormField(
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.green),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: 'Email',
                        ),
                        controller: email,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 70,
                    width: 300,
                    child: Center(
                      child: TextFormField(
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.green),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: 'Password',
                        ),
                        controller: password,
                        obscureText: true,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  Container(
                    height: 55,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.lightGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'LOG IN',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.black),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, SignUpPageRoute.routeName);
                        },
                        child: const Text(
                          "Sign up",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.2,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MyHomePageRoute extends StatelessWidget {
  static const routeName = 'MyHomePageRoute';

  const MyHomePageRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyHomePage(
      title: '',
    );
  }
}

class SignUpPageRoute extends StatelessWidget {
  static const routeName = 'SignUpPageRoute';

  const SignUpPageRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return const SignUpPage();
  }
}

class PlantPageRoute extends StatelessWidget {
  static const routeName = 'PlantPageRoute';

  const PlantPageRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlantPage();
  }
}

class ProfilePageRoute extends StatelessWidget {
  static const routeName = 'ProfilePageRoute';

  const ProfilePageRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfilePage();
  }
}

class PicturePageRoute extends StatelessWidget {
  static const routeName = 'PicturePageRoute';

  const PicturePageRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return PicturePage(
      onAddPlant: (Plant) {},
    );
  }
}

class LearnMorePageRoute extends StatelessWidget {
  static const routeName = 'LearnMorePageRoute';

  const LearnMorePageRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return LearnMorePage(
        arguments: LearnMoreArguments(
      imagePath: '',
      plantInfo: null,
      addPlant: (Plant) {},
    ));
  }
}
