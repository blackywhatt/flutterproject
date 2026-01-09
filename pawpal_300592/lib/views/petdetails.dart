import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal_300592/models/pet.dart';
import 'package:pawpal_300592/models/user.dart';
import 'package:pawpal_300592/myconfig.dart';
import 'package:pawpal_300592/views/loginpage.dart';

class PetDetails extends StatefulWidget {
  final Pet pet;
  final User? user;
  const PetDetails({super.key, required this.pet, required this.user});
  @override
  State<PetDetails> createState() => _PetDetailsState();
}

class _PetDetailsState extends State<PetDetails> {
  final TextEditingController _messageController = TextEditingController();

  // Controllers for Donation Form
  final TextEditingController _donationAmountController =
      TextEditingController();
  final TextEditingController _donationDescController = TextEditingController();
  String selectedDonationType = 'Money';

  @override
  Widget build(BuildContext context) {
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
                  const Divider(height: 30),

                  const Text(
                    "Posted By",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("User ID: ${widget.pet.userId}"),

                  const SizedBox(height: 20),
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(widget.pet.description ?? "No description provided."),

                  const SizedBox(height: 30),

                  // BUTTON 1: REQUEST TO ADOPT (Always visible)
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

                  // BUTTON 2: DONATION (Conditional - only for donation requests)
                  if (widget.pet.category == "Donation Request") ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1F3C88)),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: _showDonationForm,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- DONATION LOGIC ---
  void _showDonationForm() {
    if (widget.user?.userId == '0' || widget.user == null) {
      _showLoginDialog(); // Better than SnackBar
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Make a Donation",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: selectedDonationType,
                items: ['Money', 'Food', 'Medical']
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setModalState(() => selectedDonationType = value!),
                decoration: const InputDecoration(
                  labelText: "Donation Type",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              if (selectedDonationType == 'Money')
                TextField(
                  controller: _donationAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount (RM)",
                    border: OutlineInputBorder(),
                  ),
                )
              else
                TextField(
                  controller: _donationDescController,
                  decoration: InputDecoration(
                    labelText: "Description (e.g. 5kg $selectedDonationType)",
                    border: const OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitDonation,
                child: const Text("Submit Donation"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _submitDonation() {
    // Validation
    if (selectedDonationType == 'Money' &&
        _donationAmountController.text.isEmpty) {
      return;
    }
    if (selectedDonationType != 'Money' &&
        _donationDescController.text.isEmpty) {
      return;
    }

    http
        .post(
          Uri.parse("${MyConfig.baseUrl}/pawpal/api/submit_donation.php"),
          body: {
            "user_id": widget.user!.userId,
            "pet_id": widget.pet.petId,
            "donation_type": selectedDonationType,
            "amount": selectedDonationType == 'Money'
                ? _donationAmountController.text
                : "0",
            "description": selectedDonationType != 'Money'
                ? _donationDescController.text
                : "",
          },
        )
        .then((response) {
          var data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            // --- ADD THESE TWO LINES HERE ---
            _donationAmountController.clear();
            _donationDescController.clear();
            // --------------------------------

            Navigator.pop(context); // This closes the Bottom Sheet
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Thank you for your donation!")),
            );
          }
        });
  }

  // Task Requirement: Adoption Form with Validation
  void _showAdoptionForm() {
    print("Current User ID in PetDetails: ${widget.user?.userId}");
    if (widget.user?.userId == '0' || widget.user == null) {
      _showLoginDialog(); // Better than SnackBar
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Adoption Request",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Why do you want to adopt this pet?",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _submitAdoptionRequest,
              child: const Text("Submit Request"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _submitAdoptionRequest() async {
    String message = _messageController.text;

    // Task Requirement: Validation
    if (message.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please write a message")));
      return;
    }

    // Insert request into tbl_adoptions via API
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
          var data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Request sent successfully!")),
            );
          }
        });
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
