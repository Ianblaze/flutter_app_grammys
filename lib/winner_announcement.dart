import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';

class BetResultListener extends StatefulWidget {
  final String category;
  final String userPrediction;

  BetResultListener({required this.category, required this.userPrediction});

  @override
  _BetResultListenerState createState() => _BetResultListenerState();
}

class _BetResultListenerState extends State<BetResultListener> {
  ConfettiController _confettiController = ConfettiController(duration: Duration(seconds: 2));
  bool isWinner = false;

  @override
  void initState() {
    super.initState();
    _listenForWinnerUpdate();
  }

  // Firestore Listener for Winner Updates
  void _listenForWinnerUpdate() {
    FirebaseFirestore.instance
        .collection('grammys')
        .doc('2024')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> winners = snapshot['winners'] ?? {};
        String? actualWinner = winners[widget.category];

        if (actualWinner == widget.userPrediction) {
          setState(() {
            isWinner = true;
          });
          _showWinnerPopup();
        }
      }
    });
  }

  // Show the pop-up
  void _showWinnerPopup() {
    _confettiController.play();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text("Result", style: TextStyle(color: Colors.white, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
            ),
            Text(
              isWinner ? "🎉 You Won! 🎉" : "Better luck next time!",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _confettiController.stop();
              Navigator.pop(context);
            },
            child: Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink(); // This widget stays in the background, no UI needed
  }
}


