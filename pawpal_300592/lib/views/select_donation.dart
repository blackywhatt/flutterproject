import 'package:flutter/material.dart';
import 'package:pawpal_300592/models/pet.dart';
import 'package:pawpal_300592/models/user.dart';
import 'package:pawpal_300592/views/paymentpage.dart';
import 'package:pawpal_300592/views/aiddonationpage.dart';

class SelectDonationPage extends StatelessWidget {
  final Pet pet;
  final User user;

  const SelectDonationPage({super.key, required this.pet, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Donation Type")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _donationTile(
              context,
              "Money",
              Icons.monetization_on,
              Colors.green,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => PaymentPage(pet: pet, user: user),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
            _donationTile(context, "Food", Icons.restaurant, Colors.orange, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) =>
                      AidDonationPage(pet: pet, user: user, type: "Food"),
                ),
              );
            }),
            const SizedBox(height: 15),
            _donationTile(
              context,
              "Medicine",
              Icons.medical_services,
              Colors.red,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) =>
                        AidDonationPage(pet: pet, user: user, type: "Medicine"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _donationTile(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Icon(icon, color: color, size: 40),
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
