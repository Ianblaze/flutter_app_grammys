import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_app_grammys/artist_charts.dart';

class ArtistStatsPage extends StatefulWidget {
  final String artistName;
  const ArtistStatsPage({super.key, required this.artistName});

  @override
  _ArtistStatsPageState createState() => _ArtistStatsPageState();
}

class _ArtistStatsPageState extends State<ArtistStatsPage>
    with SingleTickerProviderStateMixin {
  Map<String, String> labelMap = {
    "grammy_noms": "Nominations(Grammys Nominations)",
    "albums": "Discography(Total Albums)",
    "grammy_wins": "Wins(Grammy Wins)",
    "hot100_1s": "No.1 Songs",
    "hot200_1s": "No.1 Albums",
    "total_streams_in_B": "Streams(Total career streams in Billion's)"
  };

  Map<String, dynamic>? artistData;
  Map<String, double> genreData = {};
  bool showStats = false;
  TextEditingController searchController = TextEditingController();
  List<QueryDocumentSnapshot>? allArtists;
  List<QueryDocumentSnapshot>? filteredArtists;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    fetchArtists();
    searchController.addListener(() {
      filterArtists();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchArtists() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('artists').get();
      setState(() {
        allArtists = snapshot.docs;
        filteredArtists = List.from(allArtists!);
      });
    } catch (e) {
      print("Error fetching artist list: $e");
    }
  }
//the searching fuvntion
  void filterArtists() {
    if (allArtists == null) return;
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredArtists = allArtists!
          .where((doc) => doc.id.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> fetchArtistData(String artistName) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('artists')
          .doc(artistName)
          .get();

      if (!doc.exists) {
        setState(() => artistData = null);
        return;
      }

      setState(() {
        artistData = doc.data() as Map<String, dynamic>;
      });

      QuerySnapshot genreSnapshot = await FirebaseFirestore.instance
          .collection('artists')
          .doc(artistName)
          .collection('genres')
          .get();

      Map<String, double> tempGenreData = {};

      for (var genreDoc in genreSnapshot.docs) {
        String genreName = genreDoc.id;
        double percentage =
            (genreDoc.data() as Map<String, dynamic>)['percentage']?.toDouble() ?? 0;
        tempGenreData[genreName] = percentage;
      }

      setState(() {
        genreData = tempGenreData;
        showStats = true;
        _fadeController.forward(from: 0);
      });

    } catch (e) {
      print("Error fetching artist data: $e");
      setState(() => artistData = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
        title:
            const Text("Artist Stats", style: TextStyle(color: Colors.amber)),
        leading: showStats
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => showStats = false),
              )
            : null,
      ),
      body: showStats ? buildStatsView() : buildSearchView(),
    );
  }

  Widget buildSearchView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            controller: searchController,
            decoration: const InputDecoration(
              labelText: "Search for an artist",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search, color: Colors.amber),
            ),
          ),
        ),
        Expanded(
          child: filteredArtists == null
              ? const Center(child: CircularProgressIndicator())
              : filteredArtists!.isEmpty
                  ? const Center(
                      child: Text("No artists found",
                          style: TextStyle(color: Colors.amber)))
                  : ListView.builder(
                      itemCount: filteredArtists!.length,
                      itemBuilder: (context, index) {
                        String artistName = filteredArtists![index].id;
                        return ListTile(
                          title: Text(artistName,
                              style: const TextStyle(color: Colors.amber)),
                          onTap: () => fetchArtistData(artistName),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget buildStatsView() {
  return FadeTransition(
    opacity: _fadeAnimation,
    child: SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            if (artistData != null)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: artistData!.entries.map((entry) {
                  if (entry.value is int || entry.value is double || entry.value is String) {
                    return buildGlassStatCard(entry.key, entry.value.toString());
                  }
                  return const SizedBox.shrink();
                }).toList(),
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: 100, 
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15), 
                  ),
                  onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ArtistChartsPage(
        genreData: genreData, 
        artistId: widget.artistName, 
      ),
    ),
  );
},
  
                  child: const Text("View Charts", style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}

  Widget buildGlassStatCard(String key, String value) {
    String label = labelMap[key] ?? key;
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.amber, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}




