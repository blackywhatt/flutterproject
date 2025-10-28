//displays a splash screen with app logo and title for 2 seconds before navigating to the HomeScreen.
import 'package:flutter/material.dart';
import 'package:lab_assignment_1/homescreen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    //wait for 2 seconds, then automatically navigate to HomeScreen
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return; // prevents navigation if widget is disposed
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    //scaffold provides page structure with a body section
    return Scaffold(
      body: Center(
        //column centers all widgets vertically
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //display the splash image (app logo)
            Image.asset('assets/images/savingtracker.png', scale: 2),
            const SizedBox(height: 10),
            //app title under the logo
            const Text(
              'Saving Goal Tracker',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            //loading spinner (just for visual feedback)
            const CircularProgressIndicator(),

            const SizedBox(height: 20),

            //small text shown under the progress indicator
            const Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
