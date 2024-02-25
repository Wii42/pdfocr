import 'dart:io';

import 'package:dcli/dcli.dart' show DartScript;
import 'package:path/path.dart' show basenameWithoutExtension, join;
import 'package:pdfocr/pdfocr.dart';

void main([List<String> args = const <String>[]]) async {
  testRun();
}

void testRun() {
  String inputPath = join(projectRoot.path, 'assets\\test_files');
  String outputPath = join(projectRoot.path, 'assets\\output');
  String inputFile = 'Eric Hobsbawm - Age Of Revolution 1789 -1848.pdf';
  PdfOcr pdfOcr = PdfOcr(
    inputFile: join(inputPath, inputFile),
    outputFile: join(outputPath, '${basenameWithoutExtension(inputFile)}.txt'),
    dpi: 800,
    language: 'eng',
    deleteTempFiles: false,
    overrideTempFiles: true,
    debugModeTesseractOnly: false,
    projectRoot: projectRoot,
  );
  pdfOcr.run();
}

Directory get projectRoot => Directory(DartScript.self.pathToProjectRoot);
