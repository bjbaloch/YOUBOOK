part of login_screen;

// Simple debouncer for real-time validation
class Debouncer {
  Debouncer(this.ms);
  final int ms;
  Timer? _timer;
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: ms), action);
  }

  void dispose() => _timer?.cancel();
}

// Regex patterns - matching signup validation
final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

// Email auto-correction method
String _canonicalEmail(String s) => s.trim().toLowerCase();
