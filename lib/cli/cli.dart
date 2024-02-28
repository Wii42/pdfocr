import 'dart:io';

import 'package:args/args.dart';
import 'package:pdfocr/helper/string_extension.dart';
import 'package:pdfocr/pdfocr/about_command/about_magick.dart';
import 'package:pdfocr/pdfocr/about_command/about_tesseract.dart';
import 'package:pdfocr/pdfocr/pdfocr.dart';

import '../pdfocr/about_command/about_command.dart';

class Cli {
  static const String version = '0.0.1';
  static int defaultIndentation = 2;
  Directory tempFilesDir;
  ArgParser parser = buildParser();
  Cli({required this.tempFilesDir});

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
    if (results.wasParsed(Args.about.name)) {
      printAboutText();
      return null;
    }
    return buildPdfOcr(results);
  }

  void printAboutText() {
    print('');
    print("About pdfocr:");
    String text =
        "pdfocr uses Tesseract-OCR and ImageMagick to convert PDF files to text files.\n"
        "The tool works by converting each page of the PDF to a PNG file using ImageMagick and then using Tesseract-OCR to convert the PNG to a text file.\n"
        "Both Tesseract-OCR and ImageMagick must be installed and added to the system PATH for the tool to work.";
    print(text.indent(defaultIndentation));
    print('');
    for (AboutCommand command in AboutCommand.list) {
      print('About ${command.programName}:');
      if (!command.isInstalled()) {
        print(
            'WARNING: ${command.programName} is not installed or not added to the system PATH.'
                .indent(defaultIndentation));
      } else {
        print('Install path: ${command.getPath()}'.indent(defaultIndentation));
        print('Installed version: ${command.getVersion()}'
            .indent(defaultIndentation));
      }
      if (command.testedVersions.isNotEmpty) {
        print(
            'pdfocr was tested with ${command.programName} ${command.testedVersions.length == 1 ? 'version' : 'versions'} ${command.testedVersions.join(', ')}'
                .indent(defaultIndentation));
      }
      print('More information about ${command.programName}: ${command.website}'
          .indent(defaultIndentation));
      print('');
    }
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
      tempFilesDir: tempFilesDir,
      page: page,
      pageLimitMarkingsInTxt: markings,
    );
  }

  void printHelpText() {
    print('');
    print('Usage: pdfocr $argumentNames [OPTIONS]');
    print('');
    print('About: Converts a PDF file to a text file using OCR.');
    print('');
    print('Argumenst:');
    for (ArgumentDescription arg in argumentDescriptions) {
      print(arg.toString().indent(defaultIndentation));
    }
    print('');
    print('Options:');
    print(parser.usage.indent(defaultIndentation));
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
      ..addFlag(Args.about.name,
          abbr: 'a',
          negatable: false,
          help: 'Print more information about the tool.')
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
        help: 'Quality of the temporary generated PNG files.',
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
  about,
  language,
  dpi,
  quality,
  page,
  markings,
}
