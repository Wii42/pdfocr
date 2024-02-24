import 'package:pdfocr/string_extension.dart';

class OcrResult {
  List<String> lines;
  int page;

  OcrResult(this.lines, this.page);
  factory OcrResult.fromString(String text, int page) {
    return OcrResult(
        text.trim().split('\n').map((e) => e.trim()).toList(), page);
  }

  String pageText() {
    return "${lines.join('\n')}\n${'-' * 20} $page ${'-' * 20}\n";
  }

  void removeHyphenation() {
    List<String> mergedLines = [];
    String currentLine = "";
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      if (line.endsWith("-") &&
          line.length >= 2 &&
          line[line.length - 2].isAlphanumeric()) {
        // Remove the hyphen at the end and concatenate with the next line
        currentLine += line.substring(0, line.length - 1);
      } else {
        // Append the current line to the list
        currentLine += line;
        mergedLines.add(currentLine);
        // Reset the current line for the next iteration
        currentLine = "";
      }
    }
    // If there's any leftover line not added due to no hyphenation
    if (currentLine.isNotEmpty) {
      mergedLines.add(currentLine);
    }
    lines = mergedLines;
  }

  void removeSingleNewLines() {
    List<String> mergedLines = [];
    String currentLine = "";
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      if (line.isNotEmpty) {
        currentLine += ' $line';
      } else {
        // Append the current line to the list
        mergedLines.add(currentLine);
        mergedLines.add(line);
        // Reset the current line for the next iteration
        currentLine = "";
      }
    }
    // If there's any leftover line not added due to no hyphenation
    if (currentLine.isNotEmpty) {
      mergedLines.add(currentLine);
    }
    lines = mergedLines.map((e) => e.trim()).toList();
  }

  void clean() {
    removeHyphenation();
    removeSingleNewLines();
  }
}
