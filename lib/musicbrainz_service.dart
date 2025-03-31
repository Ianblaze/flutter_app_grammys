import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

class MusicBrainzService {
  static const String baseUrl = "https://musicbrainz.org/ws/2";

  /// Fetch detailed artist info
  Future<Map<String, dynamic>?> getArtistInfo(String artistName) async {
    final url = Uri.parse("$baseUrl/artist/?query=$artistName&fmt=json");

    print("🎵 Fetching data for $artistName...");

    try {
      final response = await http.get(
        url,
        headers: {"User-Agent": "GrammyPredictor/1.0 (your-email@example.com)"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["artists"] != null && data["artists"].isNotEmpty) {
          var artist = data["artists"][0];

          List<dynamic>? tags = artist["tags"];
          List<String> genres = tags != null
              ? tags.map((tag) => tag["name"].toString()).toList()
              : ["Unknown"];

          return {
            "name": artist["name"],
            "country": artist["country"] ?? "Unknown",
            "genre": genres,
            "disambiguation": artist["disambiguation"] ?? "",
            "type": artist["type"] ?? "Unknown",
            "begin_date": artist["life-span"]?["begin"] ?? "Unknown",
            "aliases": artist["aliases"]?.map((a) => a["name"]).join(" | ") ?? "None",
            // Placeholder for Grammy data (to be integrated later)
            "grammy_nominations": "Unknown",
            "grammy_wins": "Unknown",
            "latest_album": "Unknown",
            "popularity_score": "Unknown"
          };
        } else {
          print("❌ No data found for $artistName.");
        }
      } else {
        print("⚠️ Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception while fetching $artistName: $e");
    }
    return null;
  }

  /// Fetch & Save Multiple Artists
  Future<void> fetchAndSaveArtists(List<String> artistNames) async {
    List<Map<String, dynamic>> artistData = [];

    for (String artist in artistNames) {
      var data = await getArtistInfo(artist);
      if (data != null) {
        artistData.add(data);
      }

      await Future.delayed(const Duration(seconds: 1));
    }

    if (artistData.isNotEmpty) {
      await saveToCSV(artistData);
    } else {
      print("❌ No valid artist data to save.");
    }
  }

  /// Save Data to CSV File
  Future<void> saveToCSV(List<Map<String, dynamic>> artistData) async {
    try {
      String csv = "Name,Country,Genre,Type,Disambiguation,Begin Date,Aliases,Grammy Nominations,Grammy Wins,Latest Album,Popularity Score\n";

      for (var artist in artistData) {
        String genres = artist['genre'].isEmpty ? "Unknown" : artist['genre'].join('|');
        csv += "${artist['name']},${artist['country']},$genres,${artist['type']},${artist['disambiguation']},${artist['begin_date']},${artist['aliases']},${artist['grammy_nominations']},${artist['grammy_wins']},${artist['latest_album']},${artist['popularity_score']}\n";
      }

      final bytes = utf8.encode(csv);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      html.Url.revokeObjectUrl(url);
      print("✅ CSV file downloaded successfully!");
    } catch (e) {
      print("❌ Error saving CSV: $e");
    }
  }
}
