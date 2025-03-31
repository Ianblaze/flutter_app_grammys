import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ArtistChartsPage extends StatelessWidget {
  final Map<String, double> genreData;

  const ArtistChartsPage({super.key, required this.genreData, required String artistId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
        title: const Text("Artist Charts", style: TextStyle(color: Colors.amber)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: genreData.isEmpty
            ? const Center(
                child: Text(
                  "No genre data available",
                  style: TextStyle(color: Colors.amber, fontSize: 16),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Genre Distribution",
                    style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: buildPieChart(context)), 
                ],
              ),
      ),
    );
  }

  Widget buildPieChart(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double chartRadius = screenWidth * 0.1;

    return Center(
      child: PieChart(
        PieChartData(
          sections: genreData.entries.map((entry) {
            return PieChartSectionData(
              value: entry.value,
              color: getColorForGenre(entry.key),
              radius: chartRadius,
              titlePositionPercentageOffset: 1.3, 
              title: entry.key.length > 10 
                  ? "${entry.key.split(' ').first}...\n(${entry.value.toInt()}%)"
                  : "${entry.key} (${entry.value.toInt()}%)",
              titleStyle: const TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          sectionsSpace: 3,
          centerSpaceRadius: chartRadius * 0.45, 
          //SwapDuration = Duration(milliseconds: 300)
        ),
      ),
    );
  }

  Color getColorForGenre(String genre) {
    List<Color> colors = [
      Colors.blueAccent, Colors.redAccent, Colors.purpleAccent,
      Colors.greenAccent, Colors.orangeAccent, Colors.pinkAccent,
      Colors.cyanAccent, Colors.tealAccent
    ];
    return colors[genre.hashCode % colors.length]; 
  }
}

