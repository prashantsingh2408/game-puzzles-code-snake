import 'package:flutter/material.dart';

class GameSettings {
  static final GameSettings _instance = GameSettings._internal();
  factory GameSettings() => _instance;
  GameSettings._internal() {
    // Initialize default values
    snakeColor = Colors.green;
    backgroundColor = Colors.black;
    useBackgroundImage = true;
  }

  bool timerMode = false;
  int timerDuration = 10;
  double gameSpeed = 1.0;
  bool wallCollision = false;
  bool selfCollision = true;
  Color snakeColor = Colors.green;
  Color backgroundColor = Colors.black;
  bool useBackgroundImage = true;

  void updateSettings({
    bool? timerMode,
    int? timerDuration,
    double? gameSpeed,
    bool? wallCollision,
    bool? selfCollision,
    Color? snakeColor,
    Color? backgroundColor,
    bool? useBackgroundImage,
  }) {
    this.timerMode = timerMode ?? this.timerMode;
    this.timerDuration = timerDuration ?? this.timerDuration;
    this.gameSpeed = gameSpeed ?? this.gameSpeed;
    this.wallCollision = wallCollision ?? this.wallCollision;
    this.selfCollision = selfCollision ?? this.selfCollision;
    this.snakeColor = snakeColor ?? this.snakeColor;
    this.backgroundColor = backgroundColor ?? this.backgroundColor;
    this.useBackgroundImage = useBackgroundImage ?? this.useBackgroundImage;
  }
} 