import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'share_helper.dart';

class CalculationPdfExporter {
  CalculationPdfExporter._();

  static const _primary = PdfColor.fromInt(0xFF1F4FFF);
  static const _background = PdfColor.fromInt(0xFFF7F8FA);
  static const _surface = PdfColor.fromInt(0xFFFFFFFF);
  static const _textPrimary = PdfColor.fromInt(0xFF111827);
  static const _textSecondary = PdfColor.fromInt(0xFF6B7280);
  static const _positive = PdfColor.fromInt(0xFF16A34A);
  static const _border = PdfColor.fromInt(0xFFE5E7EB);
  static const _mutedBlue = PdfColor.fromInt(0xFFEFF4FF);

  static Future<void> share(
    BuildContext context, {
    required String title,
    required String summary,
    Map<String, String> input = const {},
    Map<String, String> result = const {},
    Uint8List? resultImageBytes,
  }) async {
    // PDF 패키지의 기본 폰트는 한글을 안정적으로 렌더링하지 못하므로 NanumGothic을 사용한다.
    final font = await PdfGoogleFonts.nanumGothicRegular();
    final bold = await PdfGoogleFonts.nanumGothicBold();
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          buildBackground: _pageBackground,
          theme: pw.ThemeData.withFont(base: font, bold: bold),
        ),
        build: (context) {
          if (resultImageBytes != null) {
            // 차트/복잡한 결과 화면은 key-value 재구성 대신 캡처 이미지를 그대로 넣는다.
            return [
              _header(title, bold),
              pw.SizedBox(height: 14),
              _imageCard(resultImageBytes),
              pw.SizedBox(height: 14),
              _notice(),
            ];
          }

          return [
            _header(title, bold),
            pw.SizedBox(height: 14),
            _summaryCard(summary, bold),
            if (result.isNotEmpty) ...[
              pw.SizedBox(height: 14),
              _keyValueCard(
                title: '계산 결과',
                values: result,
                accentColor: _primary,
                bold: bold,
                emphasizeFirstRow: true,
              ),
            ],
            if (input.isNotEmpty) ...[
              pw.SizedBox(height: 14),
              _keyValueCard(
                title: '입력값',
                values: input,
                accentColor: _textSecondary,
                bold: bold,
              ),
            ],
            pw.SizedBox(height: 14),
            _notice(),
          ];
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final fileName = '${_safeFileName(title)}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await doc.save(), flush: true);
    if (!context.mounted) return;

    // share_plus는 파일 경로 기반 공유가 가장 호환성이 좋아 임시 파일로 저장한 뒤 전달한다.
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

  static pw.Widget _pageBackground(pw.Context context) {
    return pw.FullPage(
      ignoreMargins: true,
      child: pw.Container(color: _background),
    );
  }

  static pw.Widget _header(String title, pw.Font bold) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: _primary,
        borderRadius: pw.BorderRadius.circular(22),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(
            width: 42,
            height: 42,
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(14),
            ),
            alignment: pw.Alignment.center,
            child: pw.Text(
              '어',
              style: pw.TextStyle(
                font: bold,
                fontSize: 20,
                color: _primary,
              ),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '어떤비용 계산 결과',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    font: bold,
                    fontSize: 20,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _summaryCard(String summary, pw.Font bold) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: pw.BorderRadius.circular(20),
        border: pw.Border.all(color: _border),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionLabel('결과 요약', _primary, bold),
          pw.SizedBox(height: 10),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: _mutedBlue,
              borderRadius: pw.BorderRadius.circular(14),
            ),
            child: pw.Text(
              summary,
              style: pw.TextStyle(
                font: bold,
                fontSize: 16,
                color: _textPrimary,
                lineSpacing: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _imageCard(Uint8List imageBytes) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: pw.BorderRadius.circular(20),
        border: pw.Border.all(color: _border),
      ),
      child: pw.ClipRRect(
        horizontalRadius: 16,
        verticalRadius: 16,
        child: pw.Image(
          pw.MemoryImage(imageBytes),
          fit: pw.BoxFit.contain,
        ),
      ),
    );
  }

  static pw.Widget _keyValueCard({
    required String title,
    required Map<String, String> values,
    required PdfColor accentColor,
    required pw.Font bold,
    bool emphasizeFirstRow = false,
  }) {
    final entries = values.entries.toList();

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: pw.BorderRadius.circular(20),
        border: pw.Border.all(color: _border),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionLabel(title, accentColor, bold),
          pw.SizedBox(height: 12),
          for (var i = 0; i < entries.length; i++) ...[
            _valueRow(
              label: entries[i].key,
              value: entries[i].value,
              bold: bold,
              accentColor:
                  emphasizeFirstRow && i == 0 ? accentColor : _textPrimary,
              emphasized: emphasizeFirstRow && i == 0,
            ),
            if (i != entries.length - 1)
              pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 8),
                height: 0.7,
                color: _border,
              ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _sectionLabel(String label, PdfColor color, pw.Font bold) {
    return pw.Row(
      children: [
        pw.Container(
          width: 5,
          height: 16,
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: pw.BorderRadius.circular(99),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text(
          label,
          style: pw.TextStyle(
            font: bold,
            fontSize: 13,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  static pw.Widget _valueRow({
    required String label,
    required String value,
    required pw.Font bold,
    required PdfColor accentColor,
    required bool emphasized,
  }) {
    return pw.Container(
      padding: emphasized ? const pw.EdgeInsets.all(12) : pw.EdgeInsets.zero,
      decoration: emphasized
          ? pw.BoxDecoration(
              color: _mutedBlue,
              borderRadius: pw.BorderRadius.circular(12),
            )
          : null,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: const pw.TextStyle(
                fontSize: 11,
                color: _textSecondary,
              ),
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                font: bold,
                fontSize: emphasized ? 14 : 12,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _notice() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFFFFBEB),
        borderRadius: pw.BorderRadius.circular(16),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFFDE68A)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '!',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: _positive,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Text(
              '본 계산 결과는 참고용입니다. 실제 계약 전 전문가와 관련 기관에 확인하세요.',
              style: const pw.TextStyle(
                fontSize: 10,
                color: _textSecondary,
                lineSpacing: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _safeFileName(String title) {
    final safeTitle = title.replaceAll(RegExp(r'[^a-zA-Z0-9가-힣_-]'), '_');
    return '${safeTitle}_${DateTime.now().millisecondsSinceEpoch}';
  }
}
