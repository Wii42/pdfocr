import "dart:ffi";
import "dart:io";
import "package:ffi/ffi.dart";
import "package:pdfocr/ffigen/leptonica_bindings.dart";
import "package:pdfocr/ffigen/tesseract_bindings.dart";

typedef TessVersionNative = Utf8 Function();

//void main() {
//  // Load the dynamic library
//  final DynamicLibrary tesseractLib = DynamicLibrary.open(
//    'C:\\Program Files\\Tesseract-OCR\\libtesseract-5.dll',
//  );
//  TesseractBindings tess = TesseractBindings(tesseractLib);
//
//  Pointer<TessBaseAPI> api = tess.TessBaseAPICreate();
//
//  print(tess.TessVersion().toDartString());
//
//  print(tess.TessBaseAPIGetAvailableLanguagesAsVector(api).toDartStringList());
//}

void main(List<String> args) async{
  final dylibtesseract =
      DynamicLibrary.open('C:\\Program Files\\Tesseract-OCR\\libtesseract-5.dll');
  final dylibleptonica =
      DynamicLibrary.open('C:\\Program Files\\Tesseract-OCR\\libleptonica-6.dll');

  final tess = TesseractBindings(dylibtesseract);
  final leptonica = LeptonicaBindings(dylibleptonica);

  // === Configuration ===
  final datapath = await findTessdataPath(); // Uses TESSDATA_PREFIX env or default
  final lang = 'eng'.toNativeUtf8();
  final imagePath = 'test.png'.toNativeUtf8(); // <-- change this path

  // === Initialize API ===
  final api = tess.TessBaseAPICreate();
  final initCode = tess.TessBaseAPIInit3(api, datapath?.toNativeUtf8().cast<Char>() ?? nullptr, lang.cast<Char>());
  if (initCode != 0) {
    print('Failed to initialize Tesseract.');
    exit(1);
  }

  // === Optional: List available languages ===
  final langs = tess.TessBaseAPIGetAvailableLanguagesAsVector(api);
  final langList = langs.toDartStringList();
  print('Available languages: ${langList.join(', ')}');
  tess.TessDeleteTextArray(langs);
  //tess.TessBaseAPISetVariable(api, "user_defined_dpi".toNativeUtf8().cast<Char>(), value)

  // === Load image and process ===
  final Pointer<Pix> pix = leptonica.pixRead(imagePath.cast<Char>());
  if (pix == nullptr) {
    print('Could not read image at ${imagePath.toDartString()}');
    exit(2);
  }

  tess.TessBaseAPISetImage2(api, pix);
  final outTextPtr = tess.TessBaseAPIGetUTF8Text(api);
  final outText = outTextPtr.toDartString();

  print('OCR Result:\n$outText');

  // === Clean up ===
  tess.TessDeleteText(outTextPtr);
  //leptonica.pixDestroy(nullptr);
  tess.TessBaseAPIEnd(api);
  tess.TessBaseAPIDelete(api);

  malloc.free(lang);
  malloc.free(imagePath);
}

Future<String?> findTessdataPath() async {
  try {
    final result = Platform.isWindows
        ? await Process.run('where', ['tesseract'])
        : await Process.run('which', ['tesseract']);

    if (result.exitCode != 0 || result.stdout.toString().trim().isEmpty) {
      return null;
    }

    final fullPath = result.stdout.toString().split('\n').first.trim();
    final exeDir = File(fullPath).parent;
    final tessdataDir = Directory('${exeDir.path}${Platform.pathSeparator}tessdata');

    return await tessdataDir.exists() ? tessdataDir.path : null;
  } catch (e) {
    return null;
  }
}


extension AsStringExtension on Pointer<Char> {
  String toDartString() {
    return cast<Utf8>().toDartString();
  }
}

extension CharPointerArrayToList on Pointer<Pointer<Char>> {
  /// Converts a null-terminated char** to a Dart List<String>.
  List<String> toDartStringList() {
    final result = <String>[];
    int index = 0;

    while (true) {
      final ptr = this[index];
      if (ptr == nullptr) break;

      result.add(ptr.toDartString());
      index++;
    }

    return result;
  }
}
