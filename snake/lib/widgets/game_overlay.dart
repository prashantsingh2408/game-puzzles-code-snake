import 'package:flutter/material.dart';
import '../game/snake_game.dart';
import 'score_display.dart';
import 'timer_display.dart';
import 'settings_menu.dart';

class GameOverlay extends StatelessWidget {
  final SnakeGame game;
  final VoidCallback onSettingsChanged;

  const GameOverlay({
    super.key,
    required this.game,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: ScoreDisplay(score: game.score),
              ),
              Flexible(
                child: Row(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
} 