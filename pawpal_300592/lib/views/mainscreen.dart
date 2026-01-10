import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal_300592/models/pet.dart';
import 'package:pawpal_300592/models/user.dart';
import 'package:pawpal_300592/views/petdetails.dart';
import 'package:pawpal_300592/myconfig.dart';
import 'package:pawpal_300592/shared/mydrawer.dart';

class MainScreen extends StatefulWidget {
  final User? user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Pet> publicPetList = [];
  String status = "Loading pets...";
  int numofpage = 1;
  int curpage = 1;
  final ScrollController _scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  String selectedType = "All";
  List<String> petTypes = ["All", "Cat", "Dog", "Rabbit", "Other"];

  @override
  void initState() {
    super.initState();
    _loadPublicPets();
  }

  void _loadPublicPets() async {
    setState(() => status = "Searching...");

    String typeParam = (selectedType == "All") ? "" : selectedType;

    String url =
        "${MyConfig.baseUrl}/pawpal/api/get_all_pets.php"
        "?search=${searchController.text}"
        "&type=$typeParam"
        "&pageno=$curpage";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            publicPetList = List<Pet>.from(
              data['data'].map((x) => Pet.fromJson(x)),
            );
            // Update total pages from server response
            numofpage = int.parse(data['numofpage'].toString());
            status = "";
          });
        } else {
          setState(() {
            publicPetList = [];
            numofpage = 1;
            status = "No pets found matching your criteria.";
          });
        }
      }
    } catch (e) {
      setState(() => status = "Error connecting to server.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PawPal Discover"),
        backgroundColor: const Color(0xFF1F3C88),
        foregroundColor: Colors.white,
      ),
      drawer: MyDrawer(user: widget.user),
      body: Column(
        children: [
          // SEARCH & FILTER SECTION
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search pet name...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onSubmitted: (_) {
                      setState(() => curpage = 1);
                      _loadPublicPets();
                    },
                  ),
                ),
                const SizedBox(width: 10),

                DropdownButton<String>(
                  value: selectedType,
                  items: petTypes.map((String type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                      curpage =
                          1; // Resets pagination so you don't get stuck on an empty page
                    });
                    _loadPublicPets();
                  },
                ),

                const SizedBox(width: 5),

                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.redAccent),
                  tooltip: "Clear All Filters",
                  onPressed: () {
                    setState(() {
                      searchController.clear();
                      selectedType = "All";
                      curpage = 1;
                    });
                    _loadPublicPets();
                  },
                ),
              ],
            ),
          ),

          // LIST OF PETS
          Expanded(
            child: publicPetList.isEmpty
                ? Center(child: Text(status))
                : GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: publicPetList.length,
                    itemBuilder: (context, index) {
                      Pet pet = publicPetList[index];

                      // Image handling
                      String imagePath = "";
                      try {
                        List<dynamic> images = jsonDecode(
                          pet.imagePaths ?? '[]',
                        );
                        if (images.isNotEmpty) imagePath = images[0];
                      } catch (e) {
                        debugPrint("Image Error: $e");
                      }

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PetDetails(pet: pet, user: widget.user),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. PET IMAGE
                              Expanded(
                                flex: 6, // Takes up 60% of card height
                                child: Stack(
                                  children: [
                                    Image.network(
                                      "${MyConfig.baseUrl}/$imagePath",
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.pets,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    // AGE TAG (Overlayed on image)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          pet.petAge ?? "N/A",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 2. PET DETAILS
                              Expanded(
                                flex: 4, // Takes up 40% of card height
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        pet.petName ?? "Unknown",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        "${pet.petType}",
                                        style: TextStyle(
                                          color: Colors.blueGrey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // CATEGORY BADGE
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF1F3C88,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        child: Text(
                                          pet.category ?? "General",
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F3C88),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      bottomNavigationBar: publicPetList.isNotEmpty
          ? Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 6,
                    color: Colors.black.withOpacity(0.08),
                  ),
                ],
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: numofpage,
                itemBuilder: (context, index) {
                  final isActive = (curpage - 1) == index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: isActive
                            ? const Color(0xFF1F3C88)
                            : Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          curpage = index + 1;
                          _loadPublicPets();
                        });

                        // Add this to jump back to the top of the list
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : null,
    );
  }
}
