import 'package:pdfocr/helper/string_extension.dart';

import 'ocr_result.dart';

class OcrList {
  int titleIndentation = 2;
  String title;
  List<OcrResult> results;
  bool pageLimitMarkings;

  OcrList(this.title, this.results, {this.pageLimitMarkings = true});

  factory OcrList.fromStrings(String title, List<String> strings) {
    return OcrList(
        title,
        strings.indexed
            .map((e) => OcrResult.fromString(e.$2, e.$1 + 1))
            .toList());
  }

  String get pageTexts {
    if (results.isEmpty) {
      return ' - No pages found to parse - ';
    }
    if (results.length == 1) {
      return results.first.pageText(showPageMarkings: false);
    }
    return results
        .map((e) => e.pageText(showPageMarkings: pageLimitMarkings))
        .join('\n');
  }

  String get wholeText => "$titleRow\n$pageTexts\n$bar\n";

  String get titleRow {
    int indentation = 2;
    return "$bar\n${title.indent(indentation)}\n$bar";
  }

  String get bar => '-' * (title.length + titleIndentation * 2);

  void clean() {
    for (OcrResult result in results) {
      result.clean();
    }
  }

  void sort() {
    results.sort((a, b) => a.page.compareTo(b.page));
  }
}
