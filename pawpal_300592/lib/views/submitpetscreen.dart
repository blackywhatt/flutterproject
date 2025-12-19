import 'dart:convert';
import 'dart:io';
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
  final _formKey = GlobalKey<FormState>();

  // Controllers
  TextEditingController petNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  // Dropdown Selections
  List<String> petTypes = ['Cat', 'Dog', 'Rabbit', 'Other'];
  List<String> categories = ['Adoption', 'Donation Request', 'Help/Rescue'];
  String? selectedPetType;
  String? selectedCategory;

  // Location Variables
  String lat = "";
  String lng = "";
  String locStatus = "Fetching location...";

  // Image Variables
  File? _image1, _image2, _image3;
  final picker = ImagePicker();

  late double screenHeight, screenWidth;

  @override
  void initState() {
    super.initState();
    _determinePosition(); // Automatically get location on load
  }

  // ---------------------------------------------------------
  // LOCATION LOGIC (FIXED)
  // ---------------------------------------------------------
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    setState(() => locStatus = "Checking GPS...");

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => locStatus = "GPS is disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => locStatus = "Permission denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => locStatus = "Permission permanently denied.");
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        lat = position.latitude.toString();
        lng = position.longitude.toString();
        locStatus = "Location Locked";
      });
    } catch (e) {
      setState(() => locStatus = "Error: $e");
    }
  }

  // ---------------------------------------------------------
  // IMAGE SELECTION LOGIC
  // ---------------------------------------------------------
  Future<void> _selectImage(int index) async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 1200,
      maxWidth: 1200,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        if (index == 1) _image1 = File(pickedFile.path);
        if (index == 2) _image2 = File(pickedFile.path);
        if (index == 3) _image3 = File(pickedFile.path);
      });
    }
  }

  // ---------------------------------------------------------
  // SUBMISSION LOGIC (FIXED LOCATION PASSING)
  // ---------------------------------------------------------
  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_image1 == null) {
      _showMessage("Please upload the primary image.");
      return;
    }
    if (lat.isEmpty || lng.isEmpty) {
      _showMessage("Cannot submit without location. Please wait for GPS.");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Uploading data..."),
          ],
        ),
      ),
    );

    String base64Image1 = base64Encode(_image1!.readAsBytesSync());
    String base64Image2 = _image2 != null
        ? base64Encode(_image2!.readAsBytesSync())
        : "";
    String base64Image3 = _image3 != null
        ? base64Encode(_image3!.readAsBytesSync())
        : "";

    // IMPORTANT: Ensure keys match your submit_pet.php exactly
    var body = {
      "user_id": widget.user!.userId.toString(),
      "pet_name": petNameController.text,
      "pet_type": selectedPetType!,
      "category": selectedCategory!,
      "description": descriptionController.text,
      "lat": lat,
      "lng": lng,
      "image_1": base64Image1,
      "image_2": base64Image2,
      "image_3": base64Image3,
    };

    http
        .post(
          Uri.parse("${MyConfig.baseUrl}/pawpal/api/submit_pet.php"),
          body: body,
        )
        .then((response) {
          Navigator.pop(context); // Close loading dialog

          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            if (data['status'] == 'success') {
              _showMessage("Pet submitted successfully!");
              Navigator.pop(context); // Return to previous screen
            } else {
              _showMessage("Server Error: ${data['message']}");
            }
          } else {
            _showMessage("Network Error: ${response.statusCode}");
          }
        })
        .catchError((e) {
          Navigator.pop(context);
          _showMessage("Error: $e");
        });
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------------------------------------------------
  // UI BUILDER
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("Register New Pet")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Add Pet Photos (Max 3)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _imageBox(1, _image1),
                    _imageBox(2, _image2),
                    _imageBox(3, _image3),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: petNameController,
                  decoration: const InputDecoration(
                    labelText: "Pet Name",
                    prefixIcon: Icon(Icons.pets),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? "Please enter pet name" : null,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedPetType,
                  decoration: const InputDecoration(
                    labelText: "Pet Type",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: petTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedPetType = v),
                  validator: (v) => v == null ? "Select type" : null,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: "Listing Category",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label),
                  ),
                  items: categories
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedCategory = v),
                  validator: (v) => v == null ? "Select category" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "Pet Description",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? "Please describe the pet" : null,
                ),
                const SizedBox(height: 20),

                // Location Status Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueGrey),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location, color: Colors.blueGrey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Current Status: $locStatus",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (lat.isNotEmpty)
                              Text(
                                "Coordinates: $lat, $lng",
                                style: const TextStyle(fontSize: 12),
                              ),
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

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _onSave,
                    child: const Text(
                      "SUBMIT PET",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageBox(int index, File? img) {
    return GestureDetector(
      onTap: () => _selectImage(index),
      child: Container(
        height: screenWidth * 0.28,
        width: screenWidth * 0.28,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: img == null
            ? const Icon(Icons.add_a_photo, size: 30, color: Colors.grey)
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(img, fit: BoxFit.cover),
              ),
      ),
    );
  }
}
