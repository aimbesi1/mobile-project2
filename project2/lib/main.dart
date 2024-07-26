import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project2/auth.dart';
import 'package:project2/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project2/homepage.dart';
import 'package:project2/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'real-estate-project-5a668',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(RealEstateApp());
}

class RealEstateApp extends StatefulWidget {
  @override
  _RealEstateAppState createState() => _RealEstateAppState();
}

class _RealEstateAppState extends State<RealEstateApp> {
  ThemeData _theme = AppTheme.lightTheme;

  void updateTheme(String themeName) {
    setState(() {
      _theme = themeName == 'light' ? AppTheme.lightTheme : AppTheme.darkTheme;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String themeName = prefs.getString('theme') ?? 'light';
    updateTheme(themeName);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real Estate Time',
      theme: _theme,
      initialRoute: '/',
      routes: {
        '/': (context) {
          final FirebaseAuth auth = FirebaseAuth.instance;
          auth.idTokenChanges().listen((event) {});
          if (auth.currentUser == null) {
            return const LoginForm();
          } else {
            return const HomePage();
          }
        },
        '/auth': (context) => const LoginForm(),
        '/home': (context) => const HomePage(),
        '/settings': (context) => SettingsScreen(updateTheme: updateTheme),
      },
    );
  }
}