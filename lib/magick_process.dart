import 'dart:io';

import 'package:pdfocr/process_runner.dart';

class MagickProcess extends ProcessRunner {
  static const String magickLocation = 'extern_dependencies\\ImageMagick';

  static const defaultDpi = 400;
  static const defaultQuality = 100;

  String inputPath;
  String outputPath;
  int? dpi;
  int? quality;

  @override
  Directory exeLocation = Directory(magickLocation);
  @override
  String exeName = 'magick';

  MagickProcess({
    required this.inputPath,
    required this.outputPath,
    this.dpi = defaultDpi,
    this.quality = defaultQuality,
    super.workingDirectory,
    super.stdoutEncoding,
  });

  @override
  List<String> get programArguments {
    return [
      if (dpi != null) ...[
        '-density',
        dpi.toString(),
      ],
      inputPath,
      if (quality != null) ...[
        '-quality',
        quality.toString(),
      ],
      outputPath,
    ];
  }
}
