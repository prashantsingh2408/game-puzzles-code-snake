class ScoreManager {
  int _score = 0;
  
  int get score => _score;
  set score(int value) => _score = value;
  
  void addPoints(int points) {
    _score += points;
  }
} 