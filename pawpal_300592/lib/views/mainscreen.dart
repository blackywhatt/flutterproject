import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal_300592/models/pet.dart';
import 'package:pawpal_300592/models/user.dart';
import 'package:pawpal_300592/myconfig.dart';
import 'package:pawpal_300592/views/loginpage.dart';
import 'package:pawpal_300592/views/submitpetscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  final User? user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late double screenWidth;
  List<Pet> myPetList = [];
  String status = "Loading your submissions...";

  @override
  void initState() {
    super.initState();
    _loadMyPets();
  }

  void _loadMyPets() async {
    if (widget.user == null || widget.user!.userId == '0') {
      if (!mounted) return;
      setState(() {
        status = "Please log in to view your submissions.";
      });
      return;
    }

    final response = await http.get(
      Uri.parse(
        '${MyConfig.baseUrl}/pawpal/api/get_my_pets.php?user_id=${widget.user!.userId}',
      ),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
        myPetList = List<Pet>.from(
          jsonResponse['data'].map((x) => Pet.fromJson(x)),
        );
        setState(() {});
      } else {
        setState(() {
          //"No submissions yet." message
          status = "No submissions yet.";
          myPetList = [];
        });
      }
    } else {
      setState(() {
        status =
            "Failed to load data from server. Status: ${response.statusCode}";
      });
    }
  }

  //logout function
  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool remember = prefs.getBool("rememberMe") ?? false;

    if (!remember) {
      await prefs.remove("email");
      await prefs.remove("password");
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  //navigate to submission page
  void _navigateAndSubmit() async {
    if (widget.user?.userId == '0') {
      ScaffoldMessenger.of(context).showSnackBar(
        _getSnackBar('Please log in to submit a pet.', Colors.red),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmitPetScreen(user: widget.user),
      ),
    );
    _loadMyPets();
  }

  SnackBar _getSnackBar(String message, Color color) {
    return SnackBar(content: Text(message), backgroundColor: color);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) screenWidth = 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PawPal Submissions (My Pets)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.user?.userId != '0' ? _logout : null,
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: screenWidth,
          child: myPetList.isEmpty
              ? Center(
                  child: Text(status, style: const TextStyle(fontSize: 18)),
                )
              : ListView.builder(
                  itemCount: myPetList.length,
                  itemBuilder: (context, index) {
                    Pet pet = myPetList[index];

                    List<String> imagePaths;
                    try {
                      imagePaths = List<String>.from(
                        jsonDecode(pet.imagePaths ?? '[]'),
                      );
                    } catch (e) {
                      imagePaths = [];
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: ListTile(
                        leading: imagePaths.isNotEmpty
                            ? SizedBox(
                                width: 70,
                                height: 70,
                                child: Image.network(
                                  '${MyConfig.baseUrl}/${imagePaths[0]}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.pets,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                ),
                              )
                            : const Icon(
                                Icons.pets,
                                size: 40,
                                color: Colors.grey,
                              ),

                        title: Text(
                          pet.petName ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Type: ${pet.petType ?? 'N/A'} - Category: ${pet.category ?? 'N/A'}',
                            ),
                            Text(
                              (pet.description?.length ?? 0) > 50
                                  ? '${pet.description!.substring(0, 50)}...'
                                  : pet.description ?? '',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateAndSubmit,
        label: const Text('Submit Pet'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
