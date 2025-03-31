import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_app_grammys/winner_calculator.dart';

class NomineeScreen extends StatefulWidget {
  final String category;
  final List<Map<String, dynamic>> nominees;
  final int userPoints;
  final Function onBetPlaced;

  const NomineeScreen({super.key, 
    required this.category,
    required this.nominees,
    required this.userPoints,
    required this.onBetPlaced,
  });

  @override
  _NomineeScreenState createState() => _NomineeScreenState();
}

class _NomineeScreenState extends State<NomineeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedNominee;
  TextEditingController betController = TextEditingController();
  late int userPoints;

  @override
  void initState() {
    super.initState();
    userPoints = widget.userPoints;
  }

  Future<void> _placeBet() async {
    if (selectedNominee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a nominee first!")),
      );
      return;
    }

    int betAmount = int.tryParse(betController.text) ?? 0;

    if (betAmount <= 0 || betAmount > userPoints) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid bet amount")),
      );
      return;
    }

    User? user = _auth.currentUser;
    if (user == null) return;

    double odds = widget.nominees
        .firstWhere((nominee) => nominee["name"] == selectedNominee!)["odds"];

    try {
      QuerySnapshot previousBets = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("bets")
          .where("category", isEqualTo: widget.category)
          .get();

      for (var doc in previousBets.docs) {
        await doc.reference.delete();
      }

      await _firestore.collection("users").doc(user.uid).update({
        "points": FieldValue.increment(-betAmount)
      });

      await _firestore.collection("users").doc(user.uid).collection("bets").add({
        "nominee": selectedNominee,
        "category": widget.category,
        "odds": odds,
        "betAmount": betAmount,
        "timestamp": FieldValue.serverTimestamp()
      });

      DocumentSnapshot updatedUserDoc =
          await _firestore.collection("users").doc(user.uid).get();

      setState(() {
        userPoints = updatedUserDoc["points"];
      });

      widget.onBetPlaced();

      Future.delayed(const Duration(seconds: 30), () {
        WinnerCalculator().determineWinner(widget.category);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bet placed successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      print("Error placing bet: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error placing bet. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Shimmer.fromColors(
          baseColor: Colors.amber.shade400,
          highlightColor: Colors.white,
          child: Text(
            widget.category,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Shimmer.fromColors(
              baseColor: Colors.amber.shade400,
              highlightColor: Colors.white,
              child: Text(
                "Your Points: $userPoints",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: widget.nominees.map((nominee) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedNominee = nominee["name"];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade600, Colors.black],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 2,
                          spreadRadius: 0.5,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${nominee["name"]} (Odds: x${nominee["odds"]})",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Radio<String>(
                          value: nominee["name"],
                          groupValue: selectedNominee,
                          activeColor: Colors.amber,
                          onChanged: (value) {
                            setState(() {
                              selectedNominee = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: betController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Enter bet amount",
                labelStyle: const TextStyle(color: Colors.amber),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.amber),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.amber, width: 2.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                fillColor: Colors.black,
                filled: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _placeBet,
              child: const Text("Place Bet", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
