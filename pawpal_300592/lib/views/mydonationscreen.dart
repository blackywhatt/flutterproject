import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal_300592/models/user.dart';
import 'package:pawpal_300592/myconfig.dart';

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
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Donation History"),
        backgroundColor: const Color(0xFF1F3C88),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : donationList.isEmpty
          ? const Center(child: Text("You haven't made any donations yet."))
          : ListView.builder(
              itemCount: donationList.length,
              itemBuilder: (context, index) {
                var donation = donationList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: Icon(
                      donation['donation_type'] == 'Money'
                          ? Icons.payments
                          : Icons.volunteer_activism,
                      color: Colors.green,
                    ),
                    title: Text("To: ${donation['pet_name']}"),
                    subtitle: Text(
                      donation['donation_type'] == 'Money'
                          ? "Amount: RM ${donation['amount']}"
                          : "Help: ${donation['description']}",
                    ),
                    trailing: Text(
                      donation['date_donated'].toString().split(' ')[0],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
