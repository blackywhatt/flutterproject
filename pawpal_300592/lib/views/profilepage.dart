import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pawpal_300592/models/user.dart';
import 'package:pawpal_300592/myconfig.dart';
import 'package:pawpal_300592/shared/mydrawer.dart';

// ignore: must_be_immutable
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
  File? _image;
  final picker = ImagePicker();
  DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm a');

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

    String base64Image = "";
    if (_image != null) {
      base64Image = base64Encode(_image!.readAsBytesSync());
    }

    try {
      final response = await http
          .post(
            Uri.parse('${MyConfig.baseUrl}/pawpal/api/update_profile.php'),
            body: {
              'user_id': widget.user.userId,
              'user_name': nameController.text,
              'user_phone': phoneController.text,
              'image': base64Image,
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          _showSnackBar("Profile updated successfully", Colors.green);
          await loadProfile();
        } else {
          _showSnackBar("Update failed: ${data['message']}", Colors.red);
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      log("Update Error: $e");
      _showSnackBar("Connection error", Colors.red);
      setState(() => isLoading = false);
    }
  }

  Future<void> loadProfile() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
          '${MyConfig.baseUrl}/pawpal/api/get_user_details.php?userid=${widget.user.userId}',
        ),
      );

      if (response.statusCode == 200) {
        var resarray = jsonDecode(response.body);
        if (resarray['status'] == 'success') {
          var userData = resarray['data'];
          if (userData is List && userData.isNotEmpty) {
            userData = userData[0];
          }

          User updatedUser = User.fromJson(userData);

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', jsonEncode(updatedUser.toJson()));

          setState(() {
            widget.user = updatedUser;
            _loadUserData();
            _image = null;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      log("Load Profile Error: $e");
      setState(() => isLoading = false);
    }
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
                        GestureDetector(
                          onTap: _selectImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: const Color(0xFF1F3C88),
                                child: ClipOval(
                                  child: _image != null
                                      ? Image.file(
                                          _image!,
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        )
                                      : Image.network(
                                          "${MyConfig.baseUrl}/pawpal/uploads/profile/${widget.user.userId}.jpg?t=${DateTime.now().millisecondsSinceEpoch}",
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.person,
                                                  size: 50,
                                                  color: Colors.white,
                                                );
                                              },
                                        ),
                                ),
                              ),
                              const Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 15,
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: Color(0xFF1F3C88),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1F3C88), Color(0xFF4A69BD)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "PawPal Wallet",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "RM ${double.tryParse(widget.user.userCredit?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Available Balance",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
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
