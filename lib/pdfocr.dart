import 'dart:io';

import 'package:path/path.dart';
import 'package:pdfocr/ocr_process.dart';
import 'package:pdfocr/tesseract_process.dart';

import 'magick_process.dart';
import 'ocr_list.dart';

class PdfOcr {
  String inputFile;
  String? outputFile;
  int? dpi;
  int? quality;
  String? language;
  String? workingDirectory;
  bool deleteTempFiles;
  bool overrideTempFiles;
  bool debugModeTesseractOnly;

  PdfOcr({
    required this.inputFile,
    this.outputFile,
    this.dpi = 400,
    this.quality = 100,
    this.language = 'deu',
    this.workingDirectory,
    this.deleteTempFiles = true,
    this.overrideTempFiles = false,
    this.debugModeTesseractOnly = false,
  });

  Future<OcrList> run() async {
    Directory tempFilesDir = createTempDir(debugStub: debugModeTesseractOnly);
    String tempFileName = '${basenameWithoutExtension(inputFile)}-%d.png';
    if (!debugModeTesseractOnly) {
      String tempFile = join(tempFilesDir.path, tempFileName);
      OcrProcess magickProcess = MagickProcess(
        inputPath: inputFile,
        outputPath: tempFile,
      );
      ProcessResult result = await magickProcess.run();
      print(result.stdout);
    }
    List<String> tempFiles =
        tempFilesDir.listSync().map((e) => basename(e.path)).toList();
    List<String> pngTempFiles = tempFiles
        .where((e) => extension(e) == extension(tempFileName))
        .toList();
    List<String> ocrOutput = [];
    for (String tempFile in pngTempFiles) {
      OcrProcess tesseractProcess = TesseractProcess(
        inputPath: join(tempFilesDir.path, tempFile),
        outputPath: '-',
      );
      ProcessResult ocrResult = await tesseractProcess.run();
      ocrOutput.add(ocrResult.stdout.toString());
    }
    print('parsing ocr output...');

    if (deleteTempFiles) {
      tempFilesDir.deleteSync(recursive: true);
    }
    OcrList ocrList = OcrList.fromStrings(basename(inputFile), ocrOutput);
    ocrList.clean();
    print(ocrList.wholeText);
    //print(ocrList.results.first.lines);
    if (outputFile != null) {
      if (outputFile!.isNotEmpty && outputFile != '-') {
        saveOutput(ocrList);
      } else {
        print("'$outputFile' is not a valid output file. Skipping save.");
      }
    }

    return ocrList;
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

  void saveOutput(OcrList ocrList) {
    File output = File(outputFile!);
    Directory outputDir = output.parent;
    if (!outputDir.existsSync()) {
      throw Exception('Output directory does not exist');
    }
    output = _adjustNameIfFileAlreadyExists(outputDir, output);

    output.writeAsStringSync(ocrList.wholeText);
  }

  File _adjustNameIfFileAlreadyExists(Directory outputDir, File output) {
    List<FileSystemEntity> files = outputDir.listSync();
    if (files
        .every((element) => basename(element.path) != basename(output.path))) {
      print('Saving output to ${output.path}');
      return output;
    }
    String outputBase = basenameWithoutExtension(output.path);
    String outputExtension = extension(output.path);
    int copyNr = 0;
    while (files.any((element) =>
        basename(element.path) == "$outputBase-$copyNr$outputExtension")) {
      copyNr++;
    }
    output = File(join(outputDir.path, "$outputBase-$copyNr$outputExtension"));
    print('Output file already exists. Saving as ${basename(output.path)}');

    return output;
  }
}
