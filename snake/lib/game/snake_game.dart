import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'dart:math';
import 'snake.dart';
import 'food.dart';
import '../constants/game_constants.dart';
import 'package:flutter/services.dart';

class SnakeGame extends FlameGame with KeyboardEvents, PanDetector, TapDetector {
  late Snake snake;
  late Food food;
  GameState gameState = GameState.playing;
  int score = 0;
  final random = Random();

  @override
  Future<void> onLoad() async {
    snake = Snake(
      position: Vector2(size.x / 2, size.y / 2),
      tileSize: size.x / 30,
    );
    food = Food(tileSize: size.x / 30);
    spawnFood();
  }

  void gameOver() {
    gameState = GameState.gameOver;
    Future.delayed(const Duration(seconds: 2), resetGame);
  }

  void resetGame() {
    snake.reset(Vector2(size.x / 2, size.y / 2));
    score = 0;
    gameState = GameState.playing;
    spawnFood();
  }

  @override
  void update(double dt) {
    if (gameState != GameState.playing) return;
    
    snake.update(dt, size);
    
    if (snake.checkFoodCollision(food.position)) {
      score += 10;
      spawnFood();
      snake.grow();
    }
    
    if (snake.checkSelfCollision()) {
      gameOver();
    }
  }

  void spawnFood() {
    food.spawn(size, snake.segments);
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

    textPaint.render(canvas, 'Score: $score', Vector2(20, 20));

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
} 