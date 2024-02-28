import 'dart:io';

import 'package:dart_pdf_reader/dart_pdf_reader.dart';
import 'package:path/path.dart'
    show basename, basenameWithoutExtension, extension, join;
import 'package:pdfocr/helper/directory_extension.dart';
import 'package:pdfocr/helper/range.dart';
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
  bool renameTempDirIfExists;
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
    this.renameTempDirIfExists = true,
  });

  Future<OcrList> run() async {
    checkForFileAndCommands();

    Range rangeToConvert = await getRangeToConvert();
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
      throw Exception("File '$inputFile' does not exist");
    }
    for (AboutCommand command in AboutCommand.list) {
      if (!command.isInstalled()) {
        throw Exception(
            '${command.programName} is not installed or not added to the system PATH.');
      }
    }
  }

  Future<Range> getRangeToConvert() async {
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
    return Range(start, end);
  }

  Future<Directory> createTempPNGs(Range rangeToConvert) async {
    Directory tempFilesDir = createTempDir(debugStub: debugModeTesseractOnly);
    if (debugModeTesseractOnly) {
      return tempFilesDir;
    }
    for (int i in rangeToConvert.iterable) {
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
    String subDirName = 'tmp';
    Directory tempFilesSubDir = Directory(join(tempFilesDir.path, subDirName));
    if (debugStub) return tempFilesSubDir;

    if (tempFilesSubDir.existsSync()) {
      if (overrideTempFiles) {
        tempFilesSubDir.deleteSync(recursive: true);
      } else {
        if (renameTempDirIfExists) {
          String newTempDirName =
              tempFilesDir.adjustEntityNameIfAlreadyExistsInside(subDirName);
          tempFilesSubDir = Directory(join(tempFilesDir.path, newTempDirName));
        } else {
          throw Exception(
              "Directory for temp files already exists, this means either that the directory is used by another process or that the temp files were not deleted after the last run.");
        }
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

    print('Saving output to ${output.path}');
    output.writeAsStringSync(ocrList.wholeText);
  }

  File _adjustNameIfFileAlreadyExists(Directory outputDir, File output) {
    String outputName = basename(output.path);
    String newOutputName =
        outputDir.adjustEntityNameIfAlreadyExistsInside(outputName);
    if (newOutputName != outputName) {
      output = outputDir.fileInside(newOutputName);
      print('Output file already exists. Saving as $newOutputName');
    }
    return output;
  }

  Future<int> getPagesCount() async {
    ByteStream stream = ByteStream(File(inputFile).readAsBytesSync());
    PDFDocument doc = await PDFParser(stream).parse();
    PDFDocumentCatalog catalog = await doc.catalog;
    PDFPages pages = await catalog.getPages();
    return pages.pageCount;
  }

  @override
  String toString() {
    return "PdfOcr(inputFile: $inputFile, outputFile: $outputFile, dpi: $dpi, quality: $quality, language: $language, workingDirectory: $workingDirectory, deleteTempFiles: $deleteTempFiles, overrideTempFiles: $overrideTempFiles, debugModeTesseractOnly: $debugModeTesseractOnly, tempFilesDir: $tempFilesDir)";
  }
}
