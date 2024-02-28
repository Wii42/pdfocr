import 'package:pdfocr/pdfocr/about_command/about_command.dart';

class AboutMagick extends AboutCommand {
  @override
  String exeName = 'magick';
  @override
  String programName = 'ImageMagick';
  @override
  List<String> versionCommand = ['--version'];
  @override
  List<String> testedVersions = ['7.1.1-29 Q16-HDRI x64'];
  @override
  Uri website = Uri.parse('https://imagemagick.org');

  @override
  String parseVersion(String versionString) {
    String versionLine = versionString.split('\n').first.trim();
    versionLine = versionLine
        .split(':')
        .skip(1)
        .join(':')
        .trim(); // remove the "Version: " prefix
    List<String> versionParts = versionLine.split(' ');
    return versionParts.take(versionParts.length - 1).join(' ').trim();
  }
}
