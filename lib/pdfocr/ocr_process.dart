import 'dart:convert';
import 'package:path/path.dart' show join;
import 'dart:io';

abstract class OcrProcess {
  static const defaultDpi = 400;
  String? workingDirectory;
  Encoding? stdoutEncoding;
  int? dpi;
  Directory? projectRoot;

  OcrProcess(
      {this.workingDirectory,
      this.stdoutEncoding,
      this.dpi = defaultDpi,
      this.projectRoot});
  Directory get exeLocation;
  List<String> get programArguments;
  String get exeName;

  Future<ProcessResult> run() async {
    print('Running $commandString');
    ProcessResult result = await Process.run(exe, programArguments,
        stdoutEncoding: stdoutEncoding ?? systemEncoding);
    if (result.exitCode != 0) {
      print('exited with exit code ${result.exitCode}');
      print(result.stderr);
    }
    return result;
  }

  String get exe => join(absoluteExeLocation.path, exeName);

  String get commandString => "$exeName ${programArguments.join(' ')}";

  Directory get absoluteExeLocation {
    if (projectRoot != null) {
      return Directory(join(projectRoot!.path, exeLocation.path));
    }
    return exeLocation;
  }
}
