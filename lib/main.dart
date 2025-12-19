import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:vinu/state/player/audio_player_controller.dart';
import 'package:vinu/state/ui/library_layout_controller.dart';

import 'state/favorites/favorites_controller.dart';
import 'state/playlist/playlist_controller.dart';
import 'state/library/library_controller.dart';
import 'state/library/library_visibility_controller.dart';
import 'ui/player/player_skin_controller.dart';
import 'ui/theme/theme_controller.dart';

import 'ui/home/home_screen.dart';
import 'ui/player/player_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        ChangeNotifierProvider(create: (_) => PlayerSkinController()),
        ChangeNotifierProvider(create: (_) => LibraryLayoutController()),
      ],
      child: const VinuMusicApp(),
    ),
  );
}

class VinuMusicApp extends StatelessWidget {
  const VinuMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: theme.themeMode,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: theme.seedColor,
          brightness: Brightness.light,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        colorScheme: ColorScheme(
          brightness: Brightness.dark,

          // Accent colors (still seeded)
          primary: theme.seedColor,
          secondary: theme.seedColor.withValues(alpha: 0.85),

          // TRUE BLACK SURFACES
          surface: Colors.black,
          surfaceContainerHighest: const Color(0xFF0E0E0E),
          surfaceContainerHigh: const Color(0xFF121212),
          surfaceContainer: const Color(0xFF151515),
          surfaceContainerLow: const Color(0xFF1A1A1A),
          surfaceContainerLowest: Colors.black,

          // Text & icons
          onSurface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.black,

          // Required but unused in your app
          error: Colors.redAccent,
          onError: Colors.black,
          outline: const Color.fromARGB(255, 231, 227, 227),
          shadow: Colors.black,
          scrim: Colors.black,
          inverseSurface: Colors.white,
          onInverseSurface: Colors.black,
          inversePrimary: theme.seedColor,
        ),

        scaffoldBackgroundColor: Colors.black,
        canvasColor: Colors.black,
      ),

      home: const Scaffold(
        body: HomeScreen(),
        bottomNavigationBar: PlayerContainer(),
      ),
    );
  }
}
