import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal_300592/models/pet.dart';
import 'package:pawpal_300592/models/user.dart';
import 'package:pawpal_300592/myconfig.dart';
import 'package:pawpal_300592/views/loginpage.dart';
import 'package:pawpal_300592/views/select_donation.dart';

class PetDetails extends StatefulWidget {
  final Pet pet;
  final User? user;
  const PetDetails({super.key, required this.pet, required this.user});
  @override
  State<PetDetails> createState() => _PetDetailsState();
}

class _PetDetailsState extends State<PetDetails> {
  final TextEditingController _messageController = TextEditingController();
  String selectedDonationType = 'Money';

  @override
  Widget build(BuildContext context) {
    bool isOwner = widget.user?.userId == widget.pet.userId;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet.petName ?? "Pet Details"),
        backgroundColor: const Color(0xFF1F3C88),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.pet.petName ?? "Unnamed",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${widget.pet.petType} • ${widget.pet.category}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _infoBox(
                        Icons.transgender,
                        "Gender",
                        widget.pet.petGender ?? "N/A",
                      ),
                      _infoBox(
                        Icons.cake_outlined,
                        "Age",
                        widget.pet.petAge ?? "Unknown",
                      ),
                      _infoBox(
                        Icons.health_and_safety_outlined,
                        "Health",
                        widget.pet.petHealth ?? "Healthy",
                      ),
                    ],
                  ),

                  const Divider(height: 40),

                  const Text(
                    "Posted By",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("User ID: ${widget.pet.userId}"),
                  Text("Name: ${widget.pet.ownerName ?? 'Unknown'}"),

                  const SizedBox(height: 20),
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(widget.pet.description ?? "No description provided."),

                  if (!isOwner) ...[
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F3C88),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: _showAdoptionForm,
                        child: const Text(
                          "Request to Adopt",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),

                    if (widget.pet.category == "Donation Request") ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF1F3C88)),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: () {
                            if (widget.user?.userId == '0' ||
                                widget.user == null) {
                              _showLoginDialog();
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SelectDonationPage(
                                    pet: widget.pet,
                                    user: widget.user!,
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            "Donate Help (Food/Med/Cash)",
                            style: TextStyle(
                              color: Color(0xFF1F3C88),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                  if (isOwner) ...[
                    const SizedBox(height: 30),
                    const Center(
                      child: Text(
                        "This is your own pet.",
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(IconData icon, String label, String value) {
    return Container(
      width: (MediaQuery.of(context).size.width / 3) - 20,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F3C88).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F3C88).withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF1F3C88), size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F3C88),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdoptionForm() {
    if (widget.user?.userId == '0' || widget.user == null) {
      _showLoginDialog();
      return;
    }

    // ignore: no_leading_underscores_for_local_identifiers
    final GlobalKey<FormState> _adoptionFormKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Form(
          key: _adoptionFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.redAccent),
                  const SizedBox(width: 10),
                  Text(
                    "Adopt ${widget.pet.petName}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Please tell the owner a bit about yourself and your home environment.",
                style: TextStyle(color: Colors.blueGrey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter your message to the owner";
                  }
                  if (value.trim().length < 10) {
                    return "Your message is too short (min. 10 characters)";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText:
                      "Example: I have a large fenced yard and work from home...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  errorStyle: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Color(0xFF1F3C88),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Maybe Later"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F3C88),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (_adoptionFormKey.currentState!.validate()) {
                          _submitAdoptionRequest();
                        }
                      },
                      child: const Text(
                        "Send Request",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitAdoptionRequest() async {
    String message = _messageController.text.trim();

    try {
      http
          .post(
            Uri.parse("${MyConfig.baseUrl}/pawpal/api/submit_adoption.php"),
            body: {
              "pet_id": widget.pet.petId,
              "requester_id": widget.user!.userId,
              "owner_id": widget.pet.userId,
              "message": message,
            },
          )
          .then((response) {
            if (response.statusCode == 200) {
              var data = jsonDecode(response.body);
              if (data['status'] == 'success') {
                _messageController.clear();

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Application submitted successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Failed: ${data['message'] ?? 'Error occurred'}",
                    ),
                  ),
                );
              }
            }
          });
    } catch (e) {
      debugPrint("Adoption Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connection error. Please try again later."),
        ),
      );
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Login Required"),
        content: const Text("Please login to interact with this pet."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F3C88),
            ),
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text("Login", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildImageHeader() {
    String imageToShow = "";
    if (widget.pet.imagePaths != null && widget.pet.imagePaths!.isNotEmpty) {
      try {
        List<dynamic> list = jsonDecode(widget.pet.imagePaths!);
        if (list.isNotEmpty) imageToShow = list[0];
      } catch (e) {
        debugPrint("Decoding error: $e");
      }
    }
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: Image.network(
        "${MyConfig.baseUrl}/$imageToShow",
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.pets, size: 100),
      ),
    );
  }
}
