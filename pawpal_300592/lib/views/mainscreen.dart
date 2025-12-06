import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal_300592/models/pet.dart';
import 'package:pawpal_300592/models/user.dart';
import 'package:pawpal_300592/myconfig.dart';

class MainScreen extends StatefulWidget {
  final User user;
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
    // 💡 BEST PRACTICE: Added check for null/empty userId
    if (widget.user.userId == null ||
        widget.user.userId!.isEmpty ||
        widget.user.userId! == '0') {
      setState(() => status = "Error: User ID is missing or invalid.");
      return;
    }

    final response = await http.get(
      Uri.parse(
        '${MyConfig.baseUrl}/pawpal/api/get_my_pets.php?user_id=${widget.user.userId}',
      ),
    );

    if (!mounted) return;

    print("JSON Response (My Pets): ${response.body}");

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
        // 🏆 FIX 1: Replaced old List.from().map() with robust mapping (as requested)
        List<Pet> loadedPets = (jsonResponse['data'] as List)
            .map((item) => Pet.fromJson(item))
            .toList();

        setState(() {
          myPetList = loadedPets;
          status = myPetList.isEmpty ? "No submissions yet." : "Loaded.";
        });
      } else {
        setState(() {
          // 💡 Use server message if available
          status = jsonResponse['message'] ?? "No submissions yet.";
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

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) screenWidth = 600;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Submitted Pets'),
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth,
          child: myPetList.isEmpty
              ? Center(
                  child: Text(status, style: const TextStyle(fontSize: 18)),
                )
              : ListView.builder(
                  itemCount: myPetList.length,
                  itemBuilder: (context, index) {
                    final pet = myPetList[index];
                    final List<String> imagePaths = pet.imagePaths;

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
                                  // 🏆 FIX 2: Removed the extra '/' before 'pawpal/'
                                  // This prevents double slashes (//) in the URL.
                                  '${MyConfig.baseUrl}pawpal/${pet.imagePaths[0]}',

                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // 💡 Added print for debugging failed images
                                    print(
                                      "Image load failed for ${pet.petName}. URL: ${MyConfig.baseUrl}pawpal/${pet.imagePaths[0]}",
                                    );
                                    print("Error details: $error");
                                    return const Icon(
                                      Icons.pets,
                                      size: 40,
                                      color: Colors
                                          .red, // Use red to highlight the failure
                                    );
                                  },
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
    );
  }
}
