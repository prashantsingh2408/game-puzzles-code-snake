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

class SnakeGame extends FlameGame with KeyboardEvents, PanDetector {
  GameState gameState = GameState.playing;
  final GameSettings settings;
  final ScoreManager scoreManager;
  final TimerManager timerManager;
  async.Timer? gameTimer;
  
  late final Snake snake;
  late final Food food;

  double normalSpeed = 1.0;
  double currentSpeed = 1.0;
  async.Timer? powerUpTimer;

  SnakeGame()
    : settings = GameSettings(),
      scoreManager = ScoreManager(),
      timerManager = TimerManager();

  set onTimerChanged(Function? callback) {
    timerManager.onTimerChanged = callback;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initializeGameComponents();
    startGame();
  }

  void _initializeGameComponents() {
    snake = Snake(
      position: Vector2(size.x / 2, size.y / 2),
      tileSize: size.x / 30,
      settings: settings,
      color: settings.snakeColor,
    );
    food = Food(tileSize: size.x / 30);
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
    scoreManager.score = 0;
    gameState = GameState.playing;
    spawnFood();
    startGame();
    timerManager.onTimerChanged?.call();
  }

  @override
  void update(double dt) {
    if (gameState != GameState.playing) return;
    
    snake.color = settings.snakeColor;
    
    snake.update(dt * currentSpeed, size);
    
    if (snake.checkFoodCollision(food.position)) {
      scoreManager.score += 10;
      if (settings.timerMode) {
        scoreManager.score += timerManager.remainingTime * 2;
      }
      spawnFood();
      snake.grow();
      timerManager.onTimerChanged?.call();
    }
    
    // Check for wall collision game over
    if (settings.wallCollision && snake.fireBorder.checkCollision(snake.segments.last, size)) {
      gameOver();
      return;
    }
    
    // Check for self collision
    if (settings.selfCollision && snake.checkSelfCollision()) {
      gameOver();
    }
  }

  void spawnFood() {
    food.spawn(size, snake.segments);
    if (settings.timerMode) {
      resetFoodTimer();
    }
  }

  void resetFoodTimer() {
    gameTimer?.cancel();
    timerManager.remainingTime = settings.timerDuration;
    gameTimer = async.Timer.periodic(const Duration(seconds: 1), (timer) {
      timerManager.remainingTime--;
      timerManager.onTimerChanged?.call();
      if (timerManager.remainingTime <= 0) {
        gameOver();
      }
    });
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = GameColors.background,
    );

    snake.render(canvas, size);
    food.render(canvas);
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
      textPaint.render(
        canvas,
        'Game Over',
        Vector2(size.x / 2, size.y / 2),
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
}