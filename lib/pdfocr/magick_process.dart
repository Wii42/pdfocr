import 'dart:io';

import 'ocr_process.dart';

class MagickProcess extends OcrProcess {
  static const String magickLocation = 'extern_dependencies\\ImageMagick';
  static const defaultQuality = 100;

  String inputPath;
  String outputPath;
  int? quality;

  @override
  Directory get exeLocation => Directory(magickLocation);
  @override
  String exeName = 'magick';

  MagickProcess({
    required this.inputPath,
    required this.outputPath,
    super.dpi,
    this.quality = defaultQuality,
    super.workingDirectory,
    super.stdoutEncoding,
    super.projectRoot,
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