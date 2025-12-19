import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinu/state/library/library_visibility_controller.dart';
import '../../library/folder_songs_screen.dart';

class FoldersTab extends StatelessWidget {
  final List<String> folders;

  const FoldersTab({super.key, required this.folders});

  String _basename(String path) {
    return path.split(RegExp(r'[\\/]+')).last;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.5);

    final ctrl = context.watch<LibraryVisibilityController>();

    // Sort the incoming list for stable order and nicer UI
    final List<String> sorted = List.from(folders)..sort((a, b) {
      final x = _basename(a).toLowerCase();
      final y = _basename(b).toLowerCase();
      return x.compareTo(y);
    });

    if (sorted.isEmpty) {
      return Center(child: Text("No folders found", style: TextStyle(color: muted)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: sorted.length,
      itemBuilder: (_, i) {
        final f = sorted[i];
        final name = _basename(f);
        final count = ctrl.folderSongCount[f] ?? 0;
        final displayCount = "$count song${count == 1 ? '' : 's'}";

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
          title: Text(name, style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
          subtitle: Text(displayCount, style: TextStyle(color: scheme.onSurfaceVariant)),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FolderSongsScreen(folderPath: f)),
          ),
        );
      },
    );
  }
}
