import 'dart:typed_data';

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';

import 'package:pdf/pdf.dart';

import 'package:pdf/widgets.dart' as pw;

import 'pdf_file_saver.dart';

class PdfExportService {
  static const double _pageWidth = 1120;

  static const double _pageHeight = 1584;

  static const double _margin = 72;

  static const double _footerTop = 1500;

  static Future<ui.Image?> _loadLogo() async {
    try {
      final data = await rootBundle.load(
        'assets/zingacc_logo.png',
      );

      final bytes = data.buffer.asUint8List();

      final codec = await ui.instantiateImageCodec(
        bytes,
      );

      final frame = await codec.getNextFrame();

      codec.dispose();

      return frame.image;
    } catch (_) {
      // PDF එක logo එක නැතිව වුවත් export වෙන්න දෙන්න.

      return null;
    }
  }

  static Future<ui.Image?> _loadQuestionImage(Uint8List? bytes) async {
    if (bytes == null || bytes.isEmpty) return null;

    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: (_pageWidth - (_margin * 2)).toInt(),
    );

    try {
      final frame = await codec.getNextFrame();

      return frame.image;
    } finally {
      codec.dispose();
    }
  }

  // Display-friendly conversion. This is not a full TeX typesetter.

  // Keep the original maths semantics instead of deleting unknown commands.

  static String _cleanText(
      String value, {
        String language = 'English',
        bool mathContext = false,
      }) {
    var cleaned = value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    // Remove delimiters, not the maths they contain.

    cleaned = cleaned
        .replaceAll(r'\(', '')
        .replaceAll(r'\)', '')
        .replaceAll(r'\[', '')
        .replaceAll(r'\]', '')
        .replaceAll(r'$$', '')
        .replaceAll(r'$', '');

    // Convert TeX fractions before painting plain text. This is a fallback
    // representation; the dedicated equation below draws a stacked fraction.
    cleaned = cleaned
        .replaceAll(r'\(', '')
        .replaceAll(r'\)', '')
        .replaceAll(r'\[', '')
        .replaceAll(r'\]', '');

    // Strip layout-only TeX instructions.

    cleaned = cleaned.replaceAll(r'\left', '').replaceAll(r'\right', '');

    cleaned = cleaned.replaceAll(r'\displaystyle', '');

    // Handle nested braces in a numerator or denominator.

    // Never discard a fraction if it cannot be safely parsed.

    final fracCommand = RegExp(r'\\(?:dfrac|tfrac|frac)\s*\{');

    for (var i = 0; i < 80; i++) {
      final match = fracCommand.firstMatch(cleaned);

      if (match == null) break;

      final numerator = _readBraced(cleaned, match.end - 1);

      if (numerator == null) break;

      var at = numerator.end;

      while (at < cleaned.length && cleaned[at].trim().isEmpty) {
        at++;
      }

      if (at >= cleaned.length || cleaned[at] != '{') break;

      final denominator = _readBraced(cleaned, at);

      if (denominator == null) break;

      cleaned = cleaned.replaceRange(match.start, denominator.end,
          '(${numerator.text})/(${denominator.text})');
    }

    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\\\sqrt\s*\{([^{}]+)\}'),
          (m) => '√(${m.group(1)})',
    );

    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\\\text\s*\{([^{}]*)\}'),
          (m) => m.group(1) ?? '',
    );

    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\\\mathrm\s*\{([^{}]*)\}'),
          (m) => m.group(1) ?? '',
    );

    final symbols = <String, String>{
      r'\Rightarrow': '⇒',
      r'\rightarrow': '→',
      r'\implies': '⇒',
      r'\times': '×',
      r'\div': '÷',
      r'\cdot': '·',
      r'\leq': '≤',
      r'\le': '≤',
      r'\geq': '≥',
      r'\ge': '≥',
      r'\neq': '≠',
      r'\approx': '≈',
      r'\pm': '±',
      r'\alpha': 'α',
      r'\beta': 'β',
      r'\gamma': 'γ',
      r'\theta': 'θ',
      r'\pi': 'π',
      r'\infty': '∞',
      r'\sum': 'Σ',
      r'\int': '∫',
      r'\to': '→',
      r'\sqrt': '√',
      r'\sin': 'sin',
      r'\cos': 'cos',
      r'\tan': 'tan',
      r'\ln': 'ln',
      r'\log': 'log',
      r'\quad': '  ',
      r'\qquad': '   ',
      r'\\\\,': ' ',
      r'\\\\;': ' ',
      r'\\\\!': '',
      r'\lor':
      language == 'සිංහල' ? 'හෝ' : (language == 'தமிழ்' ? 'அல்லது' : 'or'),
    };

    for (final entry in symbols.entries) {
      cleaned = cleaned.replaceAll(
          RegExp('${RegExp.escape(entry.key)}(?![A-Za-z])'), entry.value);
    }

    // Unicode scripts work in ordinary text and inside Sinhala paragraphs.

    const subscriptDigits = <String, String>{
      '0': '₀',
      '1': '₁',
      '2': '₂',
      '3': '₃',
      '4': '₄',
      '5': '₅',
      '6': '₆',
      '7': '₇',
      '8': '₈',
      '9': '₉',
      '+': '₊',
      '-': '₋',
    };

    const superscriptDigits = <String, String>{
      '0': '⁰',
      '1': '¹',
      '2': '²',
      '3': '³',
      '4': '⁴',
      '5': '⁵',
      '6': '⁶',
      '7': '⁷',
      '8': '⁸',
      '9': '⁹',
      '+': '⁺',
      '-': '⁻',
    };

    cleaned = cleaned.replaceAllMapped(
      RegExp(r'_\\\{([0-9+\\\\-]+)\\\}|_([0-9]+)'),
          (m) => _mapScriptDigits(m.group(1) ?? m.group(2)!, subscriptDigits),
    );

    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\\\\^\\\{([0-9+\\\\-]+)\\\}|\\\\^([0-9]+)'),
          (m) => _mapScriptDigits(m.group(1) ?? m.group(2)!, superscriptDigits),
    );

    // Preserve nonnumeric powers and subscripts in readable parentheses.

    cleaned = cleaned.replaceAllMapped(
        RegExp(r'\\\\^\\\{([^{}]+)\\\}'), (m) => '^(${m.group(1)})');

    cleaned = cleaned.replaceAllMapped(
        RegExp(r'_\\\{([^{}]+)\\\}'), (m) => '_(${m.group(1)})');

    // Render common algebraic powers and subscripts as Unicode, even when
    // the AI writes x^2 rather than LaTeX x^{2}.
    const power = <String, String>{
      '0': '⁰',
      '1': '¹',
      '2': '²',
      '3': '³',
      '4': '⁴',
      '5': '⁵',
      '6': '⁶',
      '7': '⁷',
      '8': '⁸',
      '9': '⁹',
      '+': '⁺',
      '-': '⁻',
    };
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\^\{([0-9+\-]+)\}|\^([0-9]+)'),
          (m) => (m.group(1) ?? m.group(2)!)
          .split('')
          .map((c) => power[c] ?? c)
          .join(),
    );

    return cleaned.trim();
  }

  static ({String text, int end})? _readBraced(String text, int opening) {
    if (opening >= text.length || text[opening] != '{') return null;

    var depth = 0;

    for (var i = opening; i < text.length; i++) {
      if (text[i] == '{') depth++;

      if (text[i] == '}') {
        depth--;

        if (depth == 0) {
          return (text: text.substring(opening + 1, i), end: i + 1);
        }
      }
    }

    return null;
  }

  static String _mapScriptDigits(
      String value,
      Map<String, String> replacements,
      ) {
    return value.split('').map((character) {
      return replacements[character] ?? character;
    }).join();
  }

  static bool _isAnswerSectionHeading(String line) {
    final normalized = line.trim().toLowerCase().replaceAll(':', '');

    const headings = <String>{
      'ප්‍රශ්නය',
      'සොයා ගත යුතු දේ',
      'සොයාගත යුතු දේ',
      'වැදගත් තොරතුරු',
      'ප්‍රධාන නියමය / අදහස',
      'පැහැදිලි කිරීම / පියවර',
      'පරීක්ෂාව',
      'අවසාන පිළිතුර',
      'පුහුණු ප්‍රශ්නය',
      'கேள்வி',
      'கண்டுபிடிக்க வேண்டியது',
      'முக்கிய தகவல்கள்',
      'முக்கிய விதி / கருத்து',
      'விளக்கம் / படிகள்',
      'சரிபார்ப்பு',
      'இறுதி விடை',
      'பயிற்சி கேள்வி',
      'question',
      'what we need to find',
      'important information',
      'key rule / idea',
      'explanation / steps',
      'check',
      'final answer',
      'practice question',
    };

    return headings.contains(normalized);
  }

  static bool _isFinalAnswerHeading(String line) {
    final normalized = line.trim().toLowerCase().replaceAll(':', '');

    return normalized == 'අවසාන පිළිතුර' ||
        normalized == 'இறுதி விடை' ||
        normalized == 'final answer';
  }

  static Future<Uint8List> buildAnswerPdf({
    required String language,
    required String question,
    required String answer,
    Uint8List? questionImageBytes,
  }) async {
    debugPrint('PDF DEBUG 1: buildAnswerPdf START');

    late final String questionHeading;

    late final String answerHeading;

    late final String languageHeading;

    late final String imageQuestionText;

    late final String footerText;

    late final String documentSubtitle;

    late final ui.Locale locale;

    if (language == 'සිංහල') {
      questionHeading = 'ප්‍රශ්නය සහ ඉගෙනුම් තොරතුරු';

      answerHeading = 'AI ගුරුගේ පැහැදිලි කිරීම';

      languageHeading = 'පැහැදිලි කිරීමේ භාෂාව';

      imageQuestionText = 'උඩුගත කළ ඡායාරූපයේ ප්‍රශ්නය';

      footerText = 'ZingaCC Learn AI මගින් සකස් කරන ලදී';

      documentSubtitle = 'AI ඉගෙනුම් පිළිතුර';

      locale = const ui.Locale('si');
    } else if (language == 'தமிழ்') {
      questionHeading = 'கேள்வி மற்றும் கற்றல் தகவல்';

      answerHeading = 'AI ஆசிரியரின் விளக்கம்';

      languageHeading = 'விளக்க மொழி';

      imageQuestionText = 'பதிவேற்றிய படத்தில் உள்ள கேள்வி';

      footerText = 'ZingaCC Learn AI மூலம் உருவாக்கப்பட்டது';

      documentSubtitle = 'AI கற்றல் பதில்';

      locale = const ui.Locale('ta');
    } else {
      questionHeading = 'Question & Learning Details';

      answerHeading = 'AI Tutor Explanation';

      languageHeading = 'Explanation Language';

      imageQuestionText = 'Question from the uploaded image';

      footerText = 'Generated by ZingaCC Learn AI';

      documentSubtitle = 'AI Learning Answer';

      locale = const ui.Locale('en');
    }

    final mathContext = RegExp(
      r'\bsubject:\s*(?:mathematics|combined mathematics|science|physics|chemistry|biology|agricultural science|science for technology|bio systems technology)\b',
      caseSensitive: false,
    ).hasMatch(question);

    final safeQuestion = question.trim().isEmpty
        ? imageQuestionText
        : _cleanText(question, language: language, mathContext: mathContext);

    debugPrint('PDF DEBUG 2: BEFORE LOGO');

    final logo = await _loadLogo();

    final questionImage = await _loadQuestionImage(questionImageBytes);

    debugPrint('PDF DEBUG 3: AFTER LOGO');

    final pages = <_RasterPdfPage>[];

    late _RasterPdfPage currentPage;

    _RasterPdfPage createPage() {
      final page = _RasterPdfPage(
        logo: logo,
        locale: locale,
        documentSubtitle: documentSubtitle,
        languageHeading: languageHeading,
        language: language,
      );

      pages.add(page);

      return page;
    }

    currentPage = createPage();

    // ==========================================================

    // QUESTION HEADING

    // ==========================================================

    var paragraph = currentPage.createParagraph(
      questionHeading,
      fontSize: 27,
      fontWeight: ui.FontWeight.w700,
      color: const ui.Color(0xFF172033),
    );

    if (!currentPage.canFit(
      paragraph.height + 18,
    )) {
      currentPage = createPage();

      paragraph = currentPage.createParagraph(
        questionHeading,
        fontSize: 27,
        fontWeight: ui.FontWeight.w700,
        color: const ui.Color(0xFF172033),
      );
    }

    currentPage.drawParagraph(
      paragraph,
      bottomGap: 9,
    );

    // ==========================================================

    // QUESTION BOX

    // ==========================================================

    var questionParagraph = currentPage.createParagraph(
      safeQuestion,
      fontSize: 22,
      fontWeight: ui.FontWeight.w400,
      color: const ui.Color(0xFF263248),
      width: _pageWidth - (_margin * 2) - 36,
    );

    final questionBoxHeight = questionParagraph.height + 34;

    if (!currentPage.canFit(
      questionBoxHeight + 22,
    )) {
      currentPage = createPage();

      questionParagraph = currentPage.createParagraph(
        safeQuestion,
        fontSize: 22,
        fontWeight: ui.FontWeight.w400,
        color: const ui.Color(0xFF263248),
        width: _pageWidth - (_margin * 2) - 36,
      );
    }

    currentPage.drawQuestionBox(
      questionParagraph,
    );

    // Also typeset a detected fraction in the question as a proper equation.

    // The original question text remains unchanged and readable.

    final questionLatex = _RasterPdfPage.extractLatexFraction(question);
    final questionFraction = questionLatex != null
        ? _RasterPdfPage.replaceLatexFractionWithReadable(questionLatex)
        : _RasterPdfPage.extractSimpleFraction(safeQuestion);

    if (questionFraction != null) {
      if (!currentPage.canFit(105)) currentPage = createPage();

      currentPage.drawFractionEquation(questionFraction, bottomGap: 12);
    }

    currentPage.addSpace(12);

    // Add the original uploaded question photo to the exported PDF.

    if (questionImage != null) {
      var imageHeading = currentPage.createParagraph(
        imageQuestionText,
        fontSize: 21,
        fontWeight: ui.FontWeight.w600,
        color: const ui.Color(0xFF344054),
      );

      var imageSize = currentPage.questionImageDisplaySize(questionImage);

      final requiredImageSectionHeight =
          imageHeading.height + imageSize.height + 54;

      if (!currentPage.canFit(requiredImageSectionHeight)) {
        currentPage = createPage();

        imageHeading = currentPage.createParagraph(
          imageQuestionText,
          fontSize: 21,
          fontWeight: ui.FontWeight.w600,
          color: const ui.Color(0xFF344054),
        );

        imageSize = currentPage.questionImageDisplaySize(questionImage);
      }

      currentPage.drawQuestionImage(questionImage, imageHeading, imageSize);

      currentPage.addSpace(12);
    }

    // ==========================================================

    // ANSWER HEADING

    // ==========================================================

    paragraph = currentPage.createParagraph(
      answerHeading,
      fontSize: 27,
      fontWeight: ui.FontWeight.w700,
      color: const ui.Color(0xFF172033),
    );

    if (!currentPage.canFit(
      paragraph.height + 20,
    )) {
      currentPage = createPage();

      paragraph = currentPage.createParagraph(
        answerHeading,
        fontSize: 27,
        fontWeight: ui.FontWeight.w700,
        color: const ui.Color(0xFF172033),
      );
    }

    currentPage.drawParagraph(
      paragraph,
      bottomGap: 9,
    );

    // ==========================================================

    // AI ANSWER

    // ==========================================================

    final answerLines =
    answer.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');

    for (var lineIndex = 0; lineIndex < answerLines.length; lineIndex++) {
      final rawLine = answerLines[lineIndex];

      final line = rawLine.trim();

      if (line.isEmpty) {
        // Keep the answer readable without leaving a short final section on

        // an otherwise empty page.

        currentPage.addSpace(1);

        continue;
      }

      // Preserve raw TeX until the equation renderer has inspected it.
      // Converting \frac to ordinary text too early loses the fraction bar.
      final displayLine = _cleanText(
        line,
        language: language,
        mathContext: mathContext,
      );
      final latexFraction = _RasterPdfPage.extractLatexFraction(line);

      var answerParagraph = currentPage.createParagraph(
        displayLine,
        fontSize: 22,
        fontWeight: ui.FontWeight.w400,
        color: const ui.Color(0xFF263248),
      );

      var requiredHeight = latexFraction != null
          ? answerParagraph.height + 112
          : _RasterPdfPage.isSimpleFractionEquation(displayLine)
          ? 105.0
          : answerParagraph.height + 6;

      if (_isAnswerSectionHeading(line)) {
        for (var nextIndex = lineIndex + 1;
        nextIndex < answerLines.length;
        nextIndex++) {
          final nextLine = answerLines[nextIndex].trim();

          if (nextLine.isNotEmpty && _isAnswerSectionHeading(nextLine)) break;

          if (nextLine.isEmpty) {
            if (_isFinalAnswerHeading(line)) requiredHeight += 5;

            continue;
          }

          final nextParagraph = currentPage.createParagraph(
            nextLine,
            fontSize: 22,
            fontWeight: ui.FontWeight.w400,
            color: const ui.Color(0xFF263248),
          );

          requiredHeight += nextParagraph.height + 6;

          if (!_isFinalAnswerHeading(line)) break;
        }
      }

      if (!currentPage.canFit(requiredHeight)) {
        currentPage = createPage();

        answerParagraph = currentPage.createParagraph(
          displayLine,
          fontSize: 22,
          fontWeight: ui.FontWeight.w400,
          color: const ui.Color(0xFF263248),
        );
      }

      // Standalone equations with simple fractions use a stacked fraction.

      // Mixed prose and unsupported formulae keep the existing safe renderer.

      if (latexFraction != null) {
        // Keep explanatory prose, then typeset the fraction on its own line.
        final plainProse = _RasterPdfPage.removeLatexFraction(line);
        if (plainProse.isNotEmpty) {
          final proseParagraph = currentPage.createParagraph(
            _cleanText(plainProse, language: language),
            fontSize: 22,
            fontWeight: ui.FontWeight.w400,
            color: const ui.Color(0xFF263248),
          );
          if (!currentPage.canFit(proseParagraph.height + 110)) {
            currentPage = createPage();
          }
          currentPage.drawParagraph(proseParagraph, bottomGap: 5);
        }
        final formatted = _RasterPdfPage.replaceLatexFractionWithReadable(
          latexFraction,
        );
        if (!currentPage.canFit(110)) currentPage = createPage();
        currentPage.drawFractionEquation(formatted, bottomGap: 8);
      } else if (_RasterPdfPage.isSimpleFractionEquation(displayLine)) {
        currentPage.drawFractionEquation(displayLine, bottomGap: 8);
      } else {
        currentPage.drawParagraph(
          answerParagraph,
          bottomGap: 6,
        );

        // For Sinhala/Tamil/English prose containing a bracketed algebraic

        // fraction, show an additional properly typeset equation below it.

        // This avoids replacing or damaging the student's explanation.

        final inlineFraction =
        _RasterPdfPage.extractSimpleFraction(displayLine);

        if (inlineFraction != null &&
            RegExp(r'[\u0D80-\u0DFF\u0B80-\u0BFF]').hasMatch(line)) {
          if (!currentPage.canFit(100)) currentPage = createPage();

          currentPage.drawFractionEquation(inlineFraction, bottomGap: 8);
        }
      }
    }

    // ==========================================================

    // RENDER FLUTTER PAGES AS PNG

    // ==========================================================

    debugPrint('PDF DEBUG 4: PAGE CONTENT READY - pages=${pages.length}');

    final renderedPages = <Uint8List>[];

    for (var i = 0; i < pages.length; i++) {
      debugPrint('PDF DEBUG 5: PAGE ${i + 1} FINISH START');

      final pageBytes = await pages[i].finish(
        footerText: footerText,
        pageNumber: i + 1,
        totalPages: pages.length,
      );

      renderedPages.add(pageBytes);

      debugPrint(
          'PDF DEBUG 9: PAGE ${i + 1} PNG READY - bytes=${pageBytes.length}');
    }

    debugPrint('PDF DEBUG 10: ALL PAGES READY - count=${renderedPages.length}');

    logo?.dispose();

    questionImage?.dispose();

    // ==========================================================

    // CREATE REAL PDF

    // ==========================================================

    final pdf = pw.Document();

    for (final pageBytes in renderedPages) {
      final pageImage = pw.MemoryImage(
        pageBytes,
      );

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (context) {
            return pw.SizedBox.expand(
              child: pw.Image(
                pageImage,
                fit: pw.BoxFit.fill,
              ),
            );
          },
        ),
      );
    }

    debugPrint('PDF DEBUG 11: BEFORE pdf.save');

    final pdfBytes = await pdf.save();

    debugPrint('PDF DEBUG 12: PDF BYTES READY - bytes=${pdfBytes.length}');

    return pdfBytes;
  }

  static Future<void> saveOrShareAnswerPdf({
    required String language,
    required String question,
    required String answer,
    Uint8List? questionImageBytes,
  }) async {
    final bytes = await buildAnswerPdf(
      language: language,
      question: question,
      answer: answer,
      questionImageBytes: questionImageBytes,
    );

    debugPrint('PDF DEBUG 13: BEFORE DOWNLOAD - bytes=${bytes.length}');

    await savePdfBytes(
      bytes: bytes,
      filename: 'ZingaCC-Learn-AI-Answer.pdf',
      subject: 'ZingaCC Learn AI - AI Learning Answer',
    );

    debugPrint('PDF DEBUG 14: DOWNLOAD CALL FINISHED');
  }
}

