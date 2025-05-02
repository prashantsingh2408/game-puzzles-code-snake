import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'dart:math';
import 'game_settings.dart';

class Obstacle {
  final Vector2 position;
  final Vector2 size;
  final Color color;
  final Paint _paint;
  final Paint _shadowPaint;
  final List<Offset> _rockPattern;
  static final Random _random = Random();
  static const double COLLISION_BUFFER = 25.0; // Increased buffer zone for more noticeable collisions

  Obstacle({
    required this.position,
    required this.size,
    this.color = const Color(0xFF696969), // Dark gray color for rocks
  }) : _paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill,
      _shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..style = PaintingStyle.fill,
      _rockPattern = _generateRockPattern();

  static List<Offset> _generateRockPattern() {
    final points = <Offset>[];
    final segments = 8; // Number of points to create rock shape
    
    for (var i = 0; i < segments; i++) {
      final angle = (i / segments) * 2 * pi;
      final variance = 0.2 + _random.nextDouble() * 0.3; // Random variance for natural look
      final x = cos(angle) * variance;
      final y = sin(angle) * variance;
      points.add(Offset(x, y));
    }
    
    return points;
  }

  bool checkCollision(Vector2 point) {
    // Calculate center of obstacle
    final centerX = position.x + size.x / 2;
    final centerY = position.y + size.y / 2;
    
    // Calculate distance from point to center
    final dx = point.x - centerX;
    final dy = point.y - centerY;
    final distance = sqrt(dx * dx + dy * dy);
    
    // Use circular collision detection with buffer and minimum size check
    final collisionRadius = max(size.x, size.y) / 2 + COLLISION_BUFFER;
    return distance < collisionRadius;
  }

  void render(Canvas canvas) {
    // Draw shadow
    canvas.save();
    canvas.translate(position.x + size.x / 2, position.y + size.y / 2);
    canvas.scale(size.x * 0.5, size.y * 0.5);
    canvas.translate(0.1, 0.1); // Offset shadow slightly
    _drawRockShape(canvas, _shadowPaint);
    canvas.restore();

    // Draw main rock
    canvas.save();
    canvas.translate(position.x + size.x / 2, position.y + size.y / 2);
    canvas.scale(size.x * 0.5, size.y * 0.5);
    _drawRockShape(canvas, _paint);
    canvas.restore();

    // Draw collision boundary for debugging
    final debugPaint = Paint()
      ..color = Colors.red.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final center = Offset(position.x + size.x / 2, position.y + size.y / 2);
    final collisionRadius = max(size.x, size.y) / 2 + COLLISION_BUFFER;
    canvas.drawCircle(
      center,
      collisionRadius,
      debugPaint
    );
  }

  void _drawRockShape(Canvas canvas, Paint paint) {
    final path = Path();
    path.moveTo(_rockPattern[0].dx, _rockPattern[0].dy);
    for (var i = 1; i < _rockPattern.length; i++) {
      path.lineTo(_rockPattern[i].dx, _rockPattern[i].dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }
}

class ObstacleManager {
  final List<Obstacle> obstacles = [];
  int currentLevel = 1;
  final Random _random = Random();
  final GameSettings settings;
  
  // Track generated chunks for infinite mode
  final Set<String> _generatedChunks = {};
  final double chunkSize = 300.0;
  
  // Constants for obstacle generation
  static const double MIN_OBSTACLE_SIZE = 25.0;
  static const double MAX_OBSTACLE_SIZE = 40.0;
  static const double MIN_OBSTACLE_SPACING = 60.0;

  ObstacleManager() : settings = GameSettings();

  bool checkCollision(Vector2 point) {
    // In infinite mode, we need to check collision against all obstacles
    // by comparing their actual positions
    return obstacles.any((obstacle) {
      final obstacleCenter = Vector2(
        obstacle.position.x + obstacle.size.x / 2,
        obstacle.position.y + obstacle.size.y / 2
      );
      
      final dx = obstacleCenter.x - point.x;
      final dy = obstacleCenter.y - point.y;
      final distance = sqrt(dx * dx + dy * dy);
      
      final collisionRadius = max(obstacle.size.x, obstacle.size.y) / 2 + Obstacle.COLLISION_BUFFER;
      return distance < collisionRadius;
    });
  }

  bool isPositionSafe(Vector2 position, double safeRadius) {
    return !obstacles.any((obstacle) {
      final obstacleCenter = Vector2(
        obstacle.position.x + obstacle.size.x / 2,
        obstacle.position.y + obstacle.size.y / 2
      );
      final dx = obstacleCenter.x - position.x;
      final dy = obstacleCenter.y - position.y;
      return sqrt(dx * dx + dy * dy) < safeRadius;
    });
  }

  void generateInfiniteObstacles(Vector2 centerPosition, Vector2 viewportSize) {
    // Calculate current chunk coordinates
    final chunkX = (centerPosition.x / chunkSize).floor();
    final chunkY = (centerPosition.y / chunkSize).floor();
    
    // Generate obstacles for surrounding chunks if not already generated
    for (var dx = -1; dx <= 1; dx++) {
      for (var dy = -1; dy <= 1; dy++) {
        final chunk = '${chunkX + dx},${chunkY + dy}';
        if (!_generatedChunks.contains(chunk)) {
          _generateChunkObstacles(
            Vector2(
              (chunkX + dx) * chunkSize,
              (chunkY + dy) * chunkSize,
            ),
            viewportSize
          );
          _generatedChunks.add(chunk);
        }
      }
    }
    
    // Remove obstacles that are too far from the center
    obstacles.removeWhere((obstacle) {
      final distance = (obstacle.position - centerPosition).length;
      return distance > chunkSize * 2;
    });
  }

  void _generateChunkObstacles(Vector2 chunkPosition, Vector2 viewportSize) {
    // Determine number of obstacles based on density setting
    final baseDensity = {
      1: 1,  // Few
      2: 2,  // Medium
      3: 4,  // Many
    }[settings.obstacleDensity] ?? 2;
    
    final numObstacles = baseDensity + _random.nextInt(2);  // Add some randomness
    
    for (var i = 0; i < numObstacles; i++) {
      var validPosition = false;
      var attempts = 0;
      late Vector2 position;
      
      while (!validPosition && attempts < 10) {
        position = Vector2(
          chunkPosition.x + _random.nextDouble() * chunkSize,
          chunkPosition.y + _random.nextDouble() * chunkSize,
        );
        
        // Check if position is far enough from other obstacles
        validPosition = obstacles.every((other) =>
          (other.position - position).length > MIN_OBSTACLE_SPACING
        );
        
        attempts++;
      }
      
      if (validPosition) {
        final size = Vector2.all(
          MIN_OBSTACLE_SIZE + _random.nextDouble() * (MAX_OBSTACLE_SIZE - MIN_OBSTACLE_SIZE)
        );
        
        obstacles.add(Obstacle(
          position: position,
          size: size,
        ));
      }
    }
  }

  void generateLevel(Vector2 viewportSize) {
    obstacles.clear();
    
    // Base number of obstacles on level and density setting
    final baseDensity = {
      1: 2,  // Few
      2: 3,  // Medium
      3: 5,  // Many
    }[settings.obstacleDensity] ?? 3;
    
    final numObstacles = (baseDensity + currentLevel - 1) * 2;
    
    for (var i = 0; i < numObstacles; i++) {
      var validPosition = false;
      var attempts = 0;
      late Vector2 position;
      
      while (!validPosition && attempts < 10) {
        position = Vector2(
          _random.nextDouble() * viewportSize.x,
          _random.nextDouble() * viewportSize.y,
        );
        
        // Check if position is far enough from other obstacles
        validPosition = obstacles.every((other) =>
          (other.position - position).length > MIN_OBSTACLE_SPACING
        );
        
        attempts++;
      }
      
      if (validPosition) {
        final size = Vector2.all(
          MIN_OBSTACLE_SIZE + _random.nextDouble() * (MAX_OBSTACLE_SIZE - MIN_OBSTACLE_SIZE)
        );
        
        obstacles.add(Obstacle(
          position: position,
          size: size,
        ));
      }
    }
  }

  void clearInfiniteMode() {
    obstacles.clear();
    _generatedChunks.clear();
  }

  void nextLevel() {
    currentLevel++;
  }

  void render(Canvas canvas) {
    for (final obstacle in obstacles) {
      obstacle.render(canvas);
    }
  }
} 