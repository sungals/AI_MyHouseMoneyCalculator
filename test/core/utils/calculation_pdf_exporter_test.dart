import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/core/utils/calculation_pdf_exporter.dart';
import 'package:house_money_calculator/core/utils/pdf_export_labels_ko.dart';

void main() {
  group('PdfExportLabels', () {
    test('내보내기 라벨은 호출부가 주입한다', () {
      // Arrange & Act
      const labels = PdfExportLabels(
        brandMark: 'H',
        documentTitle: 'Calculation Result',
        summarySectionTitle: 'Summary',
        resultSectionTitle: 'Result',
        inputSectionTitle: 'Inputs',
        disclaimer: 'This is a reference estimate.',
      );

      // Assert
      expect(labels.brandMark, 'H');
      expect(labels.documentTitle, 'Calculation Result');
      expect(labels.summarySectionTitle, 'Summary');
      expect(labels.resultSectionTitle, 'Result');
      expect(labels.inputSectionTitle, 'Inputs');
      expect(labels.disclaimer, 'This is a reference estimate.');
    });

    test('같은 문구를 담은 두 라벨 객체는 동등하다', () {
      // Arrange
      const first = PdfExportLabels(
        brandMark: 'H',
        documentTitle: 'Calculation Result',
        summarySectionTitle: 'Summary',
        resultSectionTitle: 'Result',
        inputSectionTitle: 'Inputs',
        disclaimer: 'Reference only.',
      );
      const second = PdfExportLabels(
        brandMark: 'H',
        documentTitle: 'Calculation Result',
        summarySectionTitle: 'Summary',
        resultSectionTitle: 'Result',
        inputSectionTitle: 'Inputs',
        disclaimer: 'Reference only.',
      );

      // Assert
      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('문구가 하나라도 다르면 동등하지 않다', () {
      // Arrange
      const base = PdfExportLabels(
        brandMark: 'H',
        documentTitle: 'Calculation Result',
        summarySectionTitle: 'Summary',
        resultSectionTitle: 'Result',
        inputSectionTitle: 'Inputs',
        disclaimer: 'Reference only.',
      );
      const other = PdfExportLabels(
        brandMark: 'H',
        documentTitle: 'Calculation Result',
        summarySectionTitle: 'Summary',
        resultSectionTitle: 'Result',
        inputSectionTitle: 'Inputs',
        disclaimer: 'Different disclaimer.',
      );

      // Assert
      expect(base, isNot(other));
    });
  });

  group('kKoreanPdfExportLabels', () {
    test('한국어 기본 라벨은 표현 계층이 소유한 상수로 제공된다', () {
      // Assert
      expect(kKoreanPdfExportLabels.brandMark, '어');
      expect(kKoreanPdfExportLabels.documentTitle, '어떤비용 계산 결과');
      expect(kKoreanPdfExportLabels.summarySectionTitle, '결과 요약');
      expect(kKoreanPdfExportLabels.resultSectionTitle, '계산 결과');
      expect(kKoreanPdfExportLabels.inputSectionTitle, '입력값');
      expect(
        kKoreanPdfExportLabels.disclaimer,
        '본 계산 결과는 참고용입니다. 실제 계약 전 전문가와 관련 기관에 확인하세요.',
      );
    });
  });

  group('safeFileName', () {
    test('한글과 영숫자는 유지하고 나머지 문자는 밑줄로 바꾼다', () {
      // Act
      final fileName = CalculationPdfExporter.safeFileName('전세 위험도!');

      // Assert
      expect(fileName, startsWith('전세_위험도_'));
      expect(RegExp(r'^[a-zA-Z0-9가-힣_-]+$').hasMatch(fileName), isTrue);
    });
  });
}
