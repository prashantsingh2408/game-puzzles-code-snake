import 'package:flutter/material.dart';

class GameSettings {
  static final GameSettings _instance = GameSettings._internal();
  factory GameSettings() => _instance;
  GameSettings._internal() {
    // Initialize default values
    snakeColor = Colors.green;
  }

  bool timerMode = false;
  int timerDuration = 10;
  double gameSpeed = 1.0;
  bool wallCollision = false;
  bool selfCollision = true;
  Color snakeColor = Colors.green;

  void updateSettings({
    bool? timerMode,
    int? timerDuration,
    double? gameSpeed,
    bool? wallCollision,
    bool? selfCollision,
    Color? snakeColor,
  }) {
    this.timerMode = timerMode ?? this.timerMode;
    this.timerDuration = timerDuration ?? this.timerDuration;
    this.gameSpeed = gameSpeed ?? this.gameSpeed;
    this.wallCollision = wallCollision ?? this.wallCollision;
    this.selfCollision = selfCollision ?? this.selfCollision;
    this.snakeColor = snakeColor ?? this.snakeColor;
  }
} 