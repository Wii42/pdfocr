import 'package:pdfocr/pdfocr/about_command/about_magick.dart';

import 'ocr_process.dart';

class MagickProcess extends OcrProcess {
  static const int defaultQuality = 100;

  String inputPath;
  String outputPath;
  int? quality;

  MagickProcess({
    required this.inputPath,
    required this.outputPath,
    super.dpi,
    this.quality = defaultQuality,
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

  @override
  AboutMagick get about => AboutMagick();
}
