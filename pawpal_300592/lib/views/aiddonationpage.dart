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
  final TextEditingController _itemController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descController = TextEditingController();
  String _deliveryMethod = 'Drop-off'; // Default value

  void _submitAidDonation() {
    String itemName = _itemController.text;
    String quantity = _quantityController.text;
    String description = _descController.text;

    if (itemName.isEmpty || quantity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in item name and quantity")),
      );
      return;
    }

    // Combine values for the database 'description' field
    String finalDescription =
        "Item: $itemName | Qty: $quantity | Method: $_deliveryMethod | Note: $description";

    http
        .post(
          Uri.parse("${MyConfig.baseUrl}/pawpal/api/submit_donation.php"),
          body: {
            "user_id": widget.user.userId.toString(),
            "pet_id": widget.pet.petId.toString(),
            "donation_type": widget.type, // Food or Medicine
            "amount": "0",
            "description": finalDescription,
          },
        )
        .then((response) {
          var data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            _showSuccessDialog();
          }
        });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Donation Logged"),
        content: Text(
          "Thank you! Please ensure the ${widget.type} is delivered via $_deliveryMethod.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close AidPage
              Navigator.pop(context); // Close SelectPage
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.type} Contribution"),
        backgroundColor: const Color(0xFF1F3C88),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Donating for ${widget.pet.petName}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Item Name
            TextField(
              controller: _itemController,
              decoration: InputDecoration(
                labelText: widget.type == "Food"
                    ? "Food Type (e.g. Dry Kibbles)"
                    : "Medicine Name",
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  widget.type == "Food"
                      ? Icons.restaurant
                      : Icons.medical_services,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Quantity
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: "Quantity (e.g. 2 bags / 1 box)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.production_quantity_limits),
              ),
            ),
            const SizedBox(height: 15),

            // Delivery Method Dropdown
            const Text(
              "Delivery Method",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField<String>(
              value: _deliveryMethod,
              items: ['Drop-off', 'Courier', 'Pickup Request'].map((method) {
                return DropdownMenuItem(value: method, child: Text(method));
              }).toList(),
              onChanged: (val) => setState(() => _deliveryMethod = val!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            // Additional Notes
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Additional Notes / Expiry Date",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F3C88),
                ),
                onPressed: _submitAidDonation,
                child: const Text(
                  "Confirm Contribution",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
