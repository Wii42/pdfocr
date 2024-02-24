import 'package:pdfocr/ocr_list.dart';
import 'package:pdfocr/pdfocr.dart';

void main([List<String> args = const <String>[]]) async {

  String inputFile =
      'assets\\test_files\\Clark-Preussen_und_der_deutsche_Sonderweg.pdf';
  PdfOcr pdfOcr = PdfOcr(
      inputFile: inputFile,
      outputFile: 'assets\\output\\output.txt',
      deleteTempFiles: false,
      overrideTempFiles: true,
      debugModeTesseractOnly: false);
  OcrList result = await pdfOcr.run();
}
