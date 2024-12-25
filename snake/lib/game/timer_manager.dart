class TimerManager {
  int _remainingTime = 0;
  Function? onTimerChanged;
  
  int get remainingTime => _remainingTime;
  set remainingTime(int value) {
    _remainingTime = value;
    onTimerChanged?.call();
  }
} 