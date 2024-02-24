import 'dart:convert';

import 'package:path/path.dart';
import 'dart:io';

abstract class ProcessRunner {
  String? workingDirectory;
  Encoding? stdoutEncoding;

  ProcessRunner({this.workingDirectory, this.stdoutEncoding});

  Directory get exeLocation;
  List<String> get programArguments;
  String get exeName;

  Future<ProcessResult> run() async {
    print('Running $commandString');
    ProcessResult result = await Process.run(exe, programArguments,
        workingDirectory: workingDirectory ?? Directory.current.path,
        stdoutEncoding: stdoutEncoding ?? systemEncoding);
    if (result.exitCode != 0) {
      print('exited with exit code ${result.exitCode}');
      print(result.stderr);
    }
    return result;
  }

  String get exe => join(exeLocation.path, exeName);

  String get commandString => "$exeName ${programArguments.join(' ')}";
}
