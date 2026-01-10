import 'dart:convert'; // Add this for jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Add this for API calls
import 'package:pawpal_300592/models/pet.dart';
import 'package:pawpal_300592/models/user.dart';
import 'package:pawpal_300592/myconfig.dart'; // Add this for baseUrl

class AidDonationPage extends StatefulWidget {
  final Pet pet;
  final User user;
  final String type;

  const AidDonationPage({
    super.key,
    required this.pet,
    required this.user,
    required this.type,
  });

  @override
  State<AidDonationPage> createState() => _AidDonationPageState();
}

class _AidDonationPageState extends State<AidDonationPage> {
  final TextEditingController _descController = TextEditingController();

  // --- ADD THIS METHOD HERE ---
  void _submitAidDonation() {
    String description = _descController.text;

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide donation details")),
      );
      return;
    }

    // This calls your submit_donation.php
    http
        .post(
          Uri.parse("${MyConfig.baseUrl}/pawpal/api/submit_donation.php"),
          body: {
            "user_id": widget.user.userId,
            "pet_id": widget.pet.petId,
            "donation_type": widget.type, // "Food" or "Medicine"
            "amount": "0", // Aid does not use credits
            "description": description, // Stored in tbl_donations
          },
        )
        .then((response) {
          var data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            // Returns to PetDetails and shows success
            Navigator.of(context).popUntil((route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Thank you for your ${widget.type} donation!"),
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.type} Donation"),
        backgroundColor: const Color(0xFF1F3C88),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Providing ${widget.type} for ${widget.pet.petName}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Describe the item (e.g., 10kg Kibbles, Brand X)",
                labelText: "${widget.type} Details",
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F3C88),
                ),
                // --- UPDATE THIS BUTTON ---
                onPressed: _submitAidDonation,
                child: const Text(
                  "Submit Donation",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
