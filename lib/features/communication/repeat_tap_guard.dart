/// Blocks accidental fast double-taps of the *same* pictogram when composing
/// the bande-phrase, while still allowing a deliberate repeat after a short
/// pause. Users may have motor difficulties (CDC 3.1), so an unintended second
/// tap should not add the word twice.
class RepeatTapGuard {
  RepeatTapGuard({this.window = const Duration(milliseconds: 400)});

  /// Minimum gap below which a repeat of the same id is treated as accidental.
  final Duration window;

  int? _lastId;
  DateTime? _lastAt;

  /// Returns true if the tap should be accepted, false if it is an accidental
  /// fast repeat of the same [id]. A different pictogram is always accepted.
  bool accept(int id, {DateTime? now}) {
    final at = now ?? DateTime.now();
    if (_lastId == id &&
        _lastAt != null &&
        at.difference(_lastAt!) < window) {
      return false;
    }
    _lastId = id;
    _lastAt = at;
    return true;
  }
}
