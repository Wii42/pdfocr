import 'package:pdfocr/pdfocr/about_command/about_command.dart';

class AboutTesseract extends AboutCommand {
  @override
  String exeName = 'tesseract';
  @override
  String programName = 'Tesseract-OCR';
  @override
  List<String> versionCommand = ['-v'];
  @override
  List<String> testedVersions = ['5.3.3.20231005'];
  @override
  Uri website = Uri.parse('https://tesseract-ocr.github.io');

  @override
  String parseVersion(String versionString) {
    String versionLine = versionString.split('\n').first.trim();
    String version = versionLine.split(' ').skip(1).join(' ').trim();
    if (version.startsWith('v')) {
      version = version.substring(1);
    }
    return version;
  }
}
