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

  String category = "Songs";
  String queryText = "";

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

  void search(String text) {
    queryText = text;

    if (text.isEmpty) {
      if (category == "Songs") results = allSongs;
      if (category == "Artists") results = allArtists;
      if (category == "Albums") results = allAlbums;
      setState(() {});
      return;
    }

    final q = text.toLowerCase();

    if (category == "Songs") {
      results = allSongs.where((s) =>
          s.title.toLowerCase().contains(q) ||
          (s.artist ?? "").toLowerCase().contains(q)).toList();
    } else if (category == "Artists") {
      results = allArtists.where((a) =>
          a.artist.toLowerCase().contains(q)).toList();
    } else {
      results = allAlbums.where((a) =>
          a.album.toLowerCase().contains(q)).toList();
    }

    if (!recentSearches.contains(text)) {
      recentSearches.insert(0, text);
      if (recentSearches.length > 10) recentSearches.removeLast();
    }

    setState(() {});
  }

  TextSpan highlight(String text) {
    if (queryText.isEmpty) return TextSpan(text: text);

    final lower = text.toLowerCase();
    final q = queryText.toLowerCase();

    final start = lower.indexOf(q);
    if (start == -1) return TextSpan(text: text);

    return TextSpan(
      children: [
        TextSpan(text: text.substring(0, start)),
        TextSpan(
          text: text.substring(start, start + q.length),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(text: text.substring(start + q.length)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AudioPlayerController>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey.shade100,
        foregroundColor: Colors.black,
        title: const Text("Search", style: TextStyle(fontSize: 20)),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // PREMIUM SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: search,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 22),
                  hintText: "Search songs, artists, albums",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // CATEGORY SELECTOR (Premium Pills)
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16),
              children: [
                _categoryChip("Songs"),
                const SizedBox(width: 10),
                _categoryChip("Artists"),
                const SizedBox(width: 10),
                _categoryChip("Albums"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: results.isEmpty
                ? const Center(
                    child: Text(
                      "No results found",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      if (category == "Songs") {
                        final song = results[i];
                        return _songTile(song, controller);
                      }

                      if (category == "Artists") {
                        final artist = results[i];
                        return _artistTile(artist);
                      }

                      final album = results[i];
                      return _albumTile(album);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ------------------ Premium Widgets -------------------

  Widget _categoryChip(String name) {
    final selected = category == name;

    return GestureDetector(
      onTap: () {
        setState(() => category = name);
        search(queryText);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: selected ? Colors.black : Colors.grey.shade300),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          name,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _songTile(SongModel s, AudioPlayerController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: QueryArtworkWidget(
            id: s.id,
            type: ArtworkType.AUDIO,
            artworkHeight: 55,
            artworkWidth: 55,
            nullArtworkWidget: Container(
              width: 55,
              height: 55,
              color: Colors.grey.shade300,
              child: const Icon(Icons.music_note, color: Colors.black54),
            ),
          ),
        ),
        title: Text(s.title,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(s.artist ?? "Unknown",
            maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: () {
          controller.setPlaylist(results.cast<SongModel>());
          controller.playSong(s);
        },
      ),
    );
  }

  Widget _artistTile(ArtistModel a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, size: 28, color: Colors.black87),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              a.artist,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _albumTile(AlbumModel a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.album_rounded, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              a.album,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
