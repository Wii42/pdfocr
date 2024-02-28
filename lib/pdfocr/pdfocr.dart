import 'dart:io';

import 'package:dart_pdf_reader/dart_pdf_reader.dart';
import 'package:path/path.dart'
    show basename, basenameWithoutExtension, extension, join;
import 'package:pdfocr/pdfocr/about_command/about_command.dart';
import 'package:pdfocr/pdfocr/tesseract_process.dart';

import 'magick_process.dart';
import 'ocr_list.dart';
import 'ocr_process.dart';
import 'ocr_result.dart';

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
  Directory tempFilesDir;
  int? page;
  bool pageLimitMarkingsInTxt;

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
    required this.tempFilesDir,
    this.page,
    this.pageLimitMarkingsInTxt = true,
  });

  Future<OcrList> run() async {
    checkForFileAndCommands();

    ({int start, int end}) rangeToConvert = await getRangeToConvert();
    Directory tempFilesDir = await createTempPNGs(rangeToConvert);

    List<String> pngTempFiles = sortTempFiles(tempFilesDir);
    List<OcrResult> ocrOutput = await runOcrOnFiles(tempFilesDir, pngTempFiles);

    if (deleteTempFiles) {
      tempFilesDir.deleteSync(recursive: true);
    }
    OcrList ocrList = createOcrList(ocrOutput);
    print(ocrList.wholeText);
    print('');

    if (outputFile != null) {
      saveOutputToFile(ocrList);
    }
    return ocrList;
  }

  void saveOutputToFile(OcrList ocrList) {
    if (outputFile!.isNotEmpty && outputFile != '-') {
      saveOutput(ocrList);
    } else {
      print("'$outputFile' is not a valid output file. Skipping save.");
    }
  }

  OcrList createOcrList(List<OcrResult> ocrOutput) {
    String ocrListTitle = basename(inputFile);
    if (page != null) {
      ocrListTitle += ' page $page';
    }
    OcrList ocrList = OcrList(ocrListTitle, ocrOutput,
        pageLimitMarkings: pageLimitMarkingsInTxt);
    ocrList.clean();
    ocrList.sort();
    return ocrList;
  }

  Future<List<OcrResult>> runOcrOnFiles(
      Directory tempFilesDir, List<String> pngTempFiles) async {
    List<OcrResult> ocrOutput = [];
    for (String tempFile in pngTempFiles) {
      OcrProcess tesseractProcess = TesseractProcess(
        inputPath: join(tempFilesDir.path, tempFile),
        outputPath: '-',
        language: language,
        dpi: dpi,
      );
      ProcessResult ocrResult = await tesseractProcess.run();
      int pageNumber =
          int.parse(basenameWithoutExtension(tempFile).split('-').last) + 1;
      ocrOutput
          .add(OcrResult.fromString(ocrResult.stdout.toString(), pageNumber));
    }
    return ocrOutput;
  }

  List<String> sortTempFiles(Directory tempFilesDir) {
    List<String> tempFiles =
        tempFilesDir.listSync().map((e) => basename(e.path)).toList();
    List<String> pngTempFiles = tempFiles
        .where((e) => extension(e) == extension(tempFileName))
        .toList();
    pngTempFiles.sort((a, b) {
      int aNr = int.parse(basenameWithoutExtension(a).split('-').last);
      int bNr = int.parse(basenameWithoutExtension(b).split('-').last);
      return aNr.compareTo(bNr);
    });
    return pngTempFiles;
  }

  void checkForFileAndCommands() {
    if (!File(inputFile).existsSync()) {
      throw Exception('File $inputFile does not exist');
    }
    for (AboutCommand command in AboutCommand.list) {
      if (!command.isInstalled()) {
        throw Exception(
            '${command.programName} is not installed or not added to the system PATH.');
      }
    }
  }

  Future<({int end, int start})> getRangeToConvert() async {
    int pagesCount = await getPagesCount();
    int start;
    int end;
    if (page != null) {
      if (page! < 1 || page! >= pagesCount) {
        throw RangeError('Page $page does not exist in $inputFile');
      }
      start = page! - 1;
      end = page!;
    } else {
      start = 0;
      print('Found $pagesCount pages in $inputFile');
      end = pagesCount;
    }
    return (start: start, end: end);
  }

  Future<Directory> createTempPNGs(
      ({int start, int end}) rangeToConvert) async {
    Directory tempFilesDir = createTempDir(debugStub: debugModeTesseractOnly);
    if (debugModeTesseractOnly) {
      return tempFilesDir;
    }
    for (int i = rangeToConvert.start; i < rangeToConvert.end; i++) {
      String tempFile = join(tempFilesDir.path, tempFileName);
      OcrProcess magickProcess = MagickProcess(
        inputPath: '$inputFile[$i]',
        outputPath: tempFile,
        dpi: dpi,
        quality: quality,
      );
      ProcessResult result = await magickProcess.run();
      String stdout = result.stdout.toString();
      if (stdout.isNotEmpty) print(stdout);
      if (result.exitCode != 0) {
        throw Exception(
            'ImageMagick exited with exit code ${result.exitCode}:\n${result.stderr}');
      }
    }
    return tempFilesDir;
  }

  String get tempFileName => '${basenameWithoutExtension(inputFile)}-%d.png';

  Directory createTempDir({bool debugStub = false}) {
    Directory tempFilesSubDir = Directory(join(tempFilesDir.path, 'tmp'));
    if (debugStub) return tempFilesSubDir;

    if (tempFilesSubDir.existsSync()) {
      if (overrideTempFiles) {
        tempFilesSubDir.deleteSync(recursive: true);
      } else {
        throw Exception('Directory for temp file already exists');
      }
    }
    tempFilesSubDir.createSync(recursive: true);
    return tempFilesSubDir;
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
    int copyNr = 1;
    while (files.any((element) =>
        basename(element.path) == "$outputBase-$copyNr$outputExtension")) {
      copyNr++;
    }
    output = File(join(outputDir.path, "$outputBase-$copyNr$outputExtension"));
    print('Output file already exists. Saving as ${basename(output.path)}');

    return output;
  }

  Future<int> getPagesCount() async {
    final ByteStream stream = ByteStream(File(inputFile).readAsBytesSync());
    final PDFDocument doc = await PDFParser(stream).parse();

    final PDFDocumentCatalog catalog = await doc.catalog;
    final PDFPages pages = await catalog.getPages();
    return pages.pageCount;
  }

  bool endsWithIndex(String input) {
    // Define a regular expression pattern to match "[d]" where d is a positive integer
    RegExp regex = RegExp(r"\[\d+\]$");

    // Check if the input string matches the pattern
    return regex.hasMatch(input);
  }

  @override
  String toString() {
    return "PdfOcr(inputFile: $inputFile, outputFile: $outputFile, dpi: $dpi, quality: $quality, language: $language, workingDirectory: $workingDirectory, deleteTempFiles: $deleteTempFiles, overrideTempFiles: $overrideTempFiles, debugModeTesseractOnly: $debugModeTesseractOnly, tempFilesDir: $tempFilesDir)";
  }
}
