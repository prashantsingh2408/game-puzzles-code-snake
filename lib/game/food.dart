import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'dart:math';
import '../constants/game_constants.dart';

class Food {
  Vector2 position;
  final double tileSize;
  bool isInfiniteMode = false;
  final Random _random = Random();
  final Paint _paint = Paint();
  
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
    
    canvas.save();
    canvas.translate(position.x, position.y);
    
    // Draw mouse body (gray oval)
    _paint.color = Colors.grey.shade400;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: size,
        height: size / 1.5,
      ),
      _paint
    );
    
    // Draw mouse head
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size / 2.5, 0),
        width: size / 2,
        height: size / 2.5,
      ),
      _paint
    );
    
    // Draw mouse ears
    _paint.color = Colors.pink.shade200;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size / 2, -size / 4),
        width: size / 4,
        height: size / 4,
      ),
      _paint
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size / 2, size / 4),
        width: size / 4,
        height: size / 4,
      ),
      _paint
    );
    
    // Draw mouse tail
    _paint.color = Colors.grey.shade400;
    final tailPath = Path()
      ..moveTo(-size / 2, 0)
      ..quadraticBezierTo(-size, size / 2, -size, 0);
    canvas.drawPath(tailPath, _paint);
    
    // Draw mouse eyes
    _paint.color = Colors.black;
    canvas.drawCircle(Offset(size / 2 + size / 8, -size / 10), size / 12, _paint);
    
    canvas.restore();
  }
} 