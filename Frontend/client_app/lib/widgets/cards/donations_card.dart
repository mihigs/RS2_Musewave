import 'package:flutter/material.dart';

class DonationCard extends StatelessWidget {
  final String label;
  final VoidCallback onDonate;

  const DonationCard({super.key, required this.label, required this.onDonate});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        trailing: ElevatedButton(
          onPressed: onDonate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blueAccent,
          ),
          child: const Text('Donate'),
        ),
      ),
    );
  }
}