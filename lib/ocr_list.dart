import 'ocr_result.dart';

class OcrList {
  String title;
  List<OcrResult> results;

  OcrList(this.title, this.results);

  factory OcrList.fromStrings(String title, List<String> strings) {
    return OcrList(
        title,
        strings.indexed
            .map((e) => OcrResult.fromString(e.$2, e.$1 + 1))
            .toList());
  }

  String get wholeText =>
      "$titleRow\n${results.map((e) => e.pageText()).join('\n')}";

  String get titleRow => "${'-' * 40}\n$title\n${'-' * 40}\n";

  void clean() {
    for (OcrResult result in results) {
      result.clean();
    }
  }
}
