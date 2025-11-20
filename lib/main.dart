import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'player/audio_player_controller.dart';
import 'player/favorites_controller.dart';
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
    final colors = theme.current;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,

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

      // -------- HOME --------
      home: const Scaffold(
        body: Stack(
          children: [
            HomeScreen(),

            // Mini player always fixed at bottom
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
