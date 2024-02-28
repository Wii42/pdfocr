import 'dart:convert';
import 'package:path/path.dart' show join;
import 'dart:io';

import 'package:pdfocr/pdfocr/about_command/about_command.dart';

abstract class OcrProcess {
  static const defaultDpi = 400;
  Encoding? stdoutEncoding;
  int? dpi;

  OcrProcess({this.stdoutEncoding, this.dpi = defaultDpi});
  List<String> get programArguments;
  String get exeName => about.exeName;
  AboutCommand get about;

  Future<ProcessResult> run() async {
    print('Running $commandString');
    ProcessResult result = await Process.run(exeName, programArguments,
        stdoutEncoding: stdoutEncoding ?? systemEncoding);
    if (result.exitCode != 0) {
      print('exited with exit code ${result.exitCode}');
      print(result.stderr);
    }
    return result;
  }

  String get commandString => "$exeName ${programArguments.join(' ')}";
}
