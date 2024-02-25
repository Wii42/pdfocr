import 'dart:convert';
import 'dart:io';

import 'package:pdfocr/ocr_process.dart';

class TesseractProcess extends OcrProcess {
  static const String tesseractLocation = 'extern_dependencies\\Tesseract-OCR';
  String inputPath;
  String outputPath;
  String? language;

  @override
  Directory get exeLocation => Directory(tesseractLocation);
  @override
  String get exeName => 'tesseract';

  TesseractProcess({
    required this.inputPath,
    this.outputPath = '-',
    this.language = 'deu',
    super.workingDirectory,
    Encoding? stoutEncoding,
    super.dpi,
    super.projectRoot,
  }) : super(stdoutEncoding: stoutEncoding ?? Encoding.getByName('UTF-8'));

  @override
  List<String> get programArguments {
    return [
      inputPath,
      outputPath,
      if (dpi != null) ...[
        '--dpi',
        dpi.toString(),
      ],
      if (language != null) ...[
        '-l',
        language!,
      ],
    ];
  }
}
