import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BetResultListener extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the currently logged-in user's ID
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return SizedBox.shrink(); // User not logged in
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return SizedBox.shrink(); // No data yet
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>?;

        if (userData == null || !userData.containsKey('latestBet')) {
          return SizedBox.shrink(); // No bets placed
        }

        String category = userData['latestBet']['category'];
        String userPrediction = userData['latestBet']['prediction'];

        return FirestoreWinnerListener(category: category, userPrediction: userPrediction);
      },
    );
  }
}

class FirestoreWinnerListener extends StatelessWidget {
  final String category;
  final String userPrediction;

  FirestoreWinnerListener({required this.category, required this.userPrediction});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('grammys').doc('2024').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return SizedBox.shrink();
        }

        var winnerData = snapshot.data!.data() as Map<String, dynamic>?;

        if (winnerData == null || !winnerData.containsKey('winners') || !winnerData['winners'].containsKey(category)) {
          return SizedBox.shrink();
        }

        String actualWinner = winnerData['winners'][category];

        if (actualWinner == userPrediction) {
          Future.delayed(Duration(seconds: 1), () {
            showWinPopup(context);
          });
        }

        return SizedBox.shrink();
      },
    );
  }

  void showWinPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("🎉 Congratulations!"),
          content: Text("You won your bet for $category!"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
