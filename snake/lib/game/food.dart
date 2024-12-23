import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'dart:math';
import '../constants/game_constants.dart';

class Food {
  Vector2 position;
  final double tileSize;
  final random = Random();

  Food({required this.tileSize}) : position = Vector2.zero();

  void spawn(Vector2 screenSize, List<Vector2> snakeSegments) {
    bool validPosition;
    do {
      position = Vector2(
        random.nextDouble() * (screenSize.x - tileSize * 2) + tileSize,
        random.nextDouble() * (screenSize.y - tileSize * 2) + tileSize,
      );
      validPosition = !snakeSegments.any(
        (segment) => (segment - position).length < tileSize * 2,
      );
    } while (!validPosition);
  }

  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(position.x, position.y),
      tileSize / 2,
      Paint()
        ..color = GameColors.food
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 2),
    );
  }
} 