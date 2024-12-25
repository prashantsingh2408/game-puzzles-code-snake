import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'dart:math' as math;
import '../constants/game_constants.dart';

class FireBorder {
  final List<double> _fireOffsets = List.generate(60, (i) => math.Random().nextDouble());
  double _fireAnimationTime = 0;
  
  void update(double dt) {
    _fireAnimationTime += dt;
    for (var i = 0; i < _fireOffsets.length; i++) {
      _fireOffsets[i] = (math.sin(_fireAnimationTime * 5 + i) + 1) / 2;
    }
  }

  void render(Canvas canvas, Vector2 screenSize) {
    const numberOfFlames = 60;
    const flameHeight = 15.0;
    
    final gameWidth = screenSize.x;
    final gameHeight = screenSize.y;

    // Draw the base border
    final borderPaint = Paint()
      ..color = const Color(0xFF8B0000)  // Dark red border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw border exactly at the edges
    canvas.drawRect(
      Rect.fromLTWH(0, 0, gameWidth, gameHeight),
      borderPaint,
    );

    // Draw animated flames
    final flamePaint = Paint()
      ..color = const Color(0xFFFF5722)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 2);

    // Draw flames for each border separately
    for (var i = 0; i < numberOfFlames; i++) {
      final progress = i / numberOfFlames;
      
      // Top border - flames point down
      _drawFlame(canvas, progress * gameWidth, 0, flameHeight, flamePaint, true, i);
      
      // Bottom border - flames point up
      _drawFlame(canvas, progress * gameWidth, gameHeight, -flameHeight, flamePaint, true, i);
      
      // Left border - flames point right
      _drawFlame(canvas, 0, progress * gameHeight, flameHeight, flamePaint, true, i, isVertical: true);
      
      // Right border - flames point left
      _drawFlame(canvas, gameWidth, progress * gameHeight, -flameHeight, flamePaint, true, i, isVertical: true);
    }
  }

  void _drawFlame(Canvas canvas, double x, double y, double size, Paint paint, bool fill, int index, {bool isVertical = false}) {
    final path = Path();
    final flameSize = size.abs() * (0.5 + _fireOffsets[index % _fireOffsets.length]);
    
    if (isVertical) {
      path.moveTo(x, y);
      if (size > 0) { // Left border
        path.lineTo(x + flameSize, y);
        path.lineTo(x, y + flameSize * 0.3);
      } else { // Right border
        path.lineTo(x - flameSize, y);
        path.lineTo(x, y + flameSize * 0.3);
      }
      if (fill) {
        path.close();
      }
    } else {
      path.moveTo(x, y);
      if (size > 0) { // Top border
        path.lineTo(x, y + flameSize);
        path.lineTo(x + flameSize * 0.3, y);
      } else { // Bottom border
        path.lineTo(x, y - flameSize);
        path.lineTo(x + flameSize * 0.3, y);
      }
      if (fill) {
        path.close();
      }
    }
    canvas.drawPath(path, paint);
  }

  bool checkCollision(Vector2 position, Vector2 screenSize) {
    // Check if position is outside or exactly on the boundary
    return position.x <= 0 || 
           position.x >= screenSize.x || 
           position.y <= 0 || 
           position.y >= screenSize.y;
  }
} 