import 'dart:io';

import 'about_magick.dart';
import 'about_tesseract.dart';

abstract class AboutCommand {
  String get programName;
  String get exeName;
  List<String> get versionCommand;
  List<String> get testedVersions;
  Uri get website;

  String parseVersion(String versionString);

  String getPath() {
    ProcessResult p = runFindCommand();
    return p.stdout.toString().trim();
  }

  bool isInstalled() {
    ProcessResult p = runFindCommand();
    return p.exitCode == 0;
  }

  ProcessResult runFindCommand() =>
      Process.runSync(osSpecificFindCommand, [exeName]);

  static String get osSpecificFindCommand {
    switch (Platform.operatingSystem) {
      case 'windows':
        return 'where';
      case 'linux':
        return 'which';
      case 'macos':
        return 'which';
      default:
        throw UnsupportedError('Unsupported OS');
    }
  }

  String getVersion() {
    ProcessResult p = Process.runSync(exeName, versionCommand);
    return parseVersion(p.stdout.toString());
  }

  static List<AboutCommand> list = [AboutTesseract(), AboutMagick()];
}
