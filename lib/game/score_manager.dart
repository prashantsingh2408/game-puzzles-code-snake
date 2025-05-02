import 'package:flutter/foundation.dart';

class ScoreManager {
  final ValueNotifier<int> _scoreNotifier = ValueNotifier<int>(0);
  
  int get score => _scoreNotifier.value;
  set score(int value) => _scoreNotifier.value = value;
  
  ValueNotifier<int> get scoreNotifier => _scoreNotifier;
  
  void addPoints(int points) {
    _scoreNotifier.value += points;
  }
  
  void reset() {
    _scoreNotifier.value = 0;
  }
} 