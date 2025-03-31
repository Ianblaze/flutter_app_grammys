import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class WinnerCalculator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  Future<void> determineWinner(String category) async {
    try {
      DocumentSnapshot categorySnapshot = await _firestore
          .collection("grammys")
          .doc("2024")
          .collection("nominees")
          .doc(category)
          .get();

      if (!categorySnapshot.exists) {
        print(" No nominee data found for category $category.");
        return;
      }

      // fetchinkng nominees from subcollection
      QuerySnapshot nomineesQuery = await _firestore
          .collection("grammys")
          .doc("2024")
          .collection("nominees")
          .doc(category)
          .collection("nominees")
          .get();

      if (nomineesQuery.docs.isEmpty) {
        print(" No nominees found in category $category.");
        return;
      }

      String? winningNominee;
      double highestScore = 0;

      for (var nomineeDoc in nomineesQuery.docs) {
        var nomineeData = nomineeDoc.data() as Map<String, dynamic>;

        double buzz = (nomineeData["buzz"] ?? 0).toDouble();
        double history = (nomineeData["history"] ?? 0).toDouble();
        double reviews = (nomineeData["reviews"] ?? 0).toDouble();
        double sales = (nomineeData["sales"] ?? 0).toDouble();
        double trends = (nomineeData["trends"] ?? 0).toDouble();

        double totalScore = (buzz * 0.3) +
            (history * 0.2) +
            (reviews * 0.2) +
            (sales * 0.2) +
            (trends * 0.1);

        print(" ${nomineeDoc.id} Total Score: $totalScore");

        if (totalScore > highestScore) {
          highestScore = totalScore;
          winningNominee = nomineeDoc.id;
        }
      }

      if (winningNominee == null) {
        print(" No winner could be determined for $category.");
        return;
      }

      print(" Winner for $category: $winningNominee");

      // Update the winner in Firestore
      await _firestore
          .collection("grammys")
          .doc("2024")
          .update({"winners.$category": winningNominee});

      // Process payouts
      await _processPayouts(category, winningNominee);
    } catch (e) {
      print(" Error determining winner for $category: $e");
    }
  }

  /// **Processes payouts** 
  Future<void> _processPayouts(String category, String winningNominee) async {
    try {
      QuerySnapshot usersSnapshot = await _firestore.collection("users").get();

      for (var userDoc in usersSnapshot.docs) {
        String userId = userDoc.id;
        bool userWon = false;

        //  fetching bets only for THAT category
        QuerySnapshot betsSnapshot = await _firestore
            .collection("users")
            .doc(userId)
            .collection("bets")
            .where("category", isEqualTo: category)
            .limit(1)
            .get();

        if (betsSnapshot.docs.isEmpty) {
          print(" User $userId did not place a bet in $category.");
          continue;
        }

        for (var betDoc in betsSnapshot.docs) {
          var bet = betDoc.data() as Map<String, dynamic>;
          String nominee = bet["nominee"] ?? "";

          print(" Checking bet for $userId | Bet: $nominee | Winner: $winningNominee");

          if (nominee == winningNominee) {
            double odds = (bet["odds"] ?? 1.0).toDouble();
            int betAmount = (bet["betAmount"] ?? 0);
            int payout = (betAmount * odds).toInt();

            if (betAmount > 0) {
              await _firestore
                  .collection("users")
                  .doc(userId)
                  .update({"points": FieldValue.increment(payout)});
              print(" User $userId WON $payout points!");
              userWon = true;
            }
          }
        }
        

        if (!userWon) {
          print(" User $userId LOST and did not receive points.");
        }
      }
    } catch (e) {
      print(" Error processing payouts: $e");
    }
  }
}

