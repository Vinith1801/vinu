// lib/ui/screens/home/tabs/folders_tab.dart
import 'package:flutter/material.dart';
import '../../../screens/folder_songs_screen.dart';

class FoldersTab extends StatelessWidget {
  final List<String> folders;

  const FoldersTab({super.key, required this.folders});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.5);

    if (folders.isEmpty) {
      return Center(child: Text("No folders found", style: TextStyle(color: muted)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: folders.length,
      itemBuilder: (_, i) {
        final f = folders[i];
        final name = f.split("/").last;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.folder_rounded, color: scheme.primary),
          ),
          title: Text(name,
              style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
          subtitle: Text(f, style: TextStyle(color: muted)),
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => FolderSongsScreen(folderPath: f))),
        );
      },
    );
  }
}
