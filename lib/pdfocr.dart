import 'dart:io';

import 'package:path/path.dart';
import 'package:pdfocr/process_runner.dart';
import 'package:pdfocr/tesseract_process.dart';

import 'magick_process.dart';

class PdfOcr {
  String inputFile;
  String outputFile;
  int? dpi;
  int? quality;
  String? language;
  String? workingDirectory;
  bool deleteTempFiles;
  bool overrideTempFiles;

  PdfOcr({
    required this.inputFile,
    this.outputFile = '-',
    this.dpi = 400,
    this.quality = 100,
    this.language = 'deu',
    this.workingDirectory,
    this.deleteTempFiles = true,
    this.overrideTempFiles = false,
  });

  Future<List<String>> run() async {
    Directory tempFilesDir = createTempDir(debugStub: true);

    String tempFileName = 'page-%d.png';
    String tempFile = join(tempFilesDir.path, tempFileName);
    ProcessRunner magickProcess = MagickProcess(
      inputPath: inputFile,
      outputPath: tempFile,
    );
    //ProcessResult result = await magickProcess.run();
    //print(result.stdout);
    List<String> tempFiles =
        tempFilesDir.listSync().map((e) => basename(e.path)).toList();
    List<String> pngTempFiles = tempFiles
        .where((e) => extension(e) == extension(tempFileName))
        .toList();
    List<String> ocrOutput = [];
    for (String tempFile in pngTempFiles) {
      ProcessRunner tesseractProcess = TesseractProcess(
        inputPath: join(tempFilesDir.path, tempFile),
        outputPath: outputFile,
      );
      ProcessResult ocrResult = await tesseractProcess.run();
      ocrOutput.add(ocrResult.stdout.toString());
    }

    if (deleteTempFiles) {
      tempFilesDir.deleteSync(recursive: true);
    }

    return ocrOutput;
  }

  Directory createTempDir({bool debugStub = false}) {
    Directory tempFilesDir = Directory('assets\\temp\\tmp');
    if (debugStub) return tempFilesDir;

    if (tempFilesDir.existsSync()) {
      if (overrideTempFiles) {
        tempFilesDir.deleteSync(recursive: true);
      } else {
        throw Exception('Directory for temp file already exists');
      }
    }
    tempFilesDir.createSync(recursive: true);
    return tempFilesDir;
  }
}
