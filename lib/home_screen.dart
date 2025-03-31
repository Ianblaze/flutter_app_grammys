import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'auth_service.dart';
import 'login_screen.dart';
import 'betting_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'artist_stats.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService();
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const BettingScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
    const ArtistStatsPage(artistName: ''),
  
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.amber.shade400, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(top: BorderSide(color: Colors.amber.shade100, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 0.5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.amber.shade600,
          unselectedItemColor: Colors.grey.shade400,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          elevation: 10,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.sports_esports), label: "Bet"),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: "Stats"),

          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAppName(),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildFeatureCard(context, "Place a Bet", Icons.sports_esports, 1),
                _buildFeatureCard(context, "History", Icons.history, 2),
                _buildFeatureCard(context, "Profile", Icons.person, 3),
                _buildFeatureCard(context, "Artist Stats", Icons.bar_chart_rounded, 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon, int pageIndex) {
    return GestureDetector(
      onTap: () {
        _HomeScreenState? parent = context.findAncestorStateOfType<_HomeScreenState>();
        if (parent != null) {
          parent._onItemTapped(pageIndex);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade600, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.4),
              blurRadius: 4,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppName() {
    return Shimmer.fromColors(
      baseColor: Colors.amber.shade400,
      highlightColor: Colors.white,
      child: Text(
        "GramBot",
        style: TextStyle(
          fontSize: 35,
          fontWeight: FontWeight.w500,
          letterSpacing: 3.0,
          foreground: Paint()
            ..shader = LinearGradient(
              colors: [Colors.amber.shade400, Colors.white],
            ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
        ),
      ),
    );
  }
}



