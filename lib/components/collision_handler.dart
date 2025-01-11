import 'package:flame/components.dart';

class CollisionHandler {
  bool checkWallCollision(Vector2 position, Vector2 screenSize) {
    return position.x <= 0 || 
           position.x >= screenSize.x || 
           position.y <= 0 || 
           position.y >= screenSize.y;
  }

  bool checkSelfCollision(List<Vector2> segments, double tileSize) {
    final head = segments.last;
    for (var i = 0; i < segments.length - 2; i++) {
      if ((head - segments[i]).length < tileSize / 2) {
        return true;
      }
    }
    return false;
  }

  bool checkFoodCollision(Vector2 snakeHead, Vector2 foodPosition, double tileSize) {
    return (snakeHead - foodPosition).length < tileSize;
  }
} 