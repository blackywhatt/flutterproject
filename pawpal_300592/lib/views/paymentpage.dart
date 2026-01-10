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
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _onPayButtonPressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _showConfirmDialog(_amountController.text);
  }

  void _showConfirmDialog(String amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Donation"),
        content: Text(
          "Are you sure you want to donate RM $amount for ${widget.pet.petName}?\n\nThis amount will be deducted from your available balance.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F3C88),
            ),
            onPressed: () {
              Navigator.pop(context);
              _submitMoneyDonation();
            },
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _submitMoneyDonation() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String amountStr = _amountController.text;

    http
        .post(
          Uri.parse("${MyConfig.baseUrl}/pawpal/api/submit_donation.php"),
          body: {
            "user_id": widget.user.userId.toString(),
            "pet_id": widget.pet.petId.toString(),
            "donation_type": "Money",
            "amount": amountStr,
            "description": "Cash donation for ${widget.pet.petName}",
          },
        )
        .then((response) {
          setState(() {
            _isLoading = false;
          });

          var data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            String formattedBalance = "";

            setState(() {
              double donationAmount = double.tryParse(amountStr) ?? 0.0;
              double currentCredit = widget.user.userCredit ?? 0.0;
              double newBalance = currentCredit - donationAmount;

              widget.user.userCredit = newBalance;

              formattedBalance = newBalance.toStringAsFixed(2);
            });

            _showReceiptDialog(amountStr, formattedBalance);
          } else {}
        });
  }

  void _showReceiptDialog(String amount, String newBalance) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              "Payment Successful",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Divider(),
            _receiptRow("Target Pet", widget.pet.petName ?? "N/A"),
            _receiptRow("Amount", "RM $amount"),
            _receiptRow("New Balance", "RM $newBalance"),
            const Divider(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F3C88),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Done",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Money Donation"),
        backgroundColor: const Color(0xFF1F3C88),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(
                Icons.account_balance_wallet_rounded,
                size: 80,
                color: Color(0xFF1F3C88),
              ),
              const SizedBox(height: 16),
              Text(
                "Donating for ${widget.pet.petName}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F3C88).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Available Balance: RM ${widget.user.userCredit?.toString() ?? '0.00'}",
                  style: const TextStyle(
                    color: Color(0xFF1F3C88),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _amountController,
                enabled: !_isLoading,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Please enter an amount";
                  final n = double.tryParse(value);
                  if (n == null || n <= 0) return "Enter a valid amount";

                  double availableBalance = widget.user.userCredit ?? 0.0;

                  if (n > availableBalance) {
                    return "Insufficient balance";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Donation Amount",
                  prefixText: "RM ",
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F3C88),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _isLoading ? null : _onPayButtonPressed,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Confirm & Pay",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
