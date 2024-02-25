extension StringExtension on String {
  isAlphanumeric() {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }
}
