import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
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
  Widget? _vinylArtwork;

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
    expandedHeight = MediaQuery.of(context).size.height * 0.82;
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
      CurvedAnimation(parent: snapCtrl, curve: Curves.linear),
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
                  borderRadius: BorderRadius.circular(4),
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
                      leading: QueryArtworkWidget(
                        id: song.id,
                        type: ArtworkType.AUDIO,
                        artworkHeight: 48,
                        artworkWidth: 48,
                        nullArtworkWidget: Icon(Icons.music_note,
                            size: 36, color: scheme.onSurface),
                      ),
                      title: Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        song.artist ?? "Unknown",
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: isCurrent
                          ? Icon(Icons.play_arrow,
                              color: scheme.primary)
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
    final currentSongId =
        context.select<AudioPlayerController, int?>(
      (c) => c.currentSongId,
    );

    if (currentSongId == null) return const SizedBox.shrink();

    final controller = context.read<AudioPlayerController>();
    final song = controller.currentSong!;
    final scheme = Theme.of(context).colorScheme;

    if (_cachedSong == null || _cachedSong!.id != song.id) {
      _cachedSong = song;
      _vinylArtwork = _buildVinylDisc(song.id, scheme);
    }

    return GestureDetector(
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
              (expandedHeight - collapsedHeight) * 0.45;
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
        } else if (v > 600) controller.previous();
      },
      child: ValueListenableBuilder<double>(
        valueListenable: heightNotifier,
        builder: (_, height, _) {
          return Container(
            height: height,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(26)),
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
            borderRadius: BorderRadius.circular(12),
            child: QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              artworkHeight: 58,
              artworkWidth: 58,
              nullArtworkWidget: Container(
                width: 58,
                height: 58,
                color: scheme.surfaceContainerHighest,
                child:
                    Icon(Icons.music_note, size: 26, color: scheme.onSurface),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: scheme.onSurface)),
                const SizedBox(height: 2),
                Text(song.artist ?? "Unknown Artist",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    )),
              ],
            ),
          ),
          Selector<AudioPlayerController, bool>(
            selector: (_, c) => c.isPlaying,
            builder: (_, isPlaying, _) {
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

    return StreamBuilder<PositionData>(
      stream: c.positionDataStream,
      builder: (_, snap) {
        final position = snap.data?.position ?? Duration.zero;
        final duration = snap.data?.duration ?? Duration.zero;
        final song = c.currentSong!;

        return Stack(
          children: [
            Positioned.fill(child: _background(scheme)),

            Column(
              children: [
                const SizedBox(height: 6),

                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 32, color: scheme.onSurface),
                    onPressed: () {
                      _snapTo(collapsedHeight);
                      heightNotifier.value = collapsedHeight;
                    },
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: 300,
                  height: 300,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Center(
                        child: Selector<AudioPlayerController, bool>(
                          selector: (_, c) => c.isPlaying,
                          builder: (_, isPlaying, _) {
                            if (isPlaying) {
                              if (!rotateCtrl.isAnimating) {
                                rotateCtrl.repeat();
                              }
                              tonearmCtrl.forward();
                            } else {
                              rotateCtrl.stop();
                              tonearmCtrl.reverse();
                            }

                            return RotationTransition(
                              turns: rotateCtrl,
                              child: _vinylArtwork!,
                            );
                          },
                        ),
                      ),

                      Positioned(
                        right: -12,
                        top: -12,
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

                const SizedBox(height: 30),
                Text(song.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        color: scheme.onSurface)),
                const SizedBox(height: 6),
                Text(song.artist ?? "Unknown Artist",
                    style: TextStyle(
                        fontSize: 16, color: scheme.onSurfaceVariant)),
                const SizedBox(height: 28),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SeekBar(
                    position: position,
                    duration: duration,
                    onChangeEnd: c.seek,
                  ),
                ),

                const SizedBox(height: 30),

                _controls(c, scheme),

                const Spacer(),
              ],
            ),
          ],
        );
      },
    );
  }

  // ------------------ Full Background ------------------
  Widget _background(ColorScheme scheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: scheme.brightness == Brightness.dark
            ? RadialGradient(
                center: Alignment.topCenter,
                radius: 1.2,
                colors: [
                  scheme.surface,
                  scheme.surfaceContainerHighest,
                ],
              )
            : LinearGradient(
                colors: [scheme.surface, scheme.surfaceContainerHighest],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
      ),
    );
  }

  // ------------------ Vinyl Disc ------------------
  Widget _buildVinylDisc(int id, ColorScheme scheme) {
    const double size = 300;
    const double artSize = 200;
    final grooveColor = scheme.onSurface.withValues(alpha: 0.08);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
            ),
          ),

          // Grooves
          ...List.generate(
            12,
            (i) {
              final val = size - 10 - (i * 10);
              return Container(
                width: val,
                height: val,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: grooveColor,
                    width: 0.5,
                  ),
                ),
              );
            },
          ),

          ClipOval(
            child: QueryArtworkWidget(
              id: id,
              type: ArtworkType.AUDIO,
              artworkHeight: artSize,
              artworkWidth: artSize,
              nullArtworkWidget: Container(
                width: artSize,
                height: artSize,
                color: scheme.onSurface.withValues(alpha: 0.2),
                child: Icon(Icons.music_note,
                    size: 60, color: scheme.onSurface),
              ),
            ),
          ),

          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.surface,
              border:
                  Border.all(color: scheme.onSurface, width: 1.4),
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
                border: Border.all(color: armColor.withValues(alpha: 0.3), width: 2),
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
                borderRadius: BorderRadius.circular(4),
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
                  borderRadius: BorderRadius.circular(4),
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
          builder: (_, data, _) {
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
          icon: Icon(Icons.skip_previous_rounded,
              color: scheme.onSurface),
          onPressed: c.previous,
        ),

        Selector<AudioPlayerController, bool>(
          selector: (_, p) => p.isPlaying,
          builder: (_, isPlaying, _) => IconButton(
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
          icon: Icon(Icons.skip_next_rounded, color: scheme.onSurface),
          onPressed: c.next,
        ),

        const SizedBox(width: 16),

        IconButton(
          iconSize: 30,
          icon: Icon(Icons.queue_music_rounded,
              color: scheme.onSurfaceVariant),
          onPressed: () => _openQueue(context),
        ),
      ],
    );
  }
}
