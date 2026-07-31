import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/money_formatter.dart';
import '../../core/utils/share_helper.dart';
import '../../data/models/calculation_history.dart';
import '../../providers/calculation_history_provider.dart';

class HistoryDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const HistoryDetailScreen({super.key, required this.id});

  @override
  ConsumerState<HistoryDetailScreen> createState() =>
      _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends ConsumerState<HistoryDetailScreen> {
  CalculationHistory? _item;
  final _memoController = TextEditingController();
  bool _isSavingMemo = false;

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(calculationHistoryRepositoryProvider);
    await repo.init();
    if (mounted) {
      final item = repo.getById(widget.id);
      setState(() {
        _item = item;
        _memoController.text = item?.memo ?? '';
      });
    }
  }

  void _share() {
    final item = _item;
    if (item == null) return;

    final resultEntries = item.result.entries
        .map((e) => '${_labelForKey(e.key)}: ${_formatValue(e.value)}')
        .join('\n');

    final text = '[어떤비용] ${item.title}\n\n'
        '${item.summary}\n\n'
        '$resultEntries\n\n'
        '※ 본 계산 결과는 참고용입니다.';

    ShareHelper.shareText(
      context,
      text: text,
      subject: item.title,
      title: item.title,
    );
  }

  Future<void> _toggleFavorite() async {
    final item = _item;
    if (item == null) return;
    final repo = ref.read(calculationHistoryRepositoryProvider);
    await repo.toggleFavorite(item.id);
    await _load();
  }

  Future<void> _saveMemo() async {
    final item = _item;
    if (item == null) return;
    setState(() => _isSavingMemo = true);
    final repo = ref.read(calculationHistoryRepositoryProvider);
    await repo.updateMemo(item.id, _memoController.text.trim());
    await _load();
    if (!mounted) return;
    setState(() => _isSavingMemo = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('메모가 저장되었습니다.')),
    );
  }

  Future<void> _exportCsv() async {
    final item = _item;
    if (item == null) return;

    final rows = <List<String>>[
      ['구분', '항목', '값'],
      ['요약', '제목', item.title],
      ['요약', '계산 유형', item.type.label],
      ['요약', '저장일시', item.createdAt.toIso8601String()],
      ['요약', '결과 요약', item.summary],
      ['요약', '메모', item.memo],
      ...item.input.entries.map(
        (e) => ['입력값', _labelForKey(e.key), _formatValue(e.value)],
      ),
      ...item.result.entries.map(
        (e) => ['계산 결과', _labelForKey(e.key), _formatValue(e.value)],
      ),
    ];
    final csv = rows.map((row) => row.map(_escapeCsv).join(',')).join('\n');
    final file = await _writeExportFile(item, 'csv', csv.codeUnits);
    if (!mounted) return;
    await ShareHelper.shareFiles(
      context,
      files: [
        XFile(
          file.path,
          mimeType: 'text/csv',
          name: '${_safeFileName(item)}.csv',
        ),
      ],
      text: '${item.title} CSV',
      subject: item.title,
      title: '${item.title} CSV',
    );
  }

  Future<void> _exportPdf() async {
    final item = _item;
    if (item == null) return;

    final font = await PdfGoogleFonts.nanumGothicRegular();
    final bold = await PdfGoogleFonts.nanumGothicBold();
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font, bold: bold),
        build: (context) => [
          pw.Text(item.title, style: pw.TextStyle(fontSize: 22, font: bold)),
          pw.SizedBox(height: 8),
          pw.Text(item.type.label, style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 16),
          _pdfSection('결과 요약', [item.summary]),
          _pdfKeyValueSection('입력값', item.input),
          _pdfKeyValueSection('계산 결과', item.result),
          if (item.memo.trim().isNotEmpty) _pdfSection('메모', [item.memo]),
          pw.SizedBox(height: 16),
          pw.Text(
            '본 계산 결과는 참고용입니다.',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
      ),
    );

    final file = await _writeExportFile(item, 'pdf', await doc.save());
    if (!mounted) return;
    await ShareHelper.shareFiles(
      context,
      files: [
        XFile(
          file.path,
          mimeType: 'application/pdf',
          name: '${_safeFileName(item)}.pdf',
        ),
      ],
      text: '${item.title} PDF',
      subject: item.title,
      title: '${item.title} PDF',
    );
  }

  pw.Widget _pdfSection(String title, List<String> lines) {
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

  pw.Widget _pdfKeyValueSection(String title, Map<String, dynamic> values) {
    return _pdfSection(
      title,
      values.entries
          .map((e) => '${_labelForKey(e.key)}: ${_formatValue(e.value)}')
          .toList(),
    );
  }

  Future<File> _writeExportFile(
    CalculationHistory item,
    String extension,
    List<int> bytes,
  ) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${_safeFileName(item)}.$extension');
    return file.writeAsBytes(bytes, flush: true);
  }

  String _safeFileName(CalculationHistory item) {
    final safeTitle = item.title.replaceAll(RegExp(r'[^a-zA-Z0-9가-힣_-]'), '_');
    return '${safeTitle}_${item.id}';
  }

  String _escapeCsv(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  String _formatValue(dynamic value) {
    if (value == null) return '없음';
    if (value is int) return MoneyFormatter.formatWithWon(value);
    if (value is double) return '$value%';
    if (value is bool) return value ? '예' : '아니오';
    final text = value.toString();
    const valueLabels = {
      'sale': '매매',
      'lease': '임대차',
      'one': '1주택',
      'two': '2주택',
      'threePlus': '3주택 이상',
    };
    return valueLabels[text] ?? text;
  }

  String _labelForKey(String key) {
    const labels = {
      'jeonseDeposit': '전세 보증금',
      'jeonseLoan': '전세 대출금',
      'interestRate': '연이율',
      'monthlyRentDeposit': '월세 보증금',
      'monthlyRent': '월세',
      'maintenanceFee': '관리비',
      'months': '기간',
      'depositInterestRate': '예금 금리',
      'jeonseMonthlyCost': '전세 월 비용',
      'rentMonthlyCost': '월세 월 비용',
      'monthlyDifference': '월 차이',
      'totalDifference': '총 차이',
      'baseDeposit': '기준 보증금',
      'convertedDeposit': '전환 보증금',
      'conversionRate': '전월세 전환율',
      'fairMonthlyRent': '적정 월세',
      'actualMonthlyRent': '실제 월세',
      'loanAmount': '대출금',
      'monthlyInterest': '월 이자',
      'totalInterest': '총 이자',
      'totalMonthly': '월 합계',
      'totalAnnual': '연간 합계',
      'annualIncome': '연소득',
      'housingDebt': '주택담보대출 연간 원리금',
      'otherDebt': '기타대출 연간 원리금',
      'DSR': 'DSR',
      'DTI': 'DTI',
      'transactionType': '거래 유형',
      'transactionAmount': '거래 금액',
      'brokerageFee': '중개보수',
      'ratePercent': '적용 세율',
      'cap': '한도액',
      'price': '주택 취득가액',
      'houseCount': '보유 주택 수',
      'regulatedArea': '조정대상지역',
      'acquisitionTax': '취득세',
      'annualSalary': '연간 총급여',
      'annualLoanRepayment': '연간 대출 상환액',
      'incomeTaxRate': '소득세율',
      'deductibleRent': '월세 공제 대상액',
      'rentTaxCredit': '월세 세액공제',
      'loanDeduction': '전세대출 공제',
      'totalDeduction': '총 공제 예상액',
      'currentDeposit': '현재 보증금',
      'currentMonthlyRent': '현재 월세',
      'increaseRate': '증액 상한율',
      'maxDeposit': '갱신 보증금 상한',
      'maxMonthlyRent': '갱신 월세 상한',
      'depositIncrease': '보증금 증액분',
      'monthlyRentIncrease': '월세 증액분',
      'marketPrice': '주택 예상 시세',
      'deposit': '전세 보증금',
      'seniorDebt': '선순위채권/근저당',
      'checkedRegistry': '등기부 확인',
      'ownerMatched': '소유자 일치',
      'checkedTaxArrears': '세금 체납 확인',
      'canJoinGuaranteeInsurance': '보증보험 가능',
      'willReportMoveIn': '전입신고 예정',
      'willGetFixedDate': '확정일자 예정',
      'riskScore': '위험 점수',
      'riskLevel': '위험 등급',
      'jeonseRatio': '전세가율',
      'seniorDebtRatio': '선순위채권 비율',
      'combinedDebtRatio': '보증금+선순위채권 비율',
    };
    return labels[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;

    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('계산 결과를 찾을 수 없습니다.')),
      );
    }

    final date = item.createdAt;
    final dateStr =
        '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(item.title),
        actions: [
          IconButton(
            icon: Icon(item.isFavorite ? Icons.star : Icons.star_border),
            onPressed: _toggleFavorite,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'csv') _exportCsv();
              if (value == 'pdf') _exportPdf();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'csv', child: Text('CSV 내보내기')),
              PopupMenuItem(value: 'pdf', child: Text('PDF 내보내기')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _share,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(dateStr, style: AppTextStyles.caption),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('결과 요약', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  Text(item.summary, style: AppTextStyles.body),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('메모', style: AppTextStyles.label),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _memoController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: '계산과 관련된 메모를 남겨두세요',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _isSavingMemo ? null : _saveMemo,
                      icon: _isSavingMemo
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined, size: 18),
                      label: const Text('저장'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('계산 결과', style: AppTextStyles.label),
                  const SizedBox(height: 12),
                  ...item.result.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _labelForKey(e.key),
                                style: AppTextStyles.bodySecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(_formatValue(e.value),
                                style: AppTextStyles.body),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
