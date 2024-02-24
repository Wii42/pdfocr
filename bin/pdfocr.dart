import 'package:pdfocr/pdfocr.dart';

void main([List<String> args = const <String>[]]) async {
  //List<String> a = ['This is a test-\ning text','test-\n\ring'];
  //print(a);
  //OcrBatchOutputCleaner cleaner = OcrBatchOutputCleaner(a);
  //cleaner.clean();
  //print(cleaner.texts);
  String inputFile =
      'assets\\test_files\\Clark-Preussen_und_der_deutsche_Sonderweg.pdf[0]';
  PdfOcr pdfOcr = PdfOcr(
      inputFile: inputFile, deleteTempFiles: false, overrideTempFiles: true);
  List<String> result = await pdfOcr.run();
  OcrBatchOutputCleaner cleaner = OcrBatchOutputCleaner(result);
  cleaner.clean();
  print(cleaner.texts
      .join('\n--------------------------------------------------\n'));
}

class OcrOutputCleaner {
  String text;

  OcrOutputCleaner(this.text);

  void removeHyphenation() {
    text = text.replaceAllMapped(RegExp(r'(\w+)-\n(\s*)(?=\w+)'), (match) {
      print(match.groups([for (int i = 0; i < match.groupCount; i++) i]));
      if (match.group(0)?.endsWith('\n\n') ?? false) {
        return match.group(0) ?? '';
      }
      return match.group(1) ?? '';
    });

    text = text.replaceAllMapped(RegExp(r'(\w+)-\n\r(\s*)(?=\w+)'), (match) {
      if (match.group(0)?.endsWith('\n\r\n\r') ?? false) {
        return match.group(0) ?? '';
      }
      return match.group(1) ?? '';
    });

    text = text.replaceAllMapped(
        RegExp('(\w+)-${String.fromCharCode(10)}(\s*)(?=\w+)'), (match) {
      if (match.group(0)?.endsWith('\n\n') ?? false) {
        return match.group(0) ?? '';
      }
      return match.group(1) ?? '';
    });
  }

  void removeSingleNewLine() {
    text = text.replaceAllMapped(RegExp(r'(\w+)\n(\w+)'), (match) {
      print(match.groups([for (int i = 0; i < match.groupCount; i++) i]));
      if (match.group(0)?.endsWith('\n\n') ?? false) {
        return match.group(0) ?? '';
      }
      return match.group(1) ?? '';
    });
  }

  void clean() {
    removeHyphenation();
    removeSingleNewLine();
    Pattern p = '\n';
    Match m = p.allMatches(text).toList()[10];
    print('______________________');
    print(text.substring(m.start - 2, m.end + 2));
    print('______________________');
    print(text.codeUnitAt(m.start));
    print(text.codeUnitAt(m.start + 1));
  }
}

class OcrBatchOutputCleaner {
  List<String> texts;

  OcrBatchOutputCleaner(this.texts);

  void clean() {
    for (int i = 0; i < texts.length; i++) {
      OcrOutputCleaner cleaner = OcrOutputCleaner(texts[i]);
      cleaner.clean();
      texts[i] = cleaner.text;
    }
  }
}
