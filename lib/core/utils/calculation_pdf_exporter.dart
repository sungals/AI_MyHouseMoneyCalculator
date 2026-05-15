import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'share_helper.dart';

class CalculationPdfExporter {
  CalculationPdfExporter._();

  static Future<void> share(
    BuildContext context, {
    required String title,
    required String summary,
    Map<String, String> input = const {},
    Map<String, String> result = const {},
  }) async {
    final font = await PdfGoogleFonts.nanumGothicRegular();
    final bold = await PdfGoogleFonts.nanumGothicBold();
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font, bold: bold),
        build: (context) => [
          pw.Text(title, style: pw.TextStyle(fontSize: 22, font: bold)),
          pw.SizedBox(height: 14),
          _section('결과 요약', [summary]),
          if (input.isNotEmpty) _keyValueSection('입력값', input),
          if (result.isNotEmpty) _keyValueSection('계산 결과', result),
          pw.SizedBox(height: 16),
          pw.Text(
            '본 계산 결과는 참고용입니다. 실제 계약 전 전문가에게 확인하세요.',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final fileName = '${_safeFileName(title)}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await doc.save(), flush: true);
    if (!context.mounted) return;

    await ShareHelper.shareFiles(
      context,
      files: [
        XFile(
          file.path,
          mimeType: 'application/pdf',
          name: fileName,
        ),
      ],
      text: '$title PDF',
      subject: title,
      title: '$title PDF',
    );
  }

  static pw.Widget _section(String title, List<String> lines) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          ...lines.map((line) => pw.Text(line)),
        ],
      ),
    );
  }

  static pw.Widget _keyValueSection(
    String title,
    Map<String, String> values,
  ) {
    return _section(
      title,
      values.entries.map((entry) => '${entry.key}: ${entry.value}').toList(),
    );
  }

  static String _safeFileName(String title) {
    final safeTitle = title.replaceAll(RegExp(r'[^a-zA-Z0-9가-힣_-]'), '_');
    return '${safeTitle}_${DateTime.now().millisecondsSinceEpoch}';
  }
}
