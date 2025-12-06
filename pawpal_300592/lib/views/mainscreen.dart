import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal_300592/models/pet.dart'; // NEW
import 'package:pawpal_300592/models/user.dart';
import 'package:pawpal_300592/myconfig.dart';
import 'package:pawpal_300592/views/loginpage.dart';
import 'package:pawpal_300592/views/submitpetscreen.dart'; // NEW
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  final User? user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Lecturer's style variables
  late double screenWidth;
  List<Pet> myPetList = [];
  // Mandatory: Status for empty/loading state
  String status = "Loading your submissions...";

  @override
  void initState() {
    super.initState();
    _loadMyPets();
  }

  // Mandatory: Function to load user-specific data from API
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

    // Mandatory: Check !mounted before setState
    if (!mounted) return;

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
        // Mandatory: Map JSON data to model list
        myPetList = List<Pet>.from(
          jsonResponse['data'].map((x) => Pet.fromJson(x)),
        );
        setState(() {
          // If successful, update the list
        });
      } else {
        setState(() {
          // Mandatory: "No submissions yet." message
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

  // Existing logout function (Mandatory to keep)
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

  // Function to navigate to submission page and refresh on return
  void _navigateAndSubmit() async {
    if (widget.user?.userId == '0') {
      ScaffoldMessenger.of(context).showSnackBar(
        _getSnackBar('Please log in to submit a pet.', Colors.red),
      );
      return;
    }

    // Push the new screen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmitPetScreen(user: widget.user),
      ),
    );
    // Refresh the list after returning
    _loadMyPets();
  }

  SnackBar _getSnackBar(String message, Color color) {
    return SnackBar(content: Text(message), backgroundColor: color);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    // Mandatory: Adaptive UI limiting max width
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
          width: screenWidth, // Apply width limit
          child: myPetList.isEmpty
              ? Center(
                  // Show status/empty message
                  child: Text(status, style: const TextStyle(fontSize: 18)),
                )
              : ListView.builder(
                  itemCount: myPetList.length,
                  itemBuilder: (context, index) {
                    Pet pet = myPetList[index];

                    // Decode image paths (Stored as a JSON string in DB)
                    List<String> imagePaths;
                    try {
                      // Mandatory: Handle JSON decoding for image_paths
                      imagePaths = List<String>.from(
                        jsonDecode(pet.imagePaths ?? '[]'),
                      );
                    } catch (e) {
                      imagePaths = [];
                    }

                    // Mandatory: Show a card for each pet
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: ListTile(
                        // Mandatory: First image as thumbnail (using Image.network with MyConfig.baseUrl)
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

                        // Mandatory: Pet name and Category
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
                            // Mandatory: Description excerpt
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
      // Mandatory: Floating action button for submission
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateAndSubmit,
        label: const Text('Submit Pet'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
