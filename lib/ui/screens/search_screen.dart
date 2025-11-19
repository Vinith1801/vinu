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

  TextSpan highlight(String text, Color highlightColor) {
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
          style: TextStyle(
            color: highlightColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(text: text.substring(start + q.length)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AudioPlayerController>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        title: Text("Search",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface)),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // -------------------------------------
          // Premium Search Bar
          // -------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(
                alpha: scheme.brightness == Brightness.dark ? 0.3 : 0.8,
              ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  if (scheme.brightness == Brightness.light)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: TextField(
                onChanged: search,
                style: TextStyle(fontSize: 16, color: scheme.onSurface),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search,
                      size: 22, color: scheme.onSurfaceVariant),
                  hintText: "Search songs, artists, albums",
                  hintStyle:
                      TextStyle(color: scheme.onSurfaceVariant),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // -------------------------------------
          // CATEGORY CHIPS
          // -------------------------------------
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16),
              children: [
                _categoryChip("Songs", scheme),
                const SizedBox(width: 10),
                _categoryChip("Artists", scheme),
                const SizedBox(width: 10),
                _categoryChip("Albums", scheme),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // -------------------------------------
          // RESULTS
          // -------------------------------------
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Text(
                      "No results found",
                      style: TextStyle(
                        fontSize: 16,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      if (category == "Songs") {
                        return _songTile(
                            results[i],
                            controller,
                            scheme);
                      }

                      if (category == "Artists") {
                        return _artistTile(results[i], scheme);
                      }

                      return _albumTile(results[i], scheme);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // CATEGORY CHIP - PREMIUM PILL
  // -----------------------------------------------------------
  Widget _categoryChip(String name, ColorScheme scheme) {
    final selected = category == name;

    return GestureDetector(
      onTap: () {
        setState(() => category = name);
        search(queryText);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected
                ? scheme.primary
                : scheme.outline.withValues(alpha: 0.04),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          name,
          style: TextStyle(
            color: selected ? scheme.onPrimary : scheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // SONG TILE
  // -----------------------------------------------------------
  Widget _songTile(
      SongModel s, AudioPlayerController controller, ColorScheme scheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
              color: scheme.surfaceContainerHighest,
              child: Icon(Icons.music_note,
                  color: scheme.onSurfaceVariant),
            ),
          ),
        ),
        title: Text(
          s.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontWeight: FontWeight.w600, color: scheme.onSurface),
        ),
        subtitle: Text(
          s.artist ?? "Unknown Artist",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        onTap: () {
          controller.setPlaylist(results.cast<SongModel>());
          controller.playSong(s);
        },
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: scheme.surfaceContainerHighest.withValues(alpha: 0.2),
      ),
    );
  }

  // -----------------------------------------------------------
  // ARTIST TILE
  // -----------------------------------------------------------
  Widget _artistTile(ArtistModel a, ColorScheme scheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 70,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(
          alpha: scheme.brightness == Brightness.dark ? 0.2 : 0.7,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (scheme.brightness == Brightness.light)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 26,
            backgroundColor: scheme.surfaceContainerHighest,
            child: Icon(Icons.person,
                size: 28, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              a.artist,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: scheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // ALBUM TILE
  // -----------------------------------------------------------
  Widget _albumTile(AlbumModel a, ColorScheme scheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 70,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(
          alpha: scheme.brightness == Brightness.dark ? 0.2 : 0.7,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (scheme.brightness == Brightness.light)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.album_rounded,
              size: 32, color: scheme.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              a.album,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
