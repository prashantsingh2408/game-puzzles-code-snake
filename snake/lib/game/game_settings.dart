class GameSettings {
  static final GameSettings _instance = GameSettings._internal();
  factory GameSettings() => _instance;
  GameSettings._internal();

  bool timerMode = false;
  int timerDuration = 10; // Default 10 seconds to pick up food
  double gameSpeed = 1.0;
  bool wallCollision = true;

  void updateSettings({
    bool? timerMode,
    int? timerDuration,
    double? gameSpeed,
    bool? wallCollision,
  }) {
    this.timerMode = timerMode ?? this.timerMode;
    this.timerDuration = timerDuration ?? this.timerDuration;
    this.gameSpeed = gameSpeed ?? this.gameSpeed;
    this.wallCollision = wallCollision ?? this.wallCollision;
  }
} 