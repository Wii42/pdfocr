import 'dart:io';

import 'package:args/args.dart';
import 'package:dcli/dcli.dart' show DartScript;
import 'package:path/path.dart' show basenameWithoutExtension, join;
import 'package:pdfocr/cli/cli.dart';
import 'package:pdfocr/pdfocr/pdfocr.dart';

void main([List<String> args = const <String>[]]) async {
  //test();
  PdfOcr? pdfocr = //test();
      Cli(projectRoot: projectRoot, tempFilesDir: tempFilesDir).parseArgs(args);
  if (pdfocr == null) {
    return;
  }
  try {
    await pdfocr.run();
  } catch (e) {
    print(e);
  }
}

PdfOcr test() {
  String inputPath = join(projectRoot.path, 'assets\\test_files');
  String outputPath = join(projectRoot.path, 'assets\\output');
  String inputFile = 'Clark-Preussen_und_der_deutsche_Sonderweg.pdf';
  PdfOcr pdfOcr = PdfOcr(
      inputFile: join(inputPath, inputFile),
      outputFile:
          join(outputPath, '${basenameWithoutExtension(inputFile)}.txt'),
      dpi: 800,
      language: 'eng',
      deleteTempFiles: false,
      overrideTempFiles: true,
      debugModeTesseractOnly: false,
      projectRoot: projectRoot,
      tempFilesDir: tempFilesDir,
      page: null,
      pageLimitMarkingsInTxt: true);
  return pdfOcr;
}

Directory get projectRoot => Directory(DartScript.self.pathToProjectRoot);

Directory get tempFilesDir {
  String relativeTempPath = 'assets\\temp';
  return Directory(join(projectRoot.path, relativeTempPath));
}
