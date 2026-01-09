import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal_300592/models/user.dart';
import 'package:pawpal_300592/myconfig.dart';
import 'package:pawpal_300592/shared/mydrawer.dart';

class MyDonationScreen extends StatefulWidget {
  final User user;
  const MyDonationScreen({super.key, required this.user});

  @override
  State<MyDonationScreen> createState() => _MyDonationScreenState();
}

class _MyDonationScreenState extends State<MyDonationScreen> {
  List donationList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  void _loadDonations() {
    setState(() => isLoading = true);
    http
        .get(
          Uri.parse(
            "${MyConfig.baseUrl}/pawpal/api/get_my_donations.php?user_id=${widget.user.userId}",
          ),
        )
        .then((response) {
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            if (data['status'] == 'success') {
              setState(() {
                donationList = data['data'];
                isLoading = false;
              });
            } else {
              setState(() => isLoading = false);
            }
          } else {
            setState(() => isLoading = false);
          }
        })
        .catchError((_) => setState(() => isLoading = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Donation History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1F3C88),
        foregroundColor: Colors.white,
        elevation: 0,
        // ADD THIS LINE BELOW
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu), // The three lines icon
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadDonations,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      // MAKE SURE DRAWER IS DECLARED BELOW
      drawer: MyDrawer(user: widget.user),

      body: Column(
        children: [
          // MINI WALLET SUMMARY AT TOP
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1F3C88),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Current Wallet Balance:",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  "RM ${double.tryParse(widget.user.userCredit?.toString() ?? '0')?.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : donationList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: donationList.length,
                    itemBuilder: (context, index) {
                      var donation = donationList[index];
                      bool isMoney =
                          donation['donation_type'].toString().toLowerCase() ==
                          'money';

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: isMoney
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                            child: Icon(
                              isMoney
                                  ? Icons.payments_outlined
                                  : Icons.volunteer_activism_outlined,
                              color: isMoney ? Colors.green : Colors.orange,
                            ),
                          ),
                          title: Text(
                            "To: ${donation['pet_name'] ?? 'Unknown Pet'}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                isMoney
                                    ? "Amount: -RM ${double.tryParse(donation['amount'].toString())?.toStringAsFixed(2)}"
                                    : "Item: ${donation['description']}",
                              ),
                              Text(
                                donation['date_donated'].toString().split(
                                  ' ',
                                )[0],
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: isMoney
                              ? const Text(
                                  "Debited",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                )
                              : const Text(
                                  "Service",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "No donation history found.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
