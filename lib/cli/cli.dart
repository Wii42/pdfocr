import 'dart:io';

import 'package:args/args.dart';
import 'package:pdfocr/helper/string_extension.dart';
import 'package:pdfocr/pdfocr/pdfocr.dart';

const String version = '0.0.1';

class Cli {
  static const String version = '0.0.1';
  Directory projectRoot, tempFilesDir;
  ArgParser parser = buildParser();
  Cli({required this.projectRoot, required this.tempFilesDir});

  PdfOcr? parseArgs(List<String> args) {
    final ArgParser parser = buildParser();
    ArgResults results;
    try {
      results = parser.parse(args);
    } catch (e) {
      print(e);
      return null;
    }

    if (results.wasParsed(Args.help.name) || results.rest.contains('-?')) {
      printHelpText();
      return null;
    }
    if (results.wasParsed(Args.version.name)) {
      print(version);
      return null;
    }
    return buildPdfOcr(results);
  }

  PdfOcr? buildPdfOcr(ArgResults results) {
    if (results.rest.isEmpty) {
      print('Exception: Missing ${requiredArgumentNames.join(', ')}.');
      return null;
    }
    String inputFile = results.rest[0];
    String? outputFile = results.rest.length > 1 ? results.rest[1] : null;
    String? langauge = results[Args.language.name];
    String? dpiString = results[Args.dpi.name];
    if (dpiString != null && !dpiString.isNumeric()) {
      print('Exception: DPI must be a positive integer.');
      return null;
    }
    int? dpi = dpiString != null ? int.tryParse(dpiString) : null;
    String? qualityString = results[Args.quality.name];
    if (qualityString != null && !qualityString.isNumeric()) {
      print('Exception: Quality must be a positive integer.');
      return null;
    }
    int? quality = qualityString != null ? int.tryParse(qualityString) : null;
    String? pageString = results[Args.page.name];
    if (pageString != null && !pageString.isNumeric()) {
      print('Exception: Page must be a positive integer.');
      return null;
    }
    int? page = pageString != null ? int.tryParse(pageString) : null;
    bool markings = results[Args.markings.name];
    return PdfOcr(
      inputFile: inputFile,
      outputFile: outputFile,
      language: langauge,
      dpi: dpi,
      quality: quality,
      projectRoot: projectRoot,
      tempFilesDir: tempFilesDir,
      page: page,
      pageLimitMarkingsInTxt: markings,
    );
  }

  void printHelpText() {
    int indentation = 2;
    print('');
    print('Usage: pdfocr $argumentNames [OPTIONS]');
    print('');
    print('About: Converts a PDF file to a text file using OCR.');
    print('');
    print('Argumenst:');
    for (ArgumentDescription arg in argumentDescriptions) {
      print(arg.toString().indent(indentation));
    }
    print('');
    print('Options:');
    print(parser.usage.indent(indentation));
    print('');
  }

  List<ArgumentDescription> get argumentDescriptions {
    return [
      ArgumentDescription(
        name: 'INPUTFILE',
        description: 'PDF file to be converted to text.',
        mandatory: true,
      ),
      ArgumentDescription(
        name: 'OUTPUTFILE',
        description:
            'Text file to be created, if omitted, the output is only shown in the console.',
      )
    ];
  }

  String get argumentNames {
    return argumentDescriptions.map((e) => e.name).join(' ');
  }

  List<String> get requiredArgumentNames {
    return argumentDescriptions
        .where((e) => e.mandatory)
        .map((e) => e.name)
        .toList();
  }

  static ArgParser buildParser() {
    return ArgParser()
      ..addFlag(
        Args.help.name,
        abbr: 'h',
        negatable: false,
        help: 'Print this usage information.',
      )
      ..addFlag(
        Args.version.name,
        abbr: 'v',
        negatable: false,
        help: 'Print the tool version.',
      )
      ..addOption(
        Args.language.name,
        abbr: 'l',
        help:
            'Language to be used for OCR. For a list of available languages, see the documentation of Tesseract.',
        defaultsTo: 'eng',
      )
      ..addOption(
        Args.dpi.name,
        abbr: 'd',
        help: 'DPI to be used for OCR.',
        defaultsTo: '400',
      )
      ..addOption(
        Args.quality.name,
        abbr: 'q',
        help:
            'Quality of the temporary generated PNG files.',
        defaultsTo: '100',
      )
      ..addOption(
        Args.page.name,
        abbr: 'p',
        help:
            'Page to be converted. Must exist within the PDF document, starting at 1. If omitted, all pages are converted.',
      )
      ..addFlag(
        Args.markings.name,
        abbr: 'm',
        help:
            'If set, the page number and markings are included between the pages in the output text file.',
        negatable: true,
        defaultsTo: true,
      );
  }
}

class ArgumentDescription {
  final String name;
  final String description;
  final bool mandatory;

  ArgumentDescription({
    required this.name,
    required this.description,
    this.mandatory = false,
  });

  @override
  String toString() {
    return "${mandatory ? '[required]' : '[optional]'} $name:  $description";
  }
}

enum Args {
  help,
  version,
  language,
  dpi,
  quality,
  page,
  markings,
}