// ============================================================

// INTERNAL PDF PAGE RENDERER

// ============================================================

class _RasterPdfPage {
  _RasterPdfPage({
    required this.logo,
    required this.locale,
    required this.documentSubtitle,
    required this.languageHeading,
    required this.language,
  }) {
    canvas = ui.Canvas(recorder);

    // White page background

    canvas.drawRect(
      const ui.Rect.fromLTWH(
        0,
        0,
        PdfExportService._pageWidth,
        PdfExportService._pageHeight,
      ),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );

    _drawHeader();
  }

  final ui.Image? logo;

  final ui.Locale locale;

  final String documentSubtitle;

  final String languageHeading;

  final String language;

  final ui.PictureRecorder recorder = ui.PictureRecorder();

  late final ui.Canvas canvas;

  double y = 0;

  static const List<String> _fontFallbacks = [
    'Noto Sans Sinhala',
    'Noto Sans Tamil',
    'Noto Sans',
    'Nirmala UI',
    'Iskoola Pota',
    'Latha',
    'Arial',
  ];

  void _drawHeader() {
    const margin = PdfExportService._margin;

    double textStartX = margin;

    if (logo != null) {
      const logoSize = 74.0;

      final source = ui.Rect.fromLTWH(
        0,
        0,
        logo!.width.toDouble(),
        logo!.height.toDouble(),
      );

      const destination = ui.Rect.fromLTWH(
        margin,
        48,
        logoSize,
        logoSize,
      );

      canvas.drawImageRect(
        logo!,
        source,
        destination,
        ui.Paint(),
      );

      textStartX = margin + logoSize + 22;
    }

    final brand = createParagraph(
      'ZingaCC Learn AI',
      fontSize: 31,
      fontWeight: ui.FontWeight.w700,
      color: const ui.Color(0xFF111827),
      width: PdfExportService._pageWidth - textStartX - margin,
    );

    canvas.drawParagraph(
      brand,
      ui.Offset(
        textStartX,
        48,
      ),
    );

    final subtitle = createParagraph(
      documentSubtitle,
      fontSize: 18,
      fontWeight: ui.FontWeight.w400,
      color: const ui.Color(0xFF667085),
      width: PdfExportService._pageWidth - textStartX - margin,
    );

    canvas.drawParagraph(
      subtitle,
      ui.Offset(
        textStartX,
        86,
      ),
    );

    final languageParagraph = createParagraph(
      '$languageHeading: $language',
      fontSize: 17,
      fontWeight: ui.FontWeight.w400,
      color: const ui.Color(0xFF667085),
      width: PdfExportService._pageWidth - textStartX - margin,
    );

    canvas.drawParagraph(
      languageParagraph,
      ui.Offset(
        textStartX,
        113,
      ),
    );

    canvas.drawLine(
      const ui.Offset(
        margin,
        154,
      ),
      const ui.Offset(
        PdfExportService._pageWidth - margin,
        154,
      ),
      ui.Paint()
        ..color = const ui.Color(0xFFD5DAE3)
        ..strokeWidth = 2,
    );

    y = 184;
  }

