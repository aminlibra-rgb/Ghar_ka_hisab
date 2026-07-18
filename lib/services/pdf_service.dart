import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../core/constants/app_strings.dart';

/// PDF بنانے اور پرنٹ/شیئر کرنے کی سروس
/// اردو متن کے لیے Noto Nastaliq Urdu فونٹ استعمال ہوتا ہے۔
class PdfService {
  static pw.Font? _urduFont;
  static pw.Font? _urduFontBold;

  static Future<void> _loadFonts() async {
    _urduFont ??= await PdfGoogleFonts.notoNastaliqUrduRegular();
    _urduFontBold ??= await PdfGoogleFonts.notoNastaliqUrduBold();
  }

  /// عمومی جدول کی شکل میں رپورٹ بنانا (آمدنی، اخراجات، بل وغیرہ کے لیے)
  static Future<Uint8List> generateTableReport({
    required String reportTitle,
    required String subtitle,
    required List<String> headers,
    required List<List<String>> rows,
    String? footerNote,
  }) async {
    await _loadFonts();
    final doc = pw.Document();

    final baseTextStyle = pw.TextStyle(font: _urduFont, fontSize: 11);
    final boldTextStyle = pw.TextStyle(font: _urduFontBold, fontSize: 13);

    doc.addPage(
      pw.MultiPage(
        textDirection: pw.TextDirection.rtl,
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(AppStrings.appName, style: pw.TextStyle(font: _urduFontBold, fontSize: 20)),
            pw.SizedBox(height: 4),
            pw.Text(reportTitle, style: boldTextStyle),
            pw.Text(subtitle, style: pw.TextStyle(font: _urduFont, fontSize: 11, color: PdfColors.grey700)),
            pw.Divider(),
          ],
        ),
        footer: (context) => pw.Column(children: [
          pw.Divider(),
          pw.Text(
            'صفحہ ${context.pageNumber} از ${context.pagesCount}',
            style: pw.TextStyle(font: _urduFont, fontSize: 9, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ]),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: rows,
            headerStyle: pw.TextStyle(font: _urduFontBold, fontSize: 11, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
            cellStyle: baseTextStyle,
            cellAlignment: pw.Alignment.centerRight,
            headerAlignment: pw.Alignment.centerRight,
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          ),
          if (footerNote != null) ...[
            pw.SizedBox(height: 16),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.green50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(footerNote, style: boldTextStyle, textAlign: pw.TextAlign.right),
            ),
          ],
        ],
      ),
    );

    return doc.save();
  }

  static Future<void> printOrShare(Uint8List bytes, String fileName) async {
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }

  static Future<void> printDocument(Uint8List bytes) async {
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }
}
