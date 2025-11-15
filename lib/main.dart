import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'player/audio_player_controller.dart';
import 'ui/screens/home_screen.dart';
import 'ui/widgets/mini_player.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AudioPlayerController(),
      child: const VinuMusicApp(),
    ),
  );
}

class VinuMusicApp extends StatelessWidget {
  const VinuMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            HomeScreen(),
            Align(
              alignment: Alignment.bottomCenter,
              child: MiniPlayer(),
            ),
          ],
        ),
      ),
    );
  }
}
