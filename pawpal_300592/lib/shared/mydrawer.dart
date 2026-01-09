import 'package:flutter/material.dart';
import 'package:pawpal_300592/models/user.dart';
import 'package:pawpal_300592/shared/animated_route.dart'; // 1. Import the animation
import 'package:pawpal_300592/views/loginpage.dart';
import 'package:pawpal_300592/views/mainscreen.dart';
import 'package:pawpal_300592/views/mydonationscreen.dart';
import 'package:pawpal_300592/views/mypetscreen.dart';
import 'package:pawpal_300592/views/profilepage.dart';
import 'package:pawpal_300592/views/settingpage.dart';

class MyDrawer extends StatefulWidget {
  final User? user;
  const MyDrawer({super.key, this.user});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1F3C88)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.user?.userId != "0" && widget.user?.name != null
                    ? widget.user!.name![0].toUpperCase()
                    : "G", // 'G' for Guest
                style: const TextStyle(
                  fontSize: 24,
                  color: Color(0xFF1F3C88),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            accountName: Text(
              widget.user?.userId == "0"
                  ? 'Guest User'
                  : (widget.user?.name ?? 'Guest'),
            ),
            accountEmail: Text(
              widget.user?.userId == "0"
                  ? 'Login to join the community'
                  : (widget.user?.email ?? ''),
            ),
          ),

          // HOME
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                AnimatedRoute.slideFromRight(
                  MainScreen(user: widget.user),
                ), // 2. Use animation
              ); // Close drawer
            },
          ),

          // MY SERVICES
          ListTile(
            leading: const Icon(Icons.pets_outlined),
            title: const Text('My Pets'),
            onTap: () {
              if (widget.user?.userId == '0' || widget.user == null) {
                Navigator.pop(context);
                _showLoginDialog(context); // Block guests from seeing "My Pets"
              } else {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  AnimatedRoute.slideFromRight(MyPetScreen(user: widget.user)),
                );
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.volunteer_activism_outlined),
            title: const Text('My Donations'),
            onTap: () {
              // Check if logged in
              if (widget.user?.userId == '0' || widget.user == null) {
                Navigator.pop(context);
                _showLoginDialog(context);
              } else {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  AnimatedRoute.slideFromRight(
                    MyDonationScreen(user: widget.user!), // Navigate to history
                  ),
                );
              }
            },
          ),

          // SETTINGS
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingPage(user: widget.user),
                ),
              );
            },
          ),

          // PROFILE
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              // 1. Check if the user is a guest ('0') or null
              if (widget.user?.userId == '0' ||
                  widget.user == null ||
                  widget.user?.userId == null) {
                Navigator.pop(context); // Close the drawer
                _showLoginDialog(context); // Ask them to login
              } else {
                // 2. If logged in, go to ProfilePage
                Navigator.pop(context); // Close the drawer

                // 3. Use the AnimatedRoute you just added!
                Navigator.pushReplacement(
                  context,
                  AnimatedRoute.slideFromRight(ProfilePage(user: widget.user!)),
                );
              }
            },
          ),

          // LOGOUT
          if (widget.user?.userId == '0')
            ListTile(
              leading: const Icon(Icons.login, color: Color(0xFF1F3C88)),
              title: const Text(
                'Login / Register',
                style: TextStyle(
                  color: Color(0xFF1F3C88),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  AnimatedRoute.slideFromRight(const LoginPage()),
                );
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),

          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Version 0.1b",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                // Navigate to Login and clear all screens
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Login Required"),
        content: const Text("Please login to access this feature."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F3C88),
            ),
            onPressed: () {
              Navigator.pop(context);
              // Using slide animation for login too!
              Navigator.push(
                context,
                AnimatedRoute.slideFromRight(const LoginPage()),
              );
            },
            child: const Text("Login", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
