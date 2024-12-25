# Snake Game Implementation

A classic Snake game built with Flutter and Flame engine.

## Project Structure

### Core Game Files
- `snake_game.dart` - Main game class handling game loop, input and rendering
- `snake.dart` - Snake entity with movement and collision logic
- `food.dart` - Food entity that snake collects
- `game_settings.dart` - Game configuration and settings

### Constants
- `game_constants.dart` - Game-wide constants and enums

### UI Components  
- `game_overlay.dart` - HUD overlay with score and settings
- `score_display.dart` - Score UI widget
- `timer_display.dart` - Timer UI widget
- `settings_menu.dart` - Game settings menu

## Features
- Smooth snake movement with segment following
- Touch/swipe and keyboard controls
- Score tracking
- Timer mode with countdown
- Configurable settings:
  - Game speed
  - Wall collision
  - Self collision
  - Timer mode

## Implementation Details

### Snake Movement
The snake moves continuously in the current direction. Each segment follows the one in front of it with smooth interpolation.

### Collision Detection
- Food collection checked via distance between snake head and food
- Self collision checked between head and all body segments
- Optional wall collision with screen boundaries

### Controls
- Swipe/drag gestures for touch input
- Arrow keys for keyboard input
- Direction changes prevented from reversing directly

### Rendering
- Snake drawn as connected segments with smooth curves
- Glowing head effect
- Food with pulsing glow effect
- Clean minimal UI overlay
