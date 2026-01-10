import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal_300592/models/pet.dart';
import 'package:pawpal_300592/models/user.dart';
import 'package:pawpal_300592/myconfig.dart';
import 'package:pawpal_300592/views/loginpage.dart';
import 'package:pawpal_300592/views/submitpetscreen.dart';
import 'package:pawpal_300592/shared/mydrawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPetScreen extends StatefulWidget {
  final User? user;
  const MyPetScreen({super.key, required this.user});

  @override
  State<MyPetScreen> createState() => _MyPetScreenState();
}

class _MyPetScreenState extends State<MyPetScreen> {
  late double screenWidth, screenHeight;
  List<Pet> myPetList = [];
  String status = "Loading your submissions...";

  int numofpage = 1;
  int curpage = 1;

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
        setState(() {
          status = "";
        });
      } else {
        setState(() {
          status = "No submissions yet.";
          myPetList = [];
        });
      }
    } else {
      setState(() {
        status = "Failed to load data from server.";
      });
    }
  }

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

  void _navigateAndSubmit() async {
    if (widget.user?.userId == '0') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to submit.'),
          backgroundColor: Colors.red,
        ),
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

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    final contentWidth = screenWidth > 900 ? 900.0 : screenWidth;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      drawer: MyDrawer(user: widget.user),
      appBar: buildModernAppBar(),
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: RefreshIndicator(
            onRefresh: () async => _loadMyPets(),
            child: Column(
              children: [
                Expanded(
                  child: myPetList.isEmpty
                      ? _buildEmptyState()
                      : _buildPetList(),
                ),
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 4, 53, 159),
        onPressed: _navigateAndSubmit,
        label: const Text('New Pet', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  AppBar buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF1F3C88),
      foregroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "PawPal",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            "Your Pets at your fingertips",
            style: TextStyle(fontSize: 11, color: Colors.white70),
          ),
        ],
      ),
      actions: [
        _buildAppBarIcon(
          icon: Icons.logout,
          onTap: widget.user?.userId != '0' ? _logout : () {},
          tooltip: "Logout",
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAppBarIcon({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }

  Widget _buildPetList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: myPetList.length,
      itemBuilder: (context, index) {
        Pet pet = myPetList[index];
        List<String> imagePaths = [];
        try {
          imagePaths = List<String>.from(jsonDecode(pet.imagePaths ?? '[]'));
        } catch (e) {
          imagePaths = [];
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.shade100,
                    child: imagePaths.isNotEmpty
                        ? Image.network(
                            '${MyConfig.baseUrl}/${imagePaths[0]}',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.pets, color: Colors.grey),
                          )
                        : const Icon(Icons.pets, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              pet.petName ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F3C88),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _confirmDelete(pet),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${pet.petType} • ${pet.category}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey.shade400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.wc, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            pet.petGender ?? 'N/A',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.cake_outlined,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${pet.petAge} old",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deletePet(String petId) {
    http
        .post(
          Uri.parse("${MyConfig.baseUrl}/pawpal/api/delete_pet.php"),
          body: {"pet_id": petId, "user_id": widget.user!.userId.toString()},
        )
        .then((response) {
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            if (data['status'] == 'success') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Pet deleted successfully")),
              );
              _loadMyPets(); // Refresh the list
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Failed to delete pet")),
              );
            }
          }
        })
        .catchError((error) {
          debugPrint("Delete error: $error");
        });
  }

  void _confirmDelete(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Listing?"),
        content: Text(
          "Are you sure you want to remove ${pet.petName}? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deletePet(pet.petId!); // Call the delete function
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            status,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
