extension StringExtension on String {
  bool isAlphanumeric() {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }

  String indent(int count) {
    List<String> lines = split('\n');
    return lines.map((e) => ' ' * count + e).join('\n');
  }

  bool isNumber() {
    return RegExp(r"^[-.,'0-9]+$").hasMatch(this);
  }

  bool isNumeric() {
    return RegExp(r"^[0-9]+$").hasMatch(this);
  }
}
