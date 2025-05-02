import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game/snake_game.dart';
import 'widgets/game_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SnakeGame game;

  @override
  void initState() {
    super.initState();
    game = SnakeGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: game,
        loadingBuilder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Colors.green,
          ),
        ),
        overlayBuilderMap: {
          'gameOverlay': (context, _) => GameOverlay(
            game: game,
            onSettingsChanged: () => game.startGame(),
            onSpeedUp: () => game.activateSpeedUp(),
            onSlowDown: () => game.activateSlowDown(),
          ),
        },
        initialActiveOverlays: const ['gameOverlay'],
      ),
    );
  }

  @override
  void dispose() {
    game.gameTimer?.cancel();
    super.dispose();
  }
}