import 'calculation_pdf_exporter.dart';

/// PDF 내보내기의 한국어 고정 문구.
///
/// [CalculationPdfExporter]는 문구를 주입받기만 하므로 로케일별 문구는
/// 표현 계층이 소유한다. 계산기 화면에 l10n이 배선되면 각 화면이 이 상수 대신
/// `AppLocalizations` 값으로 [PdfExportLabels]를 만들고 이 파일은 삭제한다.
const PdfExportLabels kKoreanPdfExportLabels = PdfExportLabels(
  brandMark: '어',
  documentTitle: '어떤비용 계산 결과',
  summarySectionTitle: '결과 요약',
  resultSectionTitle: '계산 결과',
  inputSectionTitle: '입력값',
  disclaimer: '본 계산 결과는 참고용입니다. 실제 계약 전 전문가와 관련 기관에 확인하세요.',
);
