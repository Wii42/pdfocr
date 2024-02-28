import 'dart:io';

import 'package:path/path.dart';

extension DirectoryExtension on Directory {
  String adjustEntityNameIfAlreadyExistsInside(String entityName) {
    List<FileSystemEntity> files = listSync();
    if (files.every((element) => basename(element.path) != entityName)) {
      return entityName;
    }
    String outputBase = basenameWithoutExtension(entityName);
    String outputExtension = extension(entityName);
    int copyNr = 1;
    while (files.any((element) =>
        basename(element.path) == "$outputBase-$copyNr$outputExtension")) {
      copyNr++;
    }
    entityName = "$outputBase-$copyNr$outputExtension";

    return entityName;
  }

  File fileInside(String fileName) {
    return File(join(path, fileName));
  }
}
