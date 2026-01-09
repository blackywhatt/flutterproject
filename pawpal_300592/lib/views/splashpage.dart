import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pawpal_300592/models/user.dart';
import 'package:pawpal_300592/myconfig.dart';
import 'package:pawpal_300592/views/mainscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _autoLogin();
  }

  void _autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? remember = prefs.getBool('rememberMe');
    if (remember != null && remember) {
      String email = prefs.getString('email') ?? '';
      String password = prefs.getString('password') ?? '';
      if (email.isNotEmpty && password.isNotEmpty) {
        // Attempt login using stored credentials
        var response = await http.post(
          Uri.parse('${MyConfig.baseUrl}/pawpal/api/login_user.php'),
          body: {'email': email, 'password': password},
        );
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          if (data['success'] == true) {
            // build User model and navigate after short delay
            User user = User.fromJson(data['data']);
            await Future.delayed(const Duration(seconds: 2));
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen(user: user)),
            );
            return;
          }
        }
      }
    }
    // Otherwise, show splash for 2 seconds then go to Login
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Create a guest user object
    User guestUser = User(
      userId: "0",
      name: "Guest",
      email: "Not Logged In",
      // Add other fields from your User model as empty strings if needed
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(user: guestUser)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/pawpal.png', scale: 3.5),
            SizedBox(height: 10),
            Text(
              'PawPal',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
