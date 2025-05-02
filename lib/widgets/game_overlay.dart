import 'package:flutter/material.dart';
import '../game/snake_game.dart';
import 'score_display.dart';
import 'timer_display.dart';
import 'settings_menu.dart';
import 'coordinates_display.dart';
import 'package:flame/components.dart';

class GameOverlay extends StatefulWidget {
  final SnakeGame game;
  final VoidCallback onSettingsChanged;
  final VoidCallback onSpeedUp;
  final VoidCallback onSlowDown;

  const GameOverlay({
    super.key,
    required this.game,
    required this.onSettingsChanged,
    required this.onSpeedUp,
    required this.onSlowDown,
  });

  @override
  State<GameOverlay> createState() => _GameOverlayState();
}

class _GameOverlayState extends State<GameOverlay> {
  late Stream<Vector2> positionStream;

  @override
  void initState() {
    super.initState();
    // Create a stream that updates every frame
    positionStream = Stream.periodic(
      const Duration(milliseconds: 16), // ~60fps
      (_) => widget.game.snake.segments.last,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Top info bar with consistent height and background
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Left side - Score and Health
                        Expanded(
                          flex: 2, // Give more space to score/health
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 55),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 28, // Slightly more height for score
                                  child: ScoreDisplay(scoreManager: widget.game.scoreManager),
                                ),
                                const SizedBox(height: 2),
                                // Health display
                                SizedBox(
                                  height: 22, // Slightly more height for health
                                  child: ValueListenableBuilder<int>(
                                    valueListenable: widget.game.snake.healthNotifier,
                                    builder: (context, health, child) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(
                                          widget.game.snake.maxHealth,
                                          (index) => Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 2),
                                            child: Icon(
                                              index < health ? Icons.favorite : Icons.favorite_border,
                                              color: Colors.red,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Center - Level
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Level ${widget.game.obstacleManager.currentLevel}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        // Right side - Coordinates and Settings
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (widget.game.settings.infiniteViewport)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: StreamBuilder<Vector2>(
                                    stream: positionStream,
                                    builder: (context, snapshot) {
                                      return CoordinatesDisplay(
                                        position: snapshot.data ?? Vector2.zero(),
                                        isInfiniteMode: widget.game.settings.infiniteViewport,
                                        worldOffset: widget.game.worldOffset,
                                      );
                                    },
                                  ),
                                ),
                              if (widget.game.settings.timerMode)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: TimerDisplay(time: widget.game.getFormattedTime()),
                                ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.settings, color: Colors.white),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => SettingsMenu(
                                      onSettingsChanged: widget.onSettingsChanged,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Power buttons at bottom left
              Positioned(
                left: 16,
                bottom: 16,
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: IconButton(
                        padding: const EdgeInsets.all(12),
                        iconSize: 32,
                        icon: const Icon(Icons.speed, color: Colors.white),
                        onPressed: widget.onSpeedUp,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: IconButton(
                        padding: const EdgeInsets.all(12),
                        iconSize: 32,
                        icon: const Icon(Icons.slow_motion_video, color: Colors.white),
                        onPressed: widget.onSlowDown,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}