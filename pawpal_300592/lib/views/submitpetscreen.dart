import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // Required for Web Images
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pawpal_300592/models/user.dart';
import 'package:pawpal_300592/myconfig.dart';

class SubmitPetScreen extends StatefulWidget {
  final User? user;
  const SubmitPetScreen({super.key, required this.user});

  @override
  State<SubmitPetScreen> createState() => _SubmitPetScreenState();
}

class _SubmitPetScreenState extends State<SubmitPetScreen> {
  // Controllers
  TextEditingController petNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  // Dropdown Data
  List<String> petTypes = ['Cat', 'Dog', 'Rabbit', 'Other'];
  List<String> categories = ['Adoption', 'Donation Request', 'Help/Rescue'];
  String? selectedPetType;
  String? selectedCategory;

  // Location Data
  String lat = "";
  String lng = "";

  // Image Data
  List<File> mobileImages = [];
  List<Uint8List> webImages = [];
  final picker = ImagePicker();

  late double screenWidth;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      screenWidth = 600;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Submit New Pet')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: screenWidth,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // --- IMAGE PICKER SECTION (Max 3) ---
                  GestureDetector(
                    onTap: () {
                      int currentCount = kIsWeb
                          ? webImages.length
                          : mobileImages.length;
                      if (currentCount < 3) {
                        if (kIsWeb) {
                          openGallery();
                        } else {
                          pickimagedialog();
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Maximum 3 images allowed"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: screenWidth,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Tap to add images (${kIsWeb ? webImages.length : mobileImages.length}/3)",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // --- IMAGE PREVIEW GRID ---
                  if ((kIsWeb && webImages.isNotEmpty) ||
                      (!kIsWeb && mobileImages.isNotEmpty))
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: kIsWeb
                            ? webImages.length
                            : mobileImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: kIsWeb
                                      ? Image.memory(
                                          webImages[index],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          mobileImages[index],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (kIsWeb) {
                                          webImages.removeAt(index);
                                        } else {
                                          mobileImages.removeAt(index);
                                        }
                                      });
                                    },
                                    child: const Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 10),

                  // --- FORM FIELDS ---
                  // Pet Name Field with Icon
                  TextField(
                    controller: petNameController,
                    decoration: const InputDecoration(
                      labelText: 'Pet Name',
                      prefixIcon: Icon(Icons.pets),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      // Pet Type Dropdown with Icon and Null Value Handling
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Pet Type',
                            prefixIcon: const Icon(Icons.category),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          value: selectedPetType,
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text("Please choose"),
                            ),
                            ...petTypes.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ],
                          onChanged: (newValue) =>
                              setState(() => selectedPetType = newValue),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Category Dropdown with Icon and Null Value Handling
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            prefixIcon: const Icon(Icons.list_alt),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          value: selectedCategory,
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text("Please choose"),
                            ),
                            ...categories.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ],
                          onChanged: (newValue) =>
                              setState(() => selectedCategory = newValue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Description Field with Icon
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Min 10 chars)',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),

                  // --- LOCATION DISPLAY ---
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.location_on, color: Colors.blueGrey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Location:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(lat.isEmpty ? "Locating..." : "$lat, $lng"),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _determinePosition,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- SUBMIT BUTTON ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      minimumSize: Size(screenWidth, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      showSubmitDialog();
                    },
                    child: const Text(
                      'Submit Pet',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- IMAGE PICKING LOGIC ---
  void pickimagedialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  openCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  openGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> openCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      if (kIsWeb) {
        var bytes = await pickedFile.readAsBytes();
        setState(() {
          webImages.add(bytes);
        });
      } else {
        setState(() {
          mobileImages.add(File(pickedFile.path));
        });
      }
    }
  }

  Future<void> openGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        var bytes = await pickedFile.readAsBytes();
        setState(() {
          webImages.add(bytes);
        });
      } else {
        setState(() {
          mobileImages.add(File(pickedFile.path));
        });
      }
    }
  }

  // --- GEOLOCATION LOGIC ---
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, do nothing
        return;
      }
    }

    // When we reach here, permissions are granted and we can get the position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      lat = position.latitude.toString();
      lng = position.longitude.toString();
    });
  }

  // --- SUBMIT DIALOG & LOGIC (Updated Validation) ---
  void showSubmitDialog() {
    // 1. Validation
    if (petNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter Pet Name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (selectedPetType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please choose a Pet Type"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please choose a Category"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (descriptionController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Description must be at least 10 chars"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (lat.isEmpty || lng.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location not found. Refreshing..."),
          backgroundColor: Colors.red,
        ),
      );
      _determinePosition();
      return;
    }
    // Check images based on platform
    if (kIsWeb && webImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least 1 image"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!kIsWeb && mobileImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least 1 image"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Confirmation Dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Submit Pet'),
          content: const Text('Are you sure you want to submit this pet?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                submitPet();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void submitPet() {
    // Show Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    String petname = petNameController.text.trim();
    String description = descriptionController.text.trim();

    // Prepare Map
    Map<String, String> body = {
      'user_id': widget.user!.userId.toString(),
      'pet_name': petname,
      'pet_type': selectedPetType!,
      'category': selectedCategory!,
      'description': description,
      'lat': lat,
      'lng': lng,
    };

    // Encode Images (Loop max 3)
    if (kIsWeb) {
      for (int i = 0; i < webImages.length; i++) {
        body['image_${i + 1}'] = base64Encode(webImages[i]);
      }
    } else {
      for (int i = 0; i < mobileImages.length; i++) {
        body['image_${i + 1}'] = base64Encode(
          mobileImages[i].readAsBytesSync(),
        );
      }
    }

    http
        .post(
          Uri.parse('${MyConfig.baseUrl}/pawpal/api/submit_pet.php'),
          body: body,
        )
        .then((response) {
          if (!mounted) return;
          Navigator.pop(context); // Close Loading

          // 💻 LOGGING THE RESPONSE TO DEBUG CONSOLE
          print("--- HTTP POST Response ---");
          print("URL: ${MyConfig.baseUrl}/pawpal/api/submit_pet.php");
          print("Status Code: ${response.statusCode}");
          print("Body (Raw JSON): ${response.body}");
          print("--------------------------");

          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);

            // 🔍 LOGGING PARSED JSON STATUS
            print("Parsed JSON Status: ${jsonResponse['status']}");

            if (jsonResponse['status'] == 'success') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Pet submitted successfully"),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context); // Go back to Home
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(jsonResponse['message']),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Server Error: ${response.statusCode}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        })
        .catchError((e) {
          if (!mounted) return;
          Navigator.pop(context);
          // ⚠️ LOGGING ERROR
          print("HTTP Request Error: $e");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
          );
        });
  }
}
