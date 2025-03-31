import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';
import 'Nominee_screen.dart';

class BettingScreen extends StatefulWidget {
  const BettingScreen({super.key});

  @override
  _BettingScreenState createState() => _BettingScreenState();
}

class _BettingScreenState extends State<BettingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int userPoints = 0;

  Map<String, List<Map<String, dynamic>>> grammyNominations = {
    "ALBUM OF THE YEAR": [
      {"name": "Midnights - Taylor Swift", "odds": 4.8},
      {"name": "SOS - SZA", "odds": 4.3},
      {"name": "Did You Know That There's A Tunnel Under Ocean Blvd - Lana Del Rey","odds": 2.9},
      {"name": "Endless Summer Vacation - Miley Cyrus", "odds": 3.7},
      {"name": "GUTS - Olivia Rodrigo", "odds": 4.9},
      {"name": "World Music Radio - John Batiste", "odds": 2.3},
    ],
    "RAP ALBUM OF THE YEAR": [
      {"name": "Utopia - Travis Scott", "odds": 3.8},
      {"name": "MICHEAL - Killer Mike", "odds": 1.2},
      {"name": "CALL ME IF YOU GET LOST - Tyler The Creator", "odds": 2.2},
      {"name": "GNX - Kendrick Lamar", "odds": 4.8},
      {"name": "HEROES & VILLIANS - Metro Boomin", "odds": 3.1},
      {"name": "Her Loss - Drake & 21 Savage", "odds": 3.6},
      {"name": "King's Disease III - Nas", "odds": 1.6},
    ],
    "BEST RAP SONG": [
      {"name": "Embarrassed - Don Toliver", "odds": 2.3},
      {"name": "Rich Flex - Drake & 21 Savage", "odds": 3.9},
      {"name": "SCIENTISTS & ENGINEERS - Killer Mike", "odds": 1.4},
      {"name": "SORRY NOT SORRY - Tyler The Creator", "odds": 2.1},
      {"name": "TIL FURTHER NOTICE - Travis Scott", "odds": 3.3},
      {"name": "Trance - Metro Boomin, Young Thug, Travis Scott", "odds": 3.8},
    ],
    "PRODUCER OF THE YEAR": [
      {"name": "Mike Dean", "odds": 2.9},
      {"name": "Jack Antonoff", "odds": 4.2},
      {"name": "Dan Nigro", "odds": 3.9},
      {"name": "Hit-Boy", "odds": 3.1},
      {"name": "Metro Boomin", "odds": 3.8},
    ],
    "BEST POP SOLO PERFORMANCE": [
      {"name": "Anti-Hero - Taylor Swift", "odds": 2.4},
      {"name": "What Was I Made For? - Billie Eilish", "odds": 4.6},
      {"name": "Vampire - Olivia Rodrigo", "odds": 4.3},
      {"name": "Paint The Town Red - Doja Cat", "odds": 3.7},
      {"name": "Flowers - Miley Cyrus", "odds": 5.4},
    ],
    "BEST NEW ARTIST": [
      {"name": "Fred again", "odds": 1.8},
      {"name": "Gracie Abrams", "odds": 2.7},
      {"name": "Ice Spice", "odds": 3.1},
      {"name": "Noah Kahan", "odds": 1.4},
      {"name": "Victoria Monét", "odds": 2.9},
    ],
    "BEST POP VOCAL ALBUM": [
      {"name": "Endless Summer Vacation - Miley Cyrus", "odds": 4.3},
      {"name": "GUTS - Olivia Rodrigo", "odds": 4.0},
      {"name": "Subtract - Ed Sheeran", "odds": 2.1},
      {"name": "Midnights - Taylor Swift", "odds": 4.8},
    ],
    "R&B SONG OF THE YEAR": [
      {"name": "Moment of Your Life - Brent Faiyaz", "odds": 2.8},
      {"name": "On My Mama - Victoria Monet", "odds": 2.3},
      {"name": "Snooze - SZA", "odds": 6.5},
      {"name": "WAIT FOR U - Future", "odds": 3.1},
    ],
  };

  @override
  void initState() {
    super.initState();
    _fetchUserPoints();
  }

  void _fetchUserPoints() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        userPoints = userDoc.exists ? (userDoc["points"] ?? 1000) : 1000;
      });
      if (!userDoc.exists) {
        _firestore.collection('users').doc(user.uid).set({"points": 1000});
      }
    }
  }

  void openNomineeScreen(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NomineeScreen(
          category: category,
          nominees: grammyNominations[category] ?? [],
          userPoints: userPoints,
          onBetPlaced: _fetchUserPoints,
        ),
      ),
    );
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
          child: const Text(
            "",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
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
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: grammyNominations.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: grammyNominations.keys.map((category) {
                      return GestureDetector(
                        onTap: () => openNomineeScreen(category),
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
                                category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  color: Colors.white),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
