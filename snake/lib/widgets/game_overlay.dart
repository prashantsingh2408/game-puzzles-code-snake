import 'package:flutter/material.dart';
import '../game/snake_game.dart';
import 'score_display.dart';
import 'timer_display.dart';
import 'settings_menu.dart';

class GameOverlay extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              // Top row - Score and Settings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Score on left
                  Flexible(
                    child: ScoreDisplay(score: game.score),
                  ),
                  // Settings and Timer on right
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (game.settings.timerMode)
                        Flexible(
                          child: TimerDisplay(time: game.getFormattedTime()),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: IconButton(
                          padding: const EdgeInsets.all(12),
                          iconSize: 32,
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierColor: Colors.black54,
                              builder: (context) => SettingsMenu(
                                onSettingsChanged: onSettingsChanged,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Power buttons at bottom left
              Positioned(
                left: 0,
                bottom: 0,
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
                        onPressed: onSpeedUp,
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
                        onPressed: onSlowDown,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 