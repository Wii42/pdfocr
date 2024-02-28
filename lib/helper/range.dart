class Range {
  final int start;
  final int end;

  /// Creates a range from start to end.
  /// Start is inclusive, end is exclusive.
  /// End must be greater than start, otherwise an [ArgumentError] is thrown.
  Range(this.start, this.end) {
    if (end <= start) {
      throw ArgumentError('end must be greater than start');
    }
  }

  bool contains(int value) => start <= value && value <= end;

  Iterable<int> get iterable sync* {
    for (int i = start; i < end; i++) {
      yield i;
    }
  }
}
