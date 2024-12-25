import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../constants/game_constants.dart';
import 'dart:math' as math;
import 'fire_border.dart';
import 'game_settings.dart';

class Snake {
  List<Vector2> segments;
  Vector2 velocity;
  final double tileSize;
  Direction direction;
  final GameSettings settings;
  
  // Add new property for fire effect
  final List<double> _fireOffsets = List.generate(60, (i) => math.Random().nextDouble());
  double _fireAnimationTime = 0;

  // Make fireBorder public
  final FireBorder fireBorder = FireBorder();

  Snake({
    required Vector2 position, 
    required this.tileSize,
    required this.settings,
  })  : segments = List.generate(
          5,
          (i) => position + Vector2(0, i * GameConstants.segmentSpacing),
        ),
        velocity = Vector2(0, GameConstants.moveSpeed),
        direction = Direction.up;

  void update(double dt, Vector2 screenSize) {
    fireBorder.update(dt);
    
    final head = segments.last;
    final newHead = head + velocity * dt;
    
    // Handle wall collision based on settings
    if (_handleWallCollision(newHead, screenSize)) {
      return;
    }
    
    updateSegments();
    segments.last = newHead;
  }

  bool _handleWallCollision(Vector2 newHead, Vector2 screenSize) {
    bool hasCollision = newHead.x < 0 || 
        newHead.x > screenSize.x - tileSize || 
        newHead.y < 0 || 
        newHead.y > screenSize.y - tileSize;

    if (!hasCollision) return false;

    // If wall collision is enabled, reset the game
    if (settings.wallCollision) {
      reset(Vector2(screenSize.x / 2, screenSize.y / 2));
      return true;
    }
    
    // If wall collision is disabled, wrap around
    if (newHead.x < 0) {
      segments.last = Vector2(screenSize.x - tileSize, newHead.y);
    } else if (newHead.x > screenSize.x - tileSize) {
      segments.last = Vector2(0, newHead.y);
    }
    
    if (newHead.y < 0) {
      segments.last = Vector2(newHead.x, screenSize.y - tileSize);
    } else if (newHead.y > screenSize.y - tileSize) {
      segments.last = Vector2(newHead.x, 0);
    }
    
    return true;
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
    direction = Direction.up;
  }

  void render(Canvas canvas, Vector2 screenSize) {
    // Draw fire border only if wall collision is enabled
    if (settings.wallCollision) {
      fireBorder.render(canvas, screenSize);
    }
    
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

  void changeDirection(Direction newDirection) {
    // Prevent 180 degree turns
    if ((direction == Direction.up && newDirection == Direction.down) ||
        (direction == Direction.down && newDirection == Direction.up) ||
        (direction == Direction.left && newDirection == Direction.right) ||
        (direction == Direction.right && newDirection == Direction.left)) {
      return;
    }
    
    direction = newDirection;
    // Update velocity based on direction
    switch (direction) {
      case Direction.up:
        velocity = Vector2(0, -GameConstants.moveSpeed);
        break;
      case Direction.down:
        velocity = Vector2(0, GameConstants.moveSpeed);
        break;
      case Direction.left:
        velocity = Vector2(-GameConstants.moveSpeed, 0);
        break;
      case Direction.right:
        velocity = Vector2(GameConstants.moveSpeed, 0);
        break;
    }
  }
} 