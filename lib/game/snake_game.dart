import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'dart:math';
import 'snake.dart';
import 'food.dart';
import '../constants/game_constants.dart';
import 'package:flutter/services.dart';
import 'game_settings.dart';
import 'dart:async' as async;
import 'score_manager.dart';
import 'timer_manager.dart';
import 'package:flame/extensions.dart';
import 'obstacle.dart';

// Create a component to handle game state
class GameStateComponent extends Component {
  final SnakeGame game;
  
  GameStateComponent(this.game);
  
  @override
  void update(double dt) {
    game.updateGameState(dt);
  }
}

class SnakeGame extends FlameGame with KeyboardEvents, PanDetector, TapDetector {
  GameState gameState = GameState.playing;
  final GameSettings settings;
  final ScoreManager scoreManager;
  final TimerManager timerManager;
  final ObstacleManager obstacleManager;
  async.Timer? gameTimer;
  final Random _random = Random();
  
  late final Snake snake;
  late final Food food;
  late final GameStateComponent _stateComponent;

  // Camera offset for infinite viewport mode
  Vector2 worldOffset = Vector2.zero();
  
  double normalSpeed = 1.0;
  double currentSpeed = 1.0;
  async.Timer? powerUpTimer;

  late Sprite backgroundSprite;

  SnakeGame()
    : settings = GameSettings(),
      scoreManager = ScoreManager(),
      timerManager = TimerManager(),
      obstacleManager = ObstacleManager() {
    _stateComponent = GameStateComponent(this);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    try {
      backgroundSprite = await loadSprite('bg.jpg');
    } catch (e) {
      print('Error loading background: $e');
    }
    
    add(_stateComponent);
    _initializeGameComponents();
    startGame();
  }

  void _initializeGameComponents() {
    // Initialize snake at the center
    snake = Snake(
      position: Vector2(size.x / 2, size.y / 2),
      tileSize: size.x / 30,
      settings: settings,
      color: settings.snakeColor,
    );
    food = Food(tileSize: size.x / 30);
    food.isInfiniteMode = settings.infiniteViewport;
    
    // Initialize first level
    obstacleManager.currentLevel = 1;
    obstacleManager.generateLevel(size);
    
    // Ensure no obstacles are near the snake's starting position
    final safeRadius = size.x / 4;
    if (!obstacleManager.isPositionSafe(snake.segments.first, safeRadius)) {
      // Regenerate obstacles if the starting position isn't safe
      obstacleManager.generateLevel(size);
    }
    
    spawnFood();
  }

  @override
  bool onPanUpdate(DragUpdateInfo info) {
    if (gameState != GameState.playing) return true;

    final delta = info.delta.global;
    // Determine if the drag is more horizontal or vertical
    if (delta.x.abs() > delta.y.abs()) {
      // Horizontal movement
      if (delta.x > 0 && snake.direction != Direction.left) {
        snake.changeDirection(Direction.right);
      } else if (delta.x < 0 && snake.direction != Direction.right) {
        snake.changeDirection(Direction.left);
      }
    } else {
      // Vertical movement
      if (delta.y > 0 && snake.direction != Direction.up) {
        snake.changeDirection(Direction.down);
      } else if (delta.y < 0 && snake.direction != Direction.down) {
        snake.changeDirection(Direction.up);
      }
    }
    return true;
  }

  void gameOver() {
    gameTimer?.cancel();
    gameState = GameState.gameOver;
    Future.delayed(const Duration(seconds: 2), resetGame);
  }

  void resetGame() {
    gameTimer?.cancel();
    snake.reset(Vector2(size.x / 2, size.y / 2));
    worldOffset = Vector2.zero();
    scoreManager.score = 0;
    gameState = GameState.playing;
    
    if (settings.infiniteViewport) {
      obstacleManager.clearInfiniteMode();
      obstacleManager.generateInfiniteObstacles(Vector2.zero(), size);
    } else {
      obstacleManager.currentLevel = 1;
      obstacleManager.generateLevel(size);
    }
    
    spawnFood();
    startGame();
  }

  void updateGameState(double dt) {
    if (gameState != GameState.playing) return;
    
    snake.color = settings.snakeColor;
    
    // Store previous position for infinite viewport mode
    final previousHeadPos = snake.segments.last.clone();
    
    // In infinite mode, use a large size for snake movement
    final effectiveSize = settings.infiniteViewport 
        ? Vector2(100000, 100000)  // Large virtual space
        : size;
    
    snake.update(dt * currentSpeed, effectiveSize);
    
    // Update world offset in infinite viewport mode
    if (settings.infiniteViewport) {
      final movement = snake.segments.last - previousHeadPos;
      worldOffset -= movement;
      
      // Update food's infinite mode flag
      food.isInfiniteMode = true;
      
      // Generate new obstacles based on snake position
      obstacleManager.generateInfiniteObstacles(
        snake.segments.last - worldOffset,  // Convert to world space
        size
      );
    } else {
    }
    
    // Check obstacle collision
    Vector2 collisionCheckPosition;
    if (settings.infiniteViewport) {
      collisionCheckPosition = snake.segments.last - worldOffset;
    } else {
      collisionCheckPosition = snake.segments.last;
    }
    
    if (obstacleManager.checkCollision(collisionCheckPosition)) {
      snake.takeDamage();
      if (snake.health <= 0) {
        gameOver();
        return;
      }
      
      // Add knockback effect when hitting obstacle
      final knockbackDistance = 30.0;
      final knockbackDirection = -snake.velocity.normalized();
      final knockbackPosition = snake.segments.last + knockbackDirection * knockbackDistance;
      
      // Check knockback collision in appropriate coordinate space
      Vector2 knockbackCheckPosition;
      if (settings.infiniteViewport) {
        knockbackCheckPosition = knockbackPosition - worldOffset;
      } else {
        knockbackCheckPosition = knockbackPosition;
      }
      
      if (!obstacleManager.checkCollision(knockbackCheckPosition)) {
        snake.segments.last = knockbackPosition;
      }
    }
    
    // Check food collision - completely rewritten for infinite mode
    bool foodEaten = false;
    if (settings.infiniteViewport) {
      // In infinite mode, directly compare snake head to food position
      final snakeHead = snake.segments.last;
      final foodPos = food.position;
      
      // Calculate distance between snake head and food using simple distance calculation
      final dx = (snakeHead.x - foodPos.x).abs();
      final dy = (snakeHead.y - foodPos.y).abs();
      final collisionDistance = snake.tileSize;
      
      // For debugging
      if (dx < collisionDistance * 2 && dy < collisionDistance * 2) {
        print("Snake near food - Snake: $snakeHead, Food: $foodPos, Distance: dx=$dx, dy=$dy");
      }
      
      // Use a simple box collision for more reliable detection
      foodEaten = dx < collisionDistance && dy < collisionDistance;
    } else {
      // Regular food collision for fixed viewport
      foodEaten = snake.checkFoodCollision(food.position);
    }
    
    if (foodEaten) {
      // Add points
      final oldScore = scoreManager.score;
      scoreManager.addPoints(10);
      print("SCORE UPDATED: $oldScore -> ${scoreManager.score}");
      
      // Add bonus points for timer
      if (settings.timerMode) {
        scoreManager.addPoints(timerManager.remainingTime * 2);
      }
      
      // Grow snake
      snake.grow();
      
      // Spawn new food
      spawnFood();
      
      // Only update level in non-infinite mode
      if (!settings.infiniteViewport && scoreManager.score >= obstacleManager.currentLevel * 50) {
        obstacleManager.nextLevel();
        obstacleManager.generateLevel(size);
      }
    }
    
    // Check wall collision only in fixed viewport mode
    if (!settings.infiniteViewport && settings.wallCollision && snake.fireBorder.checkCollision(snake.segments.last, size)) {
      snake.takeDamage();
      if (snake.health <= 0) {
        gameOver();
        return;
      }
    }
    
    if (settings.selfCollision && snake.checkSelfCollision()) {
      snake.takeDamage();
      if (snake.health <= 0) {
        gameOver();
        return;
      }
    }
  }

  void spawnFood() {
    bool validPosition;
    int attempts = 0;
    const maxAttempts = 10;
    
    do {
      attempts++;
      
      if (settings.infiniteViewport) {
        // In infinite mode, spawn food near the snake in screen space
        final spawnRadius = size.x / 4; // Spawn closer to snake
        final angle = _random.nextDouble() * 2 * pi;
        final distance = spawnRadius * 0.5 + (_random.nextDouble() * spawnRadius * 0.5);
        final offset = Vector2(
          cos(angle) * distance,
          sin(angle) * distance
        );
        
        // Spawn food relative to snake's head
        food.position = snake.segments.last + offset;
        food.isInfiniteMode = true; // Ensure food knows it's in infinite mode
        
        print('Spawned new food at ${food.position}');
      } else {
        food.isInfiniteMode = false;
        food.spawn(size, snake.segments);
      }
      
      // Check if spawn position is valid (not inside obstacles)
      Vector2 foodCheckPosition;
      if (settings.infiniteViewport) {
        foodCheckPosition = food.position - worldOffset;
      } else {
        foodCheckPosition = food.position;
      }
      validPosition = !obstacleManager.checkCollision(foodCheckPosition);
      
      // Prevent infinite loops
      if (attempts >= maxAttempts && !validPosition) {
        // Force valid position if we've tried too many times
        validPosition = true;
      }
    } while (!validPosition);
    
    if (settings.timerMode) {
      resetFoodTimer();
    }
  }

  void resetFoodTimer() {
    gameTimer?.cancel();
    timerManager.remainingTime = settings.timerDuration;
    gameTimer = async.Timer.periodic(const Duration(seconds: 1), (timer) {
      timerManager.remainingTime--;
      if (timerManager.remainingTime <= 0) {
        gameOver();
      }
    });
  }

  @override
  void render(Canvas canvas) {
    if (settings.infiniteViewport) {
      canvas.save();
      // In infinite mode, translate the world to keep snake centered
      final centerOffset = Vector2(size.x / 2, size.y / 2) - snake.segments.last;
      canvas.translate(centerOffset.x, centerOffset.y);
    }

    // Draw background
    if (settings.useBackgroundImage && backgroundSprite != null) {
      if (settings.infiniteViewport) {
        // In infinite mode, create a repeating background pattern
        final viewportRect = Rect.fromLTWH(
          snake.segments.last.x - size.x,
          snake.segments.last.y - size.y,
          size.x * 2,
          size.y * 2
        );
        
        final startX = (viewportRect.left / size.x).floor() * size.x;
        final startY = (viewportRect.top / size.y).floor() * size.y;
        final endX = ((viewportRect.right / size.x).ceil() * size.x);
        final endY = ((viewportRect.bottom / size.y).ceil() * size.y);
        
        for (var x = startX; x <= endX; x += size.x.toInt()) {
          for (var y = startY; y <= endY; y += size.y.toInt()) {
            backgroundSprite.render(
              canvas,
              position: Vector2(x.toDouble(), y.toDouble()),
              size: size,
            );
          }
        }
      } else {
        backgroundSprite.render(
          canvas,
          position: Vector2.zero(),
          size: size,
        );
      }
    } else {
      // Draw solid color background
      if (settings.infiniteViewport) {
        final viewportRect = Rect.fromLTWH(
          snake.segments.last.x - size.x,
          snake.segments.last.y - size.y,
          size.x * 2,
          size.y * 2
        );
        canvas.drawRect(viewportRect, Paint()..color = settings.backgroundColor);
      } else {
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.x, size.y),
          Paint()..color = settings.backgroundColor,
        );
      }
    }

    // Draw game elements
    if (settings.infiniteViewport) {
      canvas.save();
      canvas.translate(worldOffset.x, worldOffset.y);
      obstacleManager.render(canvas);
      canvas.restore();
      
      // Draw food in screen space, not world space
      food.render(canvas);
      snake.render(canvas, size);
    } else {
      obstacleManager.render(canvas);
      snake.render(canvas, size);
      food.render(canvas);
    }

    if (settings.infiniteViewport) {
      canvas.restore();
    }

    // UI is always drawn in screen space
    renderUI(canvas);
  }

  void renderUI(Canvas canvas) {
    final textPaint = TextPaint(
      style: const TextStyle(
        fontSize: 32.0,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );

    if (gameState == GameState.gameOver) {
      // Draw semi-transparent background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = Colors.black54,
      );

      // Draw Game Over text
      textPaint.render(
        canvas,
        'Game Over',
        Vector2(size.x / 2, size.y / 2 - 40),
        anchor: Anchor.center,
      );

      // Draw score
      final scoreText = 'Score: ${scoreManager.scoreNotifier.value}';
      textPaint.render(
        canvas,
        scoreText,
        Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
      );

      // Draw restart button
      final buttonRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.x / 2, size.y / 2 + 60),
          width: 200,
          height: 50,
        ),
        const Radius.circular(10),
      );

      canvas.drawRRect(
        buttonRect,
        Paint()..color = Colors.green,
      );

      textPaint.render(
        canvas,
        'Restart',
        Vector2(size.x / 2, size.y / 2 + 60),
        anchor: Anchor.center,
      );
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (gameState != GameState.playing) return KeyEventResult.handled;
    
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
        snake.changeDirection(Direction.up);
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
        snake.changeDirection(Direction.down);
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        snake.changeDirection(Direction.left);
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        snake.changeDirection(Direction.right);
      }
    }
    return KeyEventResult.handled;
  }

  void startGame() {
    if (settings.timerMode) {
      resetFoodTimer();
    }
  }

  String getFormattedTime() {
    if (!settings.timerMode) return '';
    return timerManager.remainingTime.toString();
  }

  int get score => scoreManager.score;

  void activateSpeedUp() {
    currentSpeed = 2.0;
    powerUpTimer?.cancel();
    powerUpTimer = async.Timer(const Duration(seconds: 10), () {
      currentSpeed = normalSpeed;
    });
  }

  void activateSlowDown() {
    currentSpeed = 0.5;
    powerUpTimer?.cancel();
    powerUpTimer = async.Timer(const Duration(seconds: 10), () {
      currentSpeed = normalSpeed;
    });
  }

  @override
  void onRemove() {
    powerUpTimer?.cancel();
    gameTimer?.cancel();
    super.onRemove();
  }

  @override
  bool onTapDown(TapDownInfo info) {
    if (gameState == GameState.gameOver) {
      // Check if tap is within restart button bounds
      final buttonRect = Rect.fromCenter(
        center: Offset(size.x / 2, size.y / 2 + 60),
        width: 200,
        height: 50,
      );

      if (buttonRect.contains(info.eventPosition.global.toOffset())) {
        resetGame();
      }
    }
    return true;
  }
}