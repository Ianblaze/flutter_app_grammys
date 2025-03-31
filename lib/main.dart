import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'musicbrainz_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'winner_announcement.dart';
import 'bet_result_listener.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBTvlitstfVIf6b2fAXbsQUSzb0tUBdHVc",
        authDomain: "grammysapp.firebaseapp.com",
        projectId: "grammysapp",
        storageBucket: "grammysapp.firebasestorage.app",
        messagingSenderId: "630516233278",
        appId: "1:630516233278:web:d4f583482b26578b4b4d6f",
        measurementId: "G-NJ5ZH9KR3T",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  /// Fetch data before running the app
  

  runApp(const MyApp());
}

/// 🔥 Fetches MusicBrainz Data & Saves CSV
void fetchMusicData() async {
  MusicBrainzService service = MusicBrainzService();
  List<String> artists = ["Taylor Swift", "Drake", "Beyoncé", "Adele"];
  
  print("🚀 Starting Grammy Data Fetch...");
  await service.fetchAndSaveArtists(artists);
  print("🏁 Data Fetching Complete!");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grammys Betting App',
      theme: ThemeData(
        fontFamily: 'Circular',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w500), // Bold
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w500), // Medium
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400), // Normal
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
       
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FirebaseAuth.instance.currentUser == null
          ? const LoginScreen()
          : const HomeScreen(),
    );
  }
}

