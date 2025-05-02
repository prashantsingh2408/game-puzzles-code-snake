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
  Color color;
  
  // Add health system
  int maxHealth = 5;
  final ValueNotifier<int> _healthNotifier = ValueNotifier<int>(5);
  bool isInvulnerable = false;
  double invulnerableTimer = 0;
  static const double INVULNERABLE_DURATION = 1.5; // seconds of invulnerability after hit
  
  // Add new property for fire effect
  final List<double> _fireOffsets = List.generate(60, (i) => math.Random().nextDouble());
  double _fireAnimationTime = 0;

  // Make fireBorder public
  final FireBorder fireBorder = FireBorder();

  Snake({
    required Vector2 position, 
    required this.tileSize,
    required this.settings,
    required Color color,
  })  : this.color = color,
        segments = List.generate(
          5,
          (i) => position + Vector2(0, i * GameConstants.segmentSpacing),
        ),
        velocity = Vector2(0, GameConstants.moveSpeed),
        direction = Direction.up;

  int get health => _healthNotifier.value;
  ValueNotifier<int> get healthNotifier => _healthNotifier;

  void takeDamage() {
    if (!isInvulnerable) {
      _healthNotifier.value--;
      isInvulnerable = true;
      invulnerableTimer = INVULNERABLE_DURATION;
      
      // Make the snake flash red when taking damage
      color = Colors.red;
      Future.delayed(const Duration(milliseconds: 100), () {
        if (isInvulnerable) {
          color = settings.snakeColor;
        }
      });
    }
  }

  void update(double dt, Vector2 screenSize) {
    fireBorder.update(dt);
    
    // Update invulnerability timer
    if (isInvulnerable) {
      invulnerableTimer -= dt;
      if (invulnerableTimer <= 0) {
        isInvulnerable = false;
      }
    }
    
    final head = segments.last;
    final newHead = head + velocity * dt;
    
    // Handle wall collision based on settings and viewport mode
    if (_handleWallCollision(newHead, screenSize)) {
      return;
    }
    
    updateSegments();
    segments.last = newHead;
  }

  bool _handleWallCollision(Vector2 newHead, Vector2 screenSize) {
    // In infinite mode, no wall collision or wrapping
    if (settings.infiniteViewport) {
      return false;
    }

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
    
    // If wall collision is disabled, wrap around (only in fixed viewport mode)
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
    final head = segments.last;
    final collisionDistance = tileSize * 1.2; // Slightly larger collision area for better gameplay
    return (head - foodPosition).length < collisionDistance;
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
    _healthNotifier.value = maxHealth;
    isInvulnerable = false;
    invulnerableTimer = 0;
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

    // Draw snake body with flashing effect when invulnerable
    final bodyPaint = Paint()
      ..color = isInvulnerable ? 
          color.withOpacity((math.sin(invulnerableTimer * 10) + 1) / 2) : 
          color
      ..style = PaintingStyle.stroke
      ..strokeWidth = tileSize
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    canvas.drawPath(path, bodyPaint);

    // Draw snake head
    final headPaint = Paint()
      ..color = isInvulnerable ? 
          GameColors.snakeHead.withOpacity((math.sin(invulnerableTimer * 10) + 1) / 2) : 
          GameColors.snakeHead
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.outer,
        GameConstants.glowStrength,
      );

    canvas.drawCircle(
      Offset(segments.last.x, segments.last.y),
      tileSize / 2,
      headPaint,
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