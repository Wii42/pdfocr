import 'dart:convert';
import 'package:pdfocr/pdfocr/about_command/about_tesseract.dart';

import 'ocr_process.dart';

class TesseractProcess extends OcrProcess {
  static const String defaultLanguage = 'deu';
  static const String defaultEncoding = 'UTF-8';
  static const String defaultOutputPath = '-'; //stdout

  String inputPath;
  String outputPath;
  String? language;

  TesseractProcess({
    required this.inputPath,
    this.outputPath = defaultOutputPath,
    this.language = defaultLanguage,
    Encoding? stoutEncoding,
    super.dpi,
  }) : super(
          stdoutEncoding: stoutEncoding ?? Encoding.getByName(defaultEncoding),
        );

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

  @override
  AboutTesseract get about => AboutTesseract();
}
