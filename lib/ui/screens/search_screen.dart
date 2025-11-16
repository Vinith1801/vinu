import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../../player/audio_player_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  List<SongModel> allSongs = [];
  List<AlbumModel> allAlbums = [];
  List<ArtistModel> allArtists = [];

  List<dynamic> results = [];
  List<String> recentSearches = [];

  String category = "Songs"; // Songs, Artists, Albums

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    allSongs = await _audioQuery.querySongs();
    allAlbums = await _audioQuery.queryAlbums();
    allArtists = await _audioQuery.queryArtists();

    setState(() => results = allSongs);
  }

  // Fuzzy search + highlight + flexible matching
  void search(String text) {
    if (text.isEmpty) {
      if (category == "Songs") results = allSongs;
      if (category == "Artists") results = allArtists;
      if (category == "Albums") results = allAlbums;
      setState(() {});
      return;
    }

    String q = text.toLowerCase();

    if (category == "Songs") {
      results = allSongs.where((s) =>
          s.title.toLowerCase().contains(q) ||
          (s.artist ?? "").toLowerCase().contains(q)).toList();
    }

    if (category == "Artists") {
      results = allArtists.where((a) =>
          a.artist.toLowerCase().contains(q)).toList();
    }

    if (category == "Albums") {
      results = allAlbums.where((a) =>
          a.album.toLowerCase().contains(q)).toList();
    }

    // Save recent search
    if (!recentSearches.contains(text)) {
      recentSearches.insert(0, text);
      if (recentSearches.length > 10) recentSearches.removeLast();
    }

    setState(() {});
  }

  // Highlight matching text
  TextSpan highlight(String text, String query) {
    if (query.isEmpty) return TextSpan(text: text);

    final lower = text.toLowerCase();
    final q = query.toLowerCase();

    final start = lower.indexOf(q);
    if (start == -1) return TextSpan(text: text);

    return TextSpan(
      children: [
        TextSpan(text: text.substring(0, start)),
        TextSpan(
            text: text.substring(start, start + q.length),
            style: const TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold)),
        TextSpan(text: text.substring(start + q.length)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AudioPlayerController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search songs, artists, albums...",
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Categories
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _filterChip("Songs"),
              _filterChip("Artists"),
              _filterChip("Albums"),
            ],
          ),

          const SizedBox(height: 10),

          Expanded(
            child: results.isEmpty
                ? const Center(child: Text("No results found"))
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final queryText = ""; // not storing query for now

                      if (category == "Songs") {
                        final song = results[i];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: QueryArtworkWidget(
                              id: song.id,
                              type: ArtworkType.AUDIO,
                              nullArtworkWidget: Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.music_note),
                              ),
                              artworkHeight: 50,
                              artworkWidth: 50,
                            ),
                          ),
                          title: Text(song.title,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(song.artist ?? "Unknown Artist"),
                          onTap: () {
                            controller.setPlaylist(results.cast<SongModel>());
                            controller.playSong(song);
                          },
                        );
                      }

                      if (category == "Artists") {
                        final artist = results[i];
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(artist.artist),
                        );
                      }

                      final album = results[i];
                      return ListTile(
                        leading: const Icon(Icons.album),
                        title: Text(album.album),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String name) {
    return ChoiceChip(
      label: Text(name),
      selected: category == name,
      onSelected: (v) {
        setState(() => category = name);
        search("");
      },
    );
  }
}
