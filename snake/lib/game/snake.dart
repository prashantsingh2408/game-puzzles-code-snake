import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../constants/game_constants.dart';

class Snake {
  List<Vector2> segments;
  Vector2 velocity;
  final double tileSize;
  
  Snake({required Vector2 position, required this.tileSize})
      : segments = List.generate(
          5,
          (i) => position + Vector2(0, i * GameConstants.segmentSpacing),
        ),
        velocity = Vector2(0, GameConstants.moveSpeed);

  void update(double dt, Vector2 screenSize) {
    final head = segments.last;
    final newHead = head + velocity * dt;
    
    // Screen wrapping
    if (newHead.x < 0) newHead.x = screenSize.x;
    if (newHead.x > screenSize.x) newHead.x = 0;
    if (newHead.y < 0) newHead.y = screenSize.y;
    if (newHead.y > screenSize.y) newHead.y = 0;
    
    updateSegments();
    segments.last = newHead;
  }

  void updateSegments() {
    for (var i = 0; i < segments.length - 1; i++) {
      final target = segments[i + 1];
      final current = segments[i];
      final direction = target - current;
      final distance = direction.length;
      
      if (distance > GameConstants.segmentSpacing) {
        direction.normalize();
        final smoothedDistance = (distance - GameConstants.segmentSpacing) 
            * GameConstants.smoothingFactor;
        segments[i] = current + direction * smoothedDistance;
      }
    }
  }

  void updateDirection(Vector2 newDirection) {
    if (newDirection.length2 > 0) {
      final dot = newDirection.dot(velocity.normalized());
      if (dot < -0.5) return;
      velocity = newDirection.normalized() * GameConstants.moveSpeed;
    }
  }

  bool checkFoodCollision(Vector2 foodPosition) {
    return (segments.last - foodPosition).length < tileSize;
  }

  bool checkSelfCollision() {
    final head = segments.last;
    for (var i = 0; i < segments.length - 2; i++) {
      if ((head - segments[i]).length < tileSize / 2) {
        return true;
      }
    }
    return false;
  }

  void grow() {
    final lastSegment = segments.first;
    final direction = (segments[1] - lastSegment).normalized();
    segments.insert(
      0,
      lastSegment - direction * GameConstants.segmentSpacing,
    );
  }

  void reset(Vector2 position) {
    segments = List.generate(
      5,
      (i) => position + Vector2(0, i * GameConstants.segmentSpacing),
    );
    velocity = Vector2(0, GameConstants.moveSpeed);
  }

  void render(Canvas canvas) {
    final path = Path();
    
    if (segments.length > 1) {
      path.moveTo(segments.first.x, segments.first.y);
      
      for (var i = 1; i < segments.length; i++) {
        final prev = segments[i - 1];
        final current = segments[i];
        
        if (i == 1) {
          path.lineTo(
            prev.x + (current.x - prev.x) * GameConstants.tension,
            prev.y + (current.y - prev.y) * GameConstants.tension,
          );
        } else {
          final prevMid = (segments[i - 2] + prev) / 2;
          final currentMid = (prev + current) / 2;
          
          path.cubicTo(
            prevMid.x + (prev.x - prevMid.x) * GameConstants.tension,
            prevMid.y + (prev.y - prevMid.y) * GameConstants.tension,
            prev.x,
            prev.y,
            currentMid.x,
            currentMid.y,
          );
        }
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = GameColors.snakeBody
        ..style = PaintingStyle.stroke
        ..strokeWidth = tileSize
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );

    canvas.drawCircle(
      Offset(segments.last.x, segments.last.y),
      tileSize / 2,
      Paint()
        ..color = GameColors.snakeHead
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.outer,
          GameConstants.glowStrength,
        ),
    );
  }
} 