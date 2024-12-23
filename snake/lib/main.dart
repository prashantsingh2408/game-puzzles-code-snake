import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: GameWidget(
          game: SnakeGame(),
        ),
      ),
    );
  }
}

enum GameState { playing, paused, gameOver }

class SnakeGame extends FlameGame with KeyboardEvents, PanDetector, TapDetector {
  // Game constants
  static const moveSpeed = 200.0;
  static const turnSpeed = 0.3;
  static const segmentSpacing = 20.0;
  static const glowStrength = 3.0;
  static const smoothingFactor = 0.8;
  
  // Visual properties
  late double tileSize;
  final snakeHeadColor = const Color(0xFF00FF88);
  final snakeBodyColor = const Color(0xFF00CC66);
  final gameBackgroundColor = const Color(0xFF1A1F2B);
  
  // Game state
  GameState gameState = GameState.playing;
  int score = 0;
  final random = Random();
  late Vector2 food;
  
  // Snake properties
  late List<Vector2> segmentPositions;
  late Vector2 velocity;
  late double currentAngle;

  // Add direction tracking
  Vector2 targetDirection = Vector2(0, 1);
  bool isChangingDirection = false;

  @override
  Future<void> onLoad() async {
    tileSize = size.x / 30;
    
    // Initialize with continuous positions
    final centerX = size.x / 2;
    final centerY = size.y / 2;
    
    segmentPositions = List.generate(5, (i) => 
      Vector2(centerX, centerY + i * segmentSpacing)
    );
    
    velocity = Vector2(0, moveSpeed);
    currentAngle = 0;
    spawnFood();
  }

  void gameOver() {
    gameState = GameState.gameOver;
    // Reset game after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      resetGame();
    });
  }

  void resetGame() {
    final centerX = size.x / 2;
    final centerY = size.y / 2;
    
    segmentPositions = List.generate(5, (i) => 
      Vector2(centerX, centerY + i * segmentSpacing)
    );
    
    velocity = Vector2(0, moveSpeed);
    currentAngle = 0;
    score = 0;
    gameState = GameState.playing;
    spawnFood();
  }

  @override
  void update(double dt) {
    if (gameState != GameState.playing) return;

    // Update head position
    final head = segmentPositions.last;
    final newHead = head + velocity * dt;
    
    // Screen wrapping
    if (newHead.x < 0) newHead.x = size.x;
    if (newHead.x > size.x) newHead.x = 0;
    if (newHead.y < 0) newHead.y = size.y;
    if (newHead.y > size.y) newHead.y = 0;
    
    // Update segments with improved following
    for (var i = 0; i < segmentPositions.length - 1; i++) {
      final target = segmentPositions[i + 1];
      final current = segmentPositions[i];
      final direction = target - current;
      final distance = direction.length;
      
      if (distance > segmentSpacing) {
        direction.normalize();
        final smoothedDistance = (distance - segmentSpacing) * smoothingFactor;
        segmentPositions[i] = current + direction * smoothedDistance;
      }
    }
    
    segmentPositions.last = newHead;
    
    // Check food collision
    final foodRadius = tileSize / 2;
    if ((newHead - food).length < foodRadius * 2) {
      score += 10;
      spawnFood();
      // Add new segment
      final lastSegment = segmentPositions.first;
      final direction = (segmentPositions[1] - lastSegment).normalized();
      segmentPositions.insert(0, lastSegment - direction * segmentSpacing);
    }
    
    // Check self collision
    for (var i = 0; i < segmentPositions.length - 2; i++) {
      if ((newHead - segmentPositions[i]).length < tileSize / 2) {
        gameOver();
        return;
      }
    }
  }

  void updateDirection(Vector2 newDirection) {
    if (newDirection.length2 > 0) {
      // Prevent opposite direction movement
      final dot = newDirection.dot(velocity.normalized());
      if (dot < -0.5) return; // Prevent 180-degree turns
      
      targetDirection = newDirection.normalized();
      
      // Direct velocity update for more responsive controls
      velocity = targetDirection * moveSpeed;
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      if (gameState != GameState.playing) return KeyEventResult.handled;
      
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          updateDirection(Vector2(0, -1));
          break;
        case LogicalKeyboardKey.arrowDown:
          updateDirection(Vector2(0, 1));
          break;
        case LogicalKeyboardKey.arrowLeft:
          updateDirection(Vector2(-1, 0));
          break;
        case LogicalKeyboardKey.arrowRight:
          updateDirection(Vector2(1, 0));
          break;
      }
    }
    return KeyEventResult.handled;
  }

  void spawnFood() {
    food = Vector2(
      random.nextDouble() * (size.x - tileSize * 2) + tileSize,
      random.nextDouble() * (size.y - tileSize * 2) + tileSize,
    );
  }

  @override
  void render(Canvas canvas) {
    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = gameBackgroundColor,
    );

    // Draw snake with improved smoothing
    final path = Path();
    
    // Add curve tension for smoother bends
    const tension = 0.5;
    
    if (segmentPositions.length > 1) {
      path.moveTo(segmentPositions.first.x, segmentPositions.first.y);
      
      for (var i = 1; i < segmentPositions.length; i++) {
        final prev = segmentPositions[i - 1];
        final current = segmentPositions[i];
        
        if (i == 1) {
          path.lineTo(
            prev.x + (current.x - prev.x) * tension,
            prev.y + (current.y - prev.y) * tension,
          );
        } else {
          final prevMid = (segmentPositions[i - 2] + prev) / 2;
          final currentMid = (prev + current) / 2;
          
          path.cubicTo(
            prevMid.x + (prev.x - prevMid.x) * tension,
            prevMid.y + (prev.y - prevMid.y) * tension,
            prev.x,
            prev.y,
            currentMid.x,
            currentMid.y,
          );
        }
      }
    }

    // Draw snake body with anti-aliasing
    final snakePaint = Paint()
      ..color = snakeBodyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = tileSize
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    
    canvas.drawPath(path, snakePaint);

    // Draw snake head
    final headPaint = Paint()
      ..color = snakeHeadColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, glowStrength);
    
    canvas.drawCircle(
      Offset(segmentPositions.last.x, segmentPositions.last.y),
      tileSize / 2,
      headPaint,
    );

    // Draw food
    final foodPaint = Paint()
      ..color = Colors.red
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 2);
    
    canvas.drawCircle(
      Offset(food.x, food.y),
      tileSize / 2,
      foodPaint,
    );

    // Draw score
    final textPaint = TextPaint(
      style: const TextStyle(
        fontSize: 32.0,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );

    textPaint.render(
      canvas,
      'Score: $score',
      Vector2(20, 20),
    );

    if (gameState == GameState.gameOver) {
      textPaint.render(
        canvas,
        'Game Over',
        Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
      );
    }
  }
}