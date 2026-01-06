import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pawpal_300592/models/user.dart';
import 'package:pawpal_300592/myconfig.dart';
import 'package:pawpal_300592/shared/mydrawer.dart';

class ProfilePage extends StatefulWidget {
  User user;
  ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  bool isLoading = false;
  File? _image; // To store the selected image file
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    nameController.text = widget.user.name ?? '';
    phoneController.text = widget.user.phone ?? '';
  }

  Future<void> _selectImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      _showSnackBar("Please fill in all fields", Colors.red);
      return;
    }

    setState(() => isLoading = true);

    // Convert image to base64 if a new one was picked
    String base64Image = "";
    if (_image != null) {
      base64Image = base64Encode(_image!.readAsBytesSync());
    }

    try {
      final response = await http.post(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/updateprofile.php'),
        body: {
          'user_id': widget.user.userId,
          'user_name': nameController.text,
          'user_phone': phoneController.text,
          'image': base64Image, // Sending the photo
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          _showSnackBar("Profile updated successfully", Colors.green);
          loadProfile(); // Refresh and save to SharedPreferences
        }
      }
    } catch (e) {
      log(e.toString());
    }
    setState(() => isLoading = false);
  }

  // ================= REFRESH & SAVE SESSION =================
  void loadProfile() {
    setState(() => isLoading = true);
    http
        .get(
          Uri.parse(
            '${MyConfig.baseUrl}/pawpal/api/getuserdetails.php?userid=${widget.user.userId}',
          ),
        )
        .then((response) async {
          if (response.statusCode == 200) {
            var resarray = jsonDecode(response.body);
            if (resarray['status'] == 'success') {
              // 1. Update the local User object
              User updatedUser = User.fromJson(resarray['data']);

              // 2. Save to SharedPreferences (Task Requirement)
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('user', jsonEncode(updatedUser.toJson()));

              setState(() {
                widget.user = updatedUser;
                _loadUserData();
                _image = null; // Reset temp image since it's now on server
              });
            }
          }
          setState(() => isLoading = false);
        });
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width > 500
        ? 500.0
        : MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1F3C88),
        foregroundColor: Colors.white,
        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: loadProfile, icon: const Icon(Icons.refresh)),
        ],
      ),
      drawer: MyDrawer(user: widget.user),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // PHOTO SELECTION SECTION
                        GestureDetector(
                          onTap: _selectImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: const Color(0xFF1F3C88),
                                backgroundImage: _image != null
                                    ? FileImage(_image!) as ImageProvider
                                    : NetworkImage(
                                        "${MyConfig.baseUrl}/pawpal/uploads/profile/${widget.user.userId}.jpg?t=${DateTime.now().millisecondsSinceEpoch}",
                                      ),
                                child:
                                    (_image == null && widget.user.name != null)
                                    ? null // Only show initials if no image exists
                                    : null,
                              ),
                              const Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 18,
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Color(0xFF1F3C88),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        _readonlyField("User ID", widget.user.userId),
                        _readonlyField("Email", widget.user.email),

                        const Divider(height: 30),

                        _inputField(
                          controller: nameController,
                          label: "Name",
                          icon: Icons.person,
                          keyboard: TextInputType.name,
                        ),
                        const SizedBox(height: 12),
                        _inputField(
                          controller: phoneController,
                          label: "Phone Number",
                          icon: Icons.phone_outlined,
                          keyboard: TextInputType.phone,
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F3C88),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _updateProfile,
                            child: const Text(
                              "Save Changes",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // (Keep your existing _readonlyField and _inputField helper widgets here)
  Widget _readonlyField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        readOnly: true,
        controller: TextEditingController(text: value ?? "-"),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
