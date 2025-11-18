import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'player/audio_player_controller.dart';
import 'theme/theme_controller.dart';
import 'ui/screens/home_screen.dart';
import 'ui/widgets/mini_player.dart';
import 'player/favorites_controller.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioPlayerController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => FavoritesController()),
      ],
      child: const VinuMusicApp(),
    ),
  );
}

class VinuMusicApp extends StatelessWidget {
  const VinuMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme updates should rebuild the MaterialApp → use watch()
    final theme = context.watch<ThemeController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: theme.accentColor,
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: theme.accentColor,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),

      home: const Scaffold(
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
