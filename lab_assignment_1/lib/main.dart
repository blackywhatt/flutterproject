//entry point of the Flutter app
import 'package:flutter/material.dart';
import 'package:lab_assignment_1/splashpage.dart';

void main() {
  //the main() function is the starting point of every Flutter app.
  runApp(const SavingGoalTrackerApp());
}

//root widget of the app
class SavingGoalTrackerApp extends StatelessWidget {
  const SavingGoalTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    //materialApp provides the overall structure, theme, and navigation.
    return MaterialApp(
      //define global app theme
      theme: ThemeData(
        useMaterial3: true, //enables UI components
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 249, 0, 145)), // base color theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 249, 0, 149), // AppBar background color
          foregroundColor: Colors.white, // AppBar text/icon color
        ),
      ),
      //the first screen displayed when the app starts
      home: const SplashPage(),
    );
  }
}
