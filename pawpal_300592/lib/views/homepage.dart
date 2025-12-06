import 'package:flutter/material.dart';
import 'package:pawpal_300592/models/user.dart';
import 'package:pawpal_300592/views/loginpage.dart';
import 'package:pawpal_300592/views/mainscreen.dart';
import 'package:pawpal_300592/views/submitpetscreen.dart';

class HomePage extends StatelessWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // limit width similar to other screens
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) screenWidth = 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'), // top-right / app bar title
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // White frame with welcome text at top‑middle
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 24,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome, ${user.name ?? 'User'}!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Make both buttons big and same width
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: const Icon(Icons.list),
                        label: const Text(
                          'Main Screen',
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MainScreen(user: user),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: const Icon(Icons.pets),
                        label: const Text(
                          'Pet Submission Form',
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SubmitPetScreen(user: user),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
