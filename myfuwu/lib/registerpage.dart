import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late double height, width;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    print(width);
    if (width > 600) {
      width = 600;
    } else {
      width = width;
    }
    return Scaffold(
      appBar: AppBar(title: Text('Register Page')),
      body: Center(child: Column(
        children: [
          Padding(
            padding:const EdgeInsets.all(16.0),
            child: Image.asset('assets/images/myfuwu.png', scale: 1),
          ),
          SizedBox(height: 20),
          TextField(),
          TextField(),
          TextField(),
          Row(children: [
            Text('Remember Me'),
            Checkbox(value: false, onChanged: (value) {})
          ],),
          ElevatedButton(onPressed: () {}, child: Text('Register')),
          Text('Already have an account? Login'),
          Text('Forgot Password? Reset')
        ],
      )),
    );
  }
}