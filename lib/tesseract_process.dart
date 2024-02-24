import 'dart:convert';
import 'dart:io';

import 'package:pdfocr/process_runner.dart';

class TesseractProcess extends ProcessRunner {
  static const String tesseractLocation = 'extern_dependencies\\Tesseract-OCR';
  String inputPath;
  String outputPath;
  String? language;

  @override
  Directory get exeLocation => Directory(tesseractLocation);
  @override
  String get exeName => 'tesseract';

  TesseractProcess(
      {required this.inputPath,
      this.outputPath = '-',
      this.language = 'deu',
      super.workingDirectory,
      Encoding? stoutEncoding})
      : super(stdoutEncoding: stoutEncoding ?? Encoding.getByName('UTF-8'));

  @override
  List<String> get programArguments {
    return [
      inputPath,
      outputPath,
      if (language != null) ...[
        '-l',
        language!,
      ],
    ];
  }
}
