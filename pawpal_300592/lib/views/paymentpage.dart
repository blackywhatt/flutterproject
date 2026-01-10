import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal_300592/models/pet.dart';
import 'package:pawpal_300592/models/user.dart';
import 'package:pawpal_300592/myconfig.dart';

class PaymentPage extends StatefulWidget {
  final Pet pet;
  final User user;
  const PaymentPage({super.key, required this.pet, required this.user});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _amountController = TextEditingController();

  void _submitMoneyDonation() {
    String amount = _amountController.text;

    // Validation: Ensure amount is not empty and is a valid number
    if (amount.isEmpty || double.tryParse(amount) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    // Call your submit_donation.php backend
    http
        .post(
          Uri.parse("${MyConfig.baseUrl}/pawpal/api/submit_donation.php"),
          body: {
            "user_id": widget.user.userId, // The donor ID
            "pet_id": widget.pet.petId, // Used to find the receiver
            "donation_type": "Money", // Trigger credit transfer logic in PHP
            "amount": amount, // The value to deduct/add
            "description":
                "Cash donation for ${widget.pet.petName}", // Record details
          },
        )
        .then((response) {
          var data = jsonDecode(response.body);

          if (data['status'] == 'success') {
            // Success: Clear stack and return to home/details
            Navigator.of(context).popUntil((route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Donation successful! Thank you for your support.",
                ),
              ),
            );
          } else {
            // Handle failure (e.g., Insufficient balance)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'] ?? "Donation failed")),
            );
          }
        })
        .catchError((error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $error")));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Money Donation"),
        backgroundColor: const Color(0xFF1F3C88),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(
              Icons.account_balance_wallet,
              size: 64,
              color: Color(0xFF1F3C88),
            ),
            const SizedBox(height: 10),
            Text(
              "Donating for ${widget.pet.petName}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount (RM)",
                prefixText: "RM ",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F3C88),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _submitMoneyDonation,
                child: const Text(
                  "Confirm Donation",
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
