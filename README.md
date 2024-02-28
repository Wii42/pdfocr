# pdfocr

**Command line tool which converts a PDF file to a text file using OCR.**

pdfocr uses [Tesseract-OCR](https://imagemagick.org) and [ImageMagick](https://tesseract-ocr.github.io) to convert PDF
files to text files.
The tool works by converting each page of the PDF to a PNG file using ImageMagick and then using Tesseract-OCR to
convert the PNG to a text file.
Both Tesseract-OCR and ImageMagick must be installed and added to the system PATH for the tool to work.

Tested on Windows 11, but should work on other platforms as well.
Tested with Tesseract-OCR 5.3.3.20231005 and ImageMagick 7.1.1-29 Q16-HDRI x64.

### Usage

pdfocr INPUTFILE OUTPUTFILE [OPTIONS]

<br>

#### Arguments

| Name       | Description                                                                   | Necessity |
|------------|-------------------------------------------------------------------------------|-----------|
| INPUTFILE  | PDF file to be converted to text.                                             | required  |
| OUTPUTFILE | Text file to be created, if omitted, the output is only shown in the console. | optional  |

<br>

#### Options

| Shorthand | Option          | Description                                                                                                             |
|-----------|-----------------|-------------------------------------------------------------------------------------------------------------------------|
| -h, -?    | --help          | Prints usage information.                                                                                               |
| -v        | --version       | Prints the tool version.                                                                                                |
| -a        | --about         | Prints more information about the tool.                                                                                 |
| -l        | --language      | Language to be used for OCR. For a list of available languages, see the documentation of Tesseract. (defaults to "eng") |
| -d        | --dpi           | DPI to be used for OCR. (defaults to "400")                                                                             |
| -q        | --quality       | Quality of the temporary generated PNG files. (defaults to "100")                                                       |
| -p        | --page          | Page to be converted. Must exist within the PDF document, starting at 1. If omitted, all pages are converted.           |
| -m        | --[no-]markings | If set, the page number and markings are included between the pages in the output text file. (defaults to on)           |

### Code
Entrypoint and EXE in `bin/`, library code
in `lib/`, 