  ui.Paragraph createParagraph(
      String text, {
        required double fontSize,
        required ui.FontWeight fontWeight,
        required ui.Color color,
        double? width,
      }) {
    final paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textDirection: ui.TextDirection.ltr,
        fontSize: fontSize,
        height: 1.27,
        locale: locale,
      ),
    );

    paragraphBuilder.pushStyle(
      ui.TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: 1.27,
        locale: locale,
        fontFamilyFallback: _fontFallbacks,
      ),
    );

    paragraphBuilder.addText(text);

    paragraphBuilder.pop();

    final paragraph = paragraphBuilder.build();

    paragraph.layout(
      ui.ParagraphConstraints(
        width: width ??
            PdfExportService._pageWidth - (PdfExportService._margin * 2),
      ),
    );

    return paragraph;
  }

  // A conservative equation parser: accepts bracketed numerator/denominator

  // and does not interpret dy/dx or prose as an algebraic fraction.

  static final RegExp _fraction = RegExp(
    r'\(((?:[^()]|\([^()]*\)){1,120})\)\s*/\s*\(((?:[^()]|\([^()]*\)){1,120})\)',
  );

  static String? extractLatexFraction(String line) {
    final command = RegExp(r'\\(?:dfrac|tfrac|frac)\s*\{').firstMatch(line);
    if (command == null) return null;
    final numerator = PdfExportService._readBraced(line, command.end - 1);
    if (numerator == null) return null;
    var at = numerator.end;
    while (at < line.length && line[at].trim().isEmpty) {
      at++;
    }
    if (at >= line.length || line[at] != '{') return null;
    final denominator = PdfExportService._readBraced(line, at);
    if (denominator == null) return null;
    if (numerator.text.isEmpty || denominator.text.isEmpty) return null;
    return line.substring(command.start, denominator.end);
  }

  static String removeLatexFraction(String line) {
    final formula = extractLatexFraction(line);
    if (formula == null) return line.trim();
    return line
        .replaceFirst(formula, '')
        .replaceAll(r'\[', '')
        .replaceAll(r'\]', '')
        .replaceAll(r'\(', '')
        .replaceAll(r'\)', '')
        .replaceAll(r'$$', '')
        .trim();
  }

  static String replaceLatexFractionWithReadable(String line) {
    final command = RegExp(r'\\(?:dfrac|tfrac|frac)\s*\{').firstMatch(line);
    if (command == null) return line;
    final numerator = PdfExportService._readBraced(line, command.end - 1);
    if (numerator == null) return line;
    var at = numerator.end;
    while (at < line.length && line[at].trim().isEmpty) {
      at++;
    }
    if (at >= line.length || line[at] != '{') return line;
    final denominator = PdfExportService._readBraced(line, at);
    if (denominator == null) return line;
    final normalized = line.replaceRange(
      command.start,
      denominator.end,
      '(${numerator.text})/(${denominator.text})',
    );
    return PdfExportService._cleanText(normalized);
  }

  static String? extractSimpleFraction(String line) {
    final match = _fraction.firstMatch(line);

    if (match == null) return null;

    final numerator = match.group(1)!.trim();

    final denominator = match.group(2)!.trim();

    if (numerator.isEmpty || denominator.isEmpty) return null;

    if (!RegExp(r'[A-Za-z0-9π√]').hasMatch(numerator) ||
        !RegExp(r'[A-Za-z0-9π√]').hasMatch(denominator)) return null;

    if (RegExp(r'[\u0D80-\u0DFF\u0B80-\u0BFF]').hasMatch(match.group(0)!)) {
      return null;
    }

    return match.group(0);
  }

  static bool isSimpleFractionEquation(String line) {
    if (extractSimpleFraction(line) == null || line.length > 150) return false;

    if (RegExp(r'[\u0D80-\u0DFF\u0B80-\u0BFF]').hasMatch(line)) return false;

    return !line.contains('\\\\');
  }

  // Draw one true stacked fraction, centered. Any other equation text is

  // retained before/after it. Width checks prevent writing off the page.

  void drawFractionEquation(String line, {double bottomGap = 8}) {
    final match = _fraction.firstMatch(line);

    if (match == null) {
      drawParagraph(
          createParagraph(line,
              fontSize: 22,
              fontWeight: ui.FontWeight.w400,
              color: const ui.Color(0xFF263248)),
          bottomGap: bottomGap);

      return;
    }

    const color = ui.Color(0xFF263248);

    const size = 22.0;

    final before = line.substring(0, match.start);

    final numerator = match.group(1)!;

    final denominator = match.group(2)!;

    final after = line.substring(match.end);

    final left = createParagraph(before,
        fontSize: size,
        fontWeight: ui.FontWeight.w400,
        color: color,
        width: 920);

    final top = createParagraph(numerator,
        fontSize: size,
        fontWeight: ui.FontWeight.w400,
        color: color,
        width: 880);

    final bottom = createParagraph(denominator,
        fontSize: size,
        fontWeight: ui.FontWeight.w400,
        color: color,
        width: 880);

    final right = createParagraph(after,
        fontSize: size,
        fontWeight: ui.FontWeight.w400,
        color: color,
        width: 920);

    final fractionWidth = (top.longestLine > bottom.longestLine
        ? top.longestLine
        : bottom.longestLine) +
        26;

    final totalWidth = left.longestLine + fractionWidth + right.longestLine;

    final maxWidth = PdfExportService._pageWidth - PdfExportService._margin * 2;

    if (totalWidth > maxWidth || fractionWidth > maxWidth) {
      drawParagraph(
          createParagraph(line,
              fontSize: size, fontWeight: ui.FontWeight.w400, color: color),
          bottomGap: bottomGap);

      return;
    }

    final x = PdfExportService._margin;

    final topHeight = top.height;

    final barY = y + topHeight + 2;

    final fractionHeight = top.height + bottom.height + 11;

    final base = y + (fractionHeight - left.height) / 2;

    canvas.drawParagraph(left, ui.Offset(x, base));

    final fx = x + left.longestLine;

    canvas.drawParagraph(
        top, ui.Offset(fx + (fractionWidth - top.longestLine) / 2, y));

    canvas.drawLine(
        ui.Offset(fx + 4, barY),
        ui.Offset(fx + fractionWidth - 4, barY),
        ui.Paint()
          ..color = color
          ..strokeWidth = 2.2);

    canvas.drawParagraph(bottom,
        ui.Offset(fx + (fractionWidth - bottom.longestLine) / 2, barY + 5));

    canvas.drawParagraph(right, ui.Offset(fx + fractionWidth, base));

    y += fractionHeight + bottomGap;
  }

  bool canFit(double height) {
    return y + height < PdfExportService._footerTop;
  }

  void addSpace(double height) {
    y += height;
  }

  void drawParagraph(
      ui.Paragraph paragraph, {
        double bottomGap = 0,
      }) {
    canvas.drawParagraph(
      paragraph,
      ui.Offset(
        PdfExportService._margin,
        y,
      ),
    );

    y += paragraph.height + bottomGap;
  }

  void drawQuestionBox(
      ui.Paragraph paragraph,
      ) {
    const horizontalPadding = 18.0;

    const verticalPadding = 17.0;

    final boxHeight = paragraph.height + (verticalPadding * 2);

    final boxRect = ui.RRect.fromRectAndRadius(
      ui.Rect.fromLTWH(
        PdfExportService._margin,
        y,
        PdfExportService._pageWidth - (PdfExportService._margin * 2),
        boxHeight,
      ),
      const ui.Radius.circular(14),
    );

    canvas.drawRRect(
      boxRect,
      ui.Paint()..color = const ui.Color(0xFFF2F4F7),
    );

    canvas.drawParagraph(
      paragraph,
      ui.Offset(
        PdfExportService._margin + horizontalPadding,
        y + verticalPadding,
      ),
    );

    y += boxHeight;
  }

  ui.Size questionImageDisplaySize(ui.Image image) {
    const maxImageHeight = 365.0;

    final maxImageWidth =
        PdfExportService._pageWidth - (PdfExportService._margin * 2) - 32;

    var width = image.width.toDouble();

    var height = image.height.toDouble();

    var scale = 1.0;

    if (width > maxImageWidth) scale = maxImageWidth / width;

    if (height * scale > maxImageHeight) scale = maxImageHeight / height;

    return ui.Size(width * scale, height * scale);
  }

  void drawQuestionImage(
      ui.Image image,
      ui.Paragraph heading,
      ui.Size displaySize,
      ) {
    drawParagraph(heading, bottomGap: 12);

    const margin = PdfExportService._margin;

    final availableWidth = PdfExportService._pageWidth - (margin * 2);

    final cardRect = ui.RRect.fromRectAndRadius(
      ui.Rect.fromLTWH(margin, y - 8, availableWidth, displaySize.height + 16),
      const ui.Radius.circular(12),
    );

    canvas.drawRRect(
      cardRect,
      ui.Paint()..color = const ui.Color(0xFFF8FAFC),
    );

    canvas.drawRRect(
      cardRect,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..color = const ui.Color(0xFFD8DEE8)
        ..strokeWidth = 1.5,
    );

    final source = ui.Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final destination = ui.Rect.fromLTWH(
      (PdfExportService._pageWidth - displaySize.width) / 2,
      y,
      displaySize.width,
      displaySize.height,
    );

    canvas.drawImageRect(
      image,
      source,
      destination,
      ui.Paint()..filterQuality = ui.FilterQuality.high,
    );

    y += displaySize.height + 24;
  }

  Future<Uint8List> finish({
    required String footerText,
    required int pageNumber,
    required int totalPages,
  }) async {
    // Footer separator

    canvas.drawLine(
      const ui.Offset(
        PdfExportService._margin,
        1510,
      ),
      const ui.Offset(
        PdfExportService._pageWidth - PdfExportService._margin,
        1510,
      ),
      ui.Paint()
        ..color = const ui.Color(0xFFE2E6EC)
        ..strokeWidth = 1.5,
    );

    final footer = createParagraph(
      '$footerText   •   $pageNumber / $totalPages',
      fontSize: 15,
      fontWeight: ui.FontWeight.w400,
      color: const ui.Color(0xFF737B8C),
    );

    canvas.drawParagraph(
      footer,
      const ui.Offset(
        PdfExportService._margin,
        1525,
      ),
    );

    final picture = recorder.endRecording();

    debugPrint('PDF DEBUG 6: BEFORE picture.toImage - page=$pageNumber');

    final image = await picture.toImage(
      PdfExportService._pageWidth.toInt(),
      PdfExportService._pageHeight.toInt(),
    );

    debugPrint('PDF DEBUG 7: AFTER picture.toImage - page=$pageNumber');

    picture.dispose();

    debugPrint('PDF DEBUG 8: BEFORE image.toByteData - page=$pageNumber');

    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    image.dispose();

    if (byteData == null) {
      throw Exception(
        'Could not render PDF page.',
      );
    }

    return byteData.buffer.asUint8List();
  }
}
