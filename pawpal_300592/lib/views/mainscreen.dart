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
    final response = await http.get(
      Uri.parse(
        '${MyConfig.baseUrl}/pawpal/api/get_my_pets.php?user_id=${widget.user.userId}',
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
                                  "${MyConfig.baseUrl}/pawpal/${imagePaths[0]}",
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
    );
  }
}
