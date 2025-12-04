// lib/ui/widgets/mini_player.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:vinu/player/favorites_controller.dart';

import '../../player/audio_player_controller.dart';
import 'seekbar.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer>
    with TickerProviderStateMixin {
  static const double collapsedHeight = 80;
  late double expandedHeight;

  final ValueNotifier<double> heightNotifier =
      ValueNotifier<double>(collapsedHeight);

  late final AnimationController snapCtrl;
  Animation<double>? snapAnim;

  late final AnimationController rotateCtrl;
  late final AnimationController tonearmCtrl;

  SongModel? _cachedSong;
  Widget? _vinylCached; // cached + repaint-isolated vinyl artwork

  @override
  void initState() {
    super.initState();

    snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    )..addListener(() {
        if (snapAnim != null) {
          heightNotifier.value = snapAnim!.value;
        }
      });

    rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );

    tonearmCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      reverseDuration: const Duration(milliseconds: 360),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    expandedHeight = MediaQuery.of(context).size.height;
  }

  @override
  void dispose() {
    snapCtrl.dispose();
    rotateCtrl.dispose();
    tonearmCtrl.dispose();
    heightNotifier.dispose();
    super.dispose();
  }

  void _snapTo(double target) {
    snapAnim = Tween<double>(
      begin: heightNotifier.value,
      end: target,
    ).animate(
      CurvedAnimation(parent: snapCtrl, curve: Curves.easeOutCubic),
    );
    snapCtrl.forward(from: 0);
  }

  void _openQueue(BuildContext context) {
    final controller = context.read<AudioPlayerController>();
    final queue = controller.playlist;
    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 14),
              Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: scheme.outline.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(26),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Up Next",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: queue.length,
                  itemBuilder: (_, i) {
                    final song = queue[i];
                    final isCurrent = controller.currentIndex == i;

                    return ListTile(
                      tileColor: isCurrent
                          ? scheme.primary.withValues(alpha: 0.1)
                          : null,
                      leading: SizedBox(
                        width: 48,
                        height: 48,
                        child: RepaintBoundary(
                          child: _MiniArtwork(
                            songId: song.id,
                            placeholder: Container(
                              color: scheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.music_note,
                                size: 32,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        song.artist ?? "Unknown",
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: isCurrent
                          ? Icon(Icons.play_arrow, color: scheme.primary)
                          : null,
                      onTap: () {
                        Navigator.of(context).pop();
                        controller.playIndex(i);
                      },
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild only when currentSongId changes
    final currentSongId =
        context.select<AudioPlayerController, int?>(
      (c) => c.currentSongId,
    );

    if (currentSongId == null) return const SizedBox.shrink();

    final controller = context.read<AudioPlayerController>();
    final song = controller.currentSong!;
    final scheme = Theme.of(context).colorScheme;

    // cache vinyl disc per song, with repaint boundary
    if (_cachedSong == null || _cachedSong!.id != song.id) {
      _cachedSong = song;
      _vinylCached = RepaintBoundary(
        child: _buildVinylDisc(song.id, scheme),
      );
    }

    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (heightNotifier.value == collapsedHeight) {
            _snapTo(expandedHeight);
            heightNotifier.value = expandedHeight;
          }
        },
        onVerticalDragUpdate: (d) {
          final newH = (heightNotifier.value - d.delta.dy)
              .clamp(collapsedHeight, expandedHeight);
          heightNotifier.value = newH;
        },
        onVerticalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;

          if (v < -600) {
            _snapTo(expandedHeight);
            heightNotifier.value = expandedHeight;
          } else if (v > 600) {
            _snapTo(collapsedHeight);
            heightNotifier.value = collapsedHeight;
          } else {
            final mid = collapsedHeight +
                (expandedHeight - collapsedHeight) * 0.85;
            if (heightNotifier.value > mid) {
              _snapTo(expandedHeight);
              heightNotifier.value = expandedHeight;
            } else {
              _snapTo(collapsedHeight);
              heightNotifier.value = collapsedHeight;
            }
          }
        },
        onHorizontalDragEnd: (details) {
          if (heightNotifier.value <= collapsedHeight + 60) return;
          final v = details.primaryVelocity ?? 0;
          if (v < -600) {
            controller.next();
          } else if (v > 600) {
            controller.previous();
          }
        },
        child: AnimatedBuilder(
          animation: heightNotifier,
          builder: (_, __) {
            // no context.select here; we just read the notifier value
            final height = heightNotifier.value;

            return Container(
              height: height,
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: height < collapsedHeight + 60
                  ? _mini(controller, scheme)
                  : _full(controller, scheme),
            );
          },
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  //                      MINI UI
  // ----------------------------------------------------------
  Widget _mini(AudioPlayerController c, ColorScheme scheme) {
    final song = c.currentSong!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(26),
            ),
            child: SizedBox(
              width: 58,
              height: 58,
              child: RepaintBoundary(
                child: _MiniArtwork(
                  songId: song.id,
                  placeholder: Container(
                    color: scheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.music_note,
                      size: 26,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  song.artist ?? "Unknown Artist",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Selector<AudioPlayerController, bool>(
            selector: (_, c) => c.isPlaying,
            builder: (_, isPlaying, __) {
              return IconButton(
                iconSize: 30,
                icon: Icon(
                  isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: scheme.onSurface,
                ),
                onPressed: () => c.togglePlayPause(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  //                      FULL UI
  // ----------------------------------------------------------
  Widget _full(AudioPlayerController c, ColorScheme scheme) {
    final song = c.currentSong!;

    return SafeArea(
      top: false,
      child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [

        // TOP SECTION: Collapse Button
        Padding(
          padding: const EdgeInsets.only(left: 6, top: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 32,
                color: scheme.onSurface,
              ),
              onPressed: () {
                _snapTo(collapsedHeight);
                heightNotifier.value = collapsedHeight;
              },
            ),
          ),
        ),

        // CENTER SECTION: Vinyl + Info
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 320,
              height: 320,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Selector<AudioPlayerController, bool>(
                      selector: (_, c) => c.isPlaying,
                      builder: (_, isPlaying, __) {
                        if (isPlaying) {
                          if (!rotateCtrl.isAnimating) rotateCtrl.repeat();
                          tonearmCtrl.forward();
                        } else {
                          rotateCtrl.stop();
                          tonearmCtrl.reverse();
                        }
                        return RotationTransition(
                          turns: rotateCtrl,
                          child: _vinylCached ?? const SizedBox.shrink(),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    right: -18,
                    top: -18,
                    child: AnimatedBuilder(
                      animation: tonearmCtrl,
                      builder: (_, child) {
                        return Transform.rotate(
                          angle: -0.6 + tonearmCtrl.value * 0.55,
                          alignment: Alignment.topLeft,
                          child: child,
                        );
                      },
                      child: _buildTonearm(scheme),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              song.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              song.artist ?? "Unknown Artist",
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 15,
              ),
            ),
          ],
        ),

        // BOTTOM SECTION: Favorite + Seek + Controls
        Padding(
          padding: const EdgeInsets.only(bottom: 26),
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(right: 40),
                  child: Row(
                    children: [
                      const Spacer(),
                      Selector<FavoritesController, bool>(
                        selector: (_, fav) => fav.isFavorite(c.currentSong!.id),
                        builder: (_, isFav, __) {
                          return GestureDetector(
                            onTap: () => context
                                .read<FavoritesController>()
                                .toggleFavorite(c.currentSong!.id),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Icon(
                                isFav
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                key: ValueKey(isFav),
                                size: 32,
                                color: isFav
                                    ? scheme.primary
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

              StreamBuilder<PositionData>(
                stream: c.smoothPositionStream,
                builder: (_, snap) {
                  final position = snap.data?.position ?? Duration.zero;
                  final duration = snap.data?.duration ?? Duration.zero;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SeekBar(
                      position: position,
                      duration: duration,
                      onChangeEnd: c.seek,
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              _controls(c, scheme),
            ],
          ),
        ),
      ],
    )
    );
  }

  // ------------------ Vinyl Disc ------------------
  Widget _buildVinylDisc(int id, ColorScheme scheme) {
    const double size = 300;
    const double artSize = 220;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // BLACK BASE
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
          ),

          // Grooves
          ...List.generate(
            4,
            (i) {
              final radius = size - (i * 32);
              return Container(
                width: radius,
                height: radius,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
              );
            },
          ),

          // Glossy sweep
          Transform.rotate(
            angle: -0.4,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  startAngle: 0,
                  endAngle: 6.28,
                  colors: [
                    Colors.white.withValues(alpha: 0.23),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.23),
                  ],
                  stops: const [0.0, 0.18, 0.82, 1.0],
                ),
              ),
            ),
          ),

          // Artwork – using cached MiniArtwork instead of QueryArtworkWidget
          ClipOval(
            child: SizedBox(
              width: artSize,
              height: artSize,
              child: _MiniArtwork(
                songId: id,
                placeholder: Container(
                  width: artSize,
                  height: artSize,
                  color: Colors.grey.shade900,
                  child: Icon(
                    Icons.music_note,
                    size: 60,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),

          // Center cap
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ Tonearm ------------------
  Widget _buildTonearm(ColorScheme scheme) {
    final armColor = scheme.onSurface;
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: armColor.withValues(alpha: 0.08),
                border: Border.all(
                  color: armColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 10,
            child: Container(
              width: 6,
              height: 110,
              decoration: BoxDecoration(
                color: armColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
              ),
            ),
          ),
          Positioned(
            left: 4,
            top: 112,
            child: Transform.rotate(
              angle: 0.28,
              child: Container(
                width: 28,
                height: 20,
                decoration: BoxDecoration(
                  color: armColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(26),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ Controls ------------------
  Widget _controls(AudioPlayerController c, ColorScheme scheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Selector<AudioPlayerController, Map<String, dynamic>>(
          selector: (_, p) => {
            "shuffle": p.isShuffling,
            "repeat": p.loopMode,
          },
          builder: (_, data, __) {
            final shuffle = data["shuffle"] as bool;
            final repeat = data["repeat"] as LoopMode;

            IconData icon;
            Color color = scheme.onSurfaceVariant;

            if (shuffle) {
              icon = Icons.shuffle_rounded;
              color = scheme.primary;
            } else if (repeat == LoopMode.all) {
              icon = Icons.repeat_rounded;
              color = scheme.primary;
            } else if (repeat == LoopMode.one) {
              icon = Icons.repeat_one_rounded;
              color = scheme.primary;
            } else {
              icon = Icons.shuffle_rounded;
            }

            return GestureDetector(
              onTap: () {
                if (!shuffle && repeat == LoopMode.off) {
                  c.toggleShuffle();
                } else if (shuffle) {
                  c.toggleShuffle();
                  if (c.loopMode != LoopMode.all) c.toggleRepeat();
                } else if (repeat == LoopMode.all) {
                  c.toggleRepeat();
                } else if (repeat == LoopMode.one) {
                  c.toggleRepeat();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(10),
                child: Icon(icon, size: 26, color: color),
              ),
            );
          },
        ),

        const SizedBox(width: 16),

        IconButton(
          iconSize: 36,
          icon: Icon(
            Icons.skip_previous_rounded,
            color: scheme.onSurface,
          ),
          onPressed: c.previous,
        ),

        Selector<AudioPlayerController, bool>(
          selector: (_, p) => p.isPlaying,
          builder: (_, isPlaying, __) => IconButton(
            iconSize: 80,
            icon: Icon(
              isPlaying
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_fill_rounded,
              color: scheme.primary,
            ),
            onPressed: c.togglePlayPause,
          ),
        ),

        IconButton(
          iconSize: 36,
          icon: Icon(
            Icons.skip_next_rounded,
            color: scheme.onSurface,
          ),
          onPressed: c.next,
        ),

        const SizedBox(width: 16),

        IconButton(
          iconSize: 30,
          icon: Icon(
            Icons.queue_music_rounded,
            color: scheme.onSurfaceVariant,
          ),
          onPressed: () => _openQueue(context),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// SHARED MINI ARTWORK WIDGET – uses AudioPlayerController cache
// ------------------------------------------------------------
class _MiniArtwork extends StatefulWidget {
  final int songId;
  final Widget placeholder;

  const _MiniArtwork({
    required this.songId,
    required this.placeholder,
  });

  @override
  State<_MiniArtwork> createState() => _MiniArtworkState();
}

class _MiniArtworkState extends State<_MiniArtwork> {
  Uri? _uri;
  bool _loading = false;
  bool _fileExists = false;

  @override
  void initState() {
    super.initState();
    _loadArtwork();
  }

  @override
  void didUpdateWidget(covariant _MiniArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songId != widget.songId) {
      _uri = null;
      _fileExists = false;
      _loading = false;
      _loadArtwork();
    }
  }

  void _loadArtwork() {
    final ctrl = context.read<AudioPlayerController>();

    final cached = ctrl.getCachedArtworkUri(widget.songId);
    if (cached != null) {
      _uri = cached;
      _fileExists = File.fromUri(cached).existsSync();
      if (mounted) setState(() {});
      return;
    }

    if (_loading) return;
    _loading = true;

    ctrl.ensureArtworkForId(widget.songId).then((uri) {
      if (!mounted) return;
      _uri = uri;
      _fileExists = uri != null && File.fromUri(uri).existsSync();
      _loading = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_uri != null && _fileExists) {
      return Image.file(
        File.fromUri(_uri!),
        fit: BoxFit.cover,
      );
    }

    return widget.placeholder;
  }
}
