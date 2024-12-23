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

class SnakeGame extends FlameGame with KeyboardEvents, PanDetector {
  late Snake snake;
  late Food food;
  GameState gameState = GameState.playing;
  int score = 0;
  final random = Random();
  final GameSettings settings = GameSettings();
  async.Timer? gameTimer;
  int remainingTime = 0;
  Function? onTimerChanged;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    snake = Snake(
      position: Vector2(size.x / 2, size.y / 2),
      tileSize: size.x / 30,
    );
    food = Food(tileSize: size.x / 30);
    spawnFood();
    startGame();
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
    score = 0;
    gameState = GameState.playing;
    spawnFood();
    startGame();
  }

  @override
  void update(double dt) {
    if (gameState != GameState.playing) return;
    
    snake.update(dt, size);
    
    if (snake.checkFoodCollision(food.position)) {
      score += 10;
      if (settings.timerMode) {
        score += remainingTime * 2;
      }
      spawnFood();
      snake.grow();
    }
    
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
    remainingTime = settings.timerDuration;
    gameTimer = async.Timer.periodic(Duration(seconds: 1), (timer) {
      remainingTime--;
      onTimerChanged?.call();
      if (remainingTime <= 0) {
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

    snake.render(canvas);
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
    return remainingTime.toString();
  }
}