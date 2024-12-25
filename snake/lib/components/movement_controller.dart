import 'package:flame/components.dart';
import '../constants/game_constants.dart';

class MovementController {
  Vector2 velocity;
  Direction currentDirection;

  MovementController() 
    : velocity = Vector2(0, GameConstants.moveSpeed),
      currentDirection = Direction.up;

  void updateDirection(Direction newDirection) {
    if (_isValidDirectionChange(newDirection)) {
      currentDirection = newDirection;
      _updateVelocity();
    }
  }

  bool _isValidDirectionChange(Direction newDirection) {
    return !((currentDirection == Direction.up && newDirection == Direction.down) ||
            (currentDirection == Direction.down && newDirection == Direction.up) ||
            (currentDirection == Direction.left && newDirection == Direction.right) ||
            (currentDirection == Direction.right && newDirection == Direction.left));
  }

  void _updateVelocity() {
    switch (currentDirection) {
      case Direction.up:
        velocity = Vector2(0, -GameConstants.moveSpeed);
        break;
      case Direction.down:
        velocity = Vector2(0, GameConstants.moveSpeed);
        break;
      case Direction.left:
        velocity = Vector2(-GameConstants.moveSpeed, 0);
        break;
      case Direction.right:
        velocity = Vector2(GameConstants.moveSpeed, 0);
        break;
    }
  }
} 