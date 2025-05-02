import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'dart:math';
import '../constants/game_constants.dart';

class Food {
  Vector2 position;
  final double tileSize;
  bool isInfiniteMode = false;
  final Random _random = Random();
  final Paint _paint = Paint()..color = Colors.red;
  
  Food({
    required this.tileSize,
  }) : position = Vector2.zero();

  void spawn(Vector2 gameSize, List<Vector2> snakeSegments) {
    // Make sure food doesn't spawn on snake
    bool validPosition;
    do {
      position = Vector2(
        _random.nextDouble() * (gameSize.x - tileSize * 2) + tileSize,
        _random.nextDouble() * (gameSize.y - tileSize * 2) + tileSize,
      );
      
      validPosition = true;
      for (final segment in snakeSegments) {
        if ((segment - position).length < tileSize) {
          validPosition = false;
          break;
        }
      }
    } while (!validPosition);
  }

  void render(Canvas canvas) {
    // Make food larger in infinite mode for easier collision
    final size = isInfiniteMode ? tileSize * 2.0 : tileSize;
    
    // Draw a pulsing apple-like shape for better visibility
    canvas.save();
    canvas.translate(position.x, position.y);
    
    // Draw apple body
    _paint.color = Colors.red;
    canvas.drawCircle(Offset.zero, size / 2, _paint);
    
    // Draw stem
    _paint.color = Colors.brown;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(0, -size / 2),
        width: size / 6,
        height: size / 3
      ),
      _paint
    );
    
    // Draw leaf
    _paint.color = Colors.green;
    final leafPath = Path()
      ..moveTo(size / 12, -size / 2)
      ..quadraticBezierTo(size / 3, -size / 1.5, size / 6, -size / 1.2)
      ..quadraticBezierTo(0, -size / 1.4, size / 12, -size / 2);
    canvas.drawPath(leafPath, _paint);
    
    canvas.restore();
    
    // Draw collision boundary for debugging in infinite mode
    if (isInfiniteMode) {
      canvas.drawCircle(
        Offset(position.x, position.y),
        size * 1.5,
        Paint()..color = Colors.yellow.withOpacity(0.3)
      );
    }
  }
} 