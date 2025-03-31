import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Shimmer.fromColors(
          baseColor: Colors.amber,
          highlightColor: Colors.white,
          child: const Text(
            "Profile",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("User profile not found.", style: TextStyle(fontSize: 18, color: Colors.white)),
            );
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // picture
                CircleAvatar(
                  radius: 50,
                  backgroundImage: userData['profilePic'] != null
                      ? NetworkImage(userData['profilePic'])
                      : null,
                  backgroundColor: Colors.grey[800],
                  child: userData['profilePic'] == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white70)
                      : null,
                ),
                const SizedBox(height: 16),

                // user name whjich is  not yet implemented
                Text(
                  userData['name'] ?? 'Unknown User',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),

                //pointss
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900]?.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text("Total Points", style: TextStyle(fontSize: 16, color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text(
                        userData['points'].toString(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // potential
                Shimmer.fromColors(
                  baseColor: Colors.white70,
                  highlightColor: Colors.amber,
                  child: const Text(
                    "🏆 Leaderboard Coming Soon...",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),

                // to edit profile
                ElevatedButton(
                  onPressed: () {
                  
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.amber,
                    shadowColor: Colors.amber.withOpacity(0.5),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<DocumentSnapshot> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("No user logged in");

    return await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  }
}


