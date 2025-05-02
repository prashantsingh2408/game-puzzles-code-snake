import 'package:flutter/material.dart';
import 'package:flame/components.dart';

class CoordinatesDisplay extends StatelessWidget {
  final Vector2 position;
  final bool isInfiniteMode;
  final Vector2 worldOffset;

  CoordinatesDisplay({
    super.key, 
    required this.position,
    this.isInfiniteMode = false,
    Vector2? worldOffset,
  }) : this.worldOffset = worldOffset ?? Vector2.zero();

  @override
  Widget build(BuildContext context) {
    // Calculate the actual position considering infinite mode
    final displayPosition = isInfiniteMode ? position - worldOffset : position;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${displayPosition.x.toInt()}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            ',',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${displayPosition.y.toInt()}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 