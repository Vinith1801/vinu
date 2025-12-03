//lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:vinu/player/library_visibility_controller.dart';

import 'player/audio_player_controller.dart';
import 'player/favorites_controller.dart';
import 'player/playlist_controller.dart';
import 'player/library_controller.dart';
import 'theme/theme_controller.dart';

import 'ui/screens/home_screen.dart';
import 'ui/widgets/mini_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background audio capabilities (notification + lockscreen)
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.vinith.vinu.channel.audio',
    androidNotificationChannelName: 'Vinu Music',
    androidNotificationOngoing: true,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioPlayerController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => FavoritesController()),
        ChangeNotifierProvider(create: (_) => PlaylistController()),
        ChangeNotifierProvider(create: (_) => LibraryVisibilityController()),
        ChangeNotifierProvider(create: (_) => LibraryController()..init()),
      ],
      child: const VinuMusicApp(),
    ),
  );
}

class VinuMusicApp extends StatelessWidget {
  const VinuMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.read<ThemeController>();

    return AnimatedBuilder(
      animation: themeController,
      builder: (_, __) {
        final colors = themeController.current;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode:
              themeController.isDark ? ThemeMode.dark : ThemeMode.light,

          // -------- LIGHT THEME --------
          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: colors.primary,
              primary: colors.primary,
              secondary: colors.secondary,
              surface: colors.background,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: colors.background,
          ),

          // -------- DARK THEME --------
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: colors.primary,
              primary: colors.primary,
              secondary: colors.secondary,
              surface: Colors.black,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: Colors.black,
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
      },
    );
  }
}
