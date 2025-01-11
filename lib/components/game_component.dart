import 'package:flame/components.dart';

/// Base class for all game components
abstract class GameComponent {
  void update(double dt);
  void render(Canvas canvas);
} 