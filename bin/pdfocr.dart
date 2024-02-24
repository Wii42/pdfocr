
import 'package:path/path.dart';
import 'package:pdfocr/ocr_list.dart';
import 'package:pdfocr/pdfocr.dart';

void main([List<String> args = const <String>[]]) async {
  String inputPath = 'assets\\test_files';
  String outputPath = 'assets\\output';
  String inputFile = 'Osterhammel-Verwandlung.pdf';
  PdfOcr pdfOcr = PdfOcr(
      inputFile: join(inputPath, inputFile),
      outputFile: join(outputPath, '${basenameWithoutExtension(inputFile)}.txt'),
      deleteTempFiles: false,
      overrideTempFiles: true,
      debugModeTesseractOnly: false);
  OcrList result = await pdfOcr.run();
}