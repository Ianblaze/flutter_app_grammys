import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BetDetailsScreen extends StatelessWidget {
  final String betId;
  final Map<String, dynamic> betData;

  const BetDetailsScreen({super.key, required this.betId, required this.betData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Shimmer.fromColors(
          baseColor: Colors.amber,
          highlightColor: Colors.white,
          child: const Text(
            "Bet Details",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900]?.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailItem("Nominee", betData['nominee']),
              _detailItem("Category", betData['category']),
              _detailItem("Bet Amount", "${betData['betAmount']} Points"),
              _detailItem("Odds", betData['odds'].toString()),
              _detailItem("Timestamp", betData['timestamp'].toDate().toString()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, color: Colors.white70)),
          Text(value, style: const TextStyle(fontSize: 18, color: Colors.amber)),
        ],
      ),
    );
  }
}


