import 'package:flutter/material.dart';

enum GameState { playing, paused, gameOver }

class GameConstants {
  static const double moveSpeed = 200.0;
  static const double turnSpeed = 0.3;
  static const double segmentSpacing = 20.0;
  static const double glowStrength = 3.0;
  static const double smoothingFactor = 0.8;
  static const double tension = 0.5;
}

class GameColors {
  static const Color snakeHead = Color(0xFF00FF88);
  static const Color snakeBody = Color(0xFF00CC66);
  static const Color background = Color(0xFF1A1F2B);
  static const Color food = Colors.red;
} 