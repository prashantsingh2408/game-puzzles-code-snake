import 'package:flutter/material.dart';

class GameSettings {
  static final GameSettings _instance = GameSettings._internal();
  factory GameSettings() => _instance;
  GameSettings._internal() {
    // Initialize default values
    snakeColor = Colors.green;
    backgroundColor = Colors.blue.shade900;
    useBackgroundImage = false;
    infiniteViewport = true;
    obstacleDensity = 1; // Default to low density (Few obstacles)
  }

  bool timerMode = false;
  int timerDuration = 10;
  double gameSpeed = 1.0;
  bool wallCollision = false;
  bool selfCollision = true;
  Color snakeColor = Colors.green;
  Color backgroundColor = Colors.blue.shade900;
  bool useBackgroundImage = false;
  bool infiniteViewport = true;
  int obstacleDensity = 1; // 1 = few, 2 = medium, 3 = many

  void updateSettings({
    bool? timerMode,
    int? timerDuration,
    double? gameSpeed,
    bool? wallCollision,
    bool? selfCollision,
    Color? snakeColor,
    Color? backgroundColor,
    bool? useBackgroundImage,
    bool? infiniteViewport,
    int? obstacleDensity,
  }) {
    this.timerMode = timerMode ?? this.timerMode;
    this.timerDuration = timerDuration ?? this.timerDuration;
    this.gameSpeed = gameSpeed ?? this.gameSpeed;
    this.wallCollision = wallCollision ?? this.wallCollision;
    this.selfCollision = selfCollision ?? this.selfCollision;
    this.snakeColor = snakeColor ?? this.snakeColor;
    this.backgroundColor = backgroundColor ?? this.backgroundColor;
    this.useBackgroundImage = useBackgroundImage ?? this.useBackgroundImage;
    this.infiniteViewport = infiniteViewport ?? this.infiniteViewport;
    this.obstacleDensity = obstacleDensity ?? this.obstacleDensity;
  }

  void copyFrom(GameSettings other) {
    wallCollision = other.wallCollision;
    selfCollision = other.selfCollision;
    infiniteViewport = other.infiniteViewport;
    timerMode = other.timerMode;
    timerDuration = other.timerDuration;
    useBackgroundImage = other.useBackgroundImage;
    backgroundColor = other.backgroundColor;
    snakeColor = other.snakeColor;
    obstacleDensity = other.obstacleDensity;
  }
} 