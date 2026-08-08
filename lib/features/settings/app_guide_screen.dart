import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/gen/app_localizations.dart';

// 기능별 강조색. 팔레트에 대응 토큰이 없어 이 화면 안에서만 쓰는 상수다.
// 라이트 기준 값이므로 다크에서는 _accent 로 밝기를 올려 쓴다.
const _accentSemiRent = Color(0xFF7C3AED);
const _accentDsrDti = Color(0xFF0F766E);
const _accentTaxDeduction = Color(0xFF0891B2);
const _accentBrokerage = Color(0xFF9333EA);
const _accentAcquisition = Color(0xFFBE123C);

/// 강조색을 현재 밝기에 맞춘다. 다크에서 원색을 그대로 쓰면 어두운 surface 위
/// 저대비가 되므로 명도만 올린다. 색상(hue)은 유지해 기능별 구분을 지킨다.
Color _accent(BuildContext context, Color base) {
  if (Theme.of(context).brightness != Brightness.dark) return base;
  final hsl = HSLColor.fromColor(base);
  return hsl.withLightness((hsl.lightness + 0.25).clamp(0.0, 1.0)).toColor();
}

class AppGuideScreen extends StatefulWidget {
  const AppGuideScreen({super.key});

  @override
  State<AppGuideScreen> createState() => _AppGuideScreenState();
}

class _AppGuideScreenState extends State<AppGuideScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 페이지 목록은 로케일과 테마에 의존하므로 build 에서 만든다.
  /// initState 에서 만들면 언어를 바꿔도 이전 언어가 남는다.
  List<Widget> _buildPages(BuildContext context, AppLocalizations l10n) {
    return [
      _wrapPage(const _IntroPanel()),
      _wrapPage(_CategoryPage(
        title: l10n.guideCategoryLeaseTitle,
        subtitle: l10n.guideCategoryLeaseSubtitle,
        cards: [
          _FeatureGuideCard(
            icon: Icons.compare_arrows_rounded,
            color: context.palette.primary,
            title: l10n.guideJeonseRentTitle,
            summary: l10n.guideJeonseRentSummary,
            steps: [
              l10n.guideJeonseRentStep1,
              l10n.guideJeonseRentStep2,
              l10n.guideJeonseRentStep3,
            ],
            preview: const _JeonseMoonsePreview(),
          ),
          _FeatureGuideCard(
            icon: Icons.swap_horiz_rounded,
            color: _accent(context, _accentSemiRent),
            title: l10n.guideSemiRentTitle,
            summary: l10n.guideSemiRentSummary,
            steps: [
              l10n.guideSemiRentStep1,
              l10n.guideSemiRentStep2,
              l10n.guideSemiRentStep3,
            ],
            preview: const _HalfJeonsePreview(),
          ),
        ],
      )),
      _wrapPage(_CategoryPage(
        title: l10n.guideCategoryFinanceTitle,
        subtitle: l10n.guideCategoryFinanceSubtitle,
        cards: [
          _FeatureGuideCard(
            icon: Icons.account_balance_rounded,
            color: context.palette.warning,
            title: l10n.guideLoanInterestTitle,
            summary: l10n.guideLoanInterestSummary,
            steps: [
              l10n.guideLoanInterestStep1,
              l10n.guideLoanInterestStep2,
              l10n.guideLoanInterestStep3,
            ],
            preview: const _LoanInterestPreview(),
          ),
          _FeatureGuideCard(
            icon: Icons.speed_rounded,
            color: _accent(context, _accentDsrDti),
            title: l10n.guideDsrDtiTitle,
            summary: l10n.guideDsrDtiSummary,
            steps: [
              l10n.guideDsrDtiStep1,
              l10n.guideDsrDtiStep2,
              l10n.guideDsrDtiStep3,
            ],
            preview: const _DsrDtiPreview(),
          ),
          _FeatureGuideCard(
            icon: Icons.receipt_long_rounded,
            color: context.palette.positive,
            title: l10n.guideMonthlyExpenseTitle,
            summary: l10n.guideMonthlyExpenseSummary,
            steps: [
              l10n.guideMonthlyExpenseStep1,
              l10n.guideMonthlyExpenseStep2,
              l10n.guideMonthlyExpenseStep3,
            ],
            preview: const _MonthlyFixedPreview(),
          ),
        ],
      )),
      _wrapPage(_CategoryPage(
        title: l10n.guideCategoryTaxTitle,
        subtitle: l10n.guideCategoryTaxSubtitle,
        cards: [
          _FeatureGuideCard(
            icon: Icons.receipt_outlined,
            color: _accent(context, _accentTaxDeduction),
            title: l10n.guideTaxDeductionTitle,
            summary: l10n.guideTaxDeductionSummary,
            steps: [
              l10n.guideTaxDeductionStep1,
              l10n.guideTaxDeductionStep2,
              l10n.guideTaxDeductionStep3,
            ],
            preview: const _TaxDeductionPreview(),
          ),
          _FeatureGuideCard(
            icon: Icons.handshake_outlined,
            color: _accent(context, _accentBrokerage),
            title: l10n.guideBrokerageFeeTitle,
            summary: l10n.guideBrokerageFeeSummary,
            steps: [
              l10n.guideBrokerageFeeStep1,
              l10n.guideBrokerageFeeStep2,
              l10n.guideBrokerageFeeStep3,
            ],
            preview: const _BrokerFeePreview(),
          ),
          _FeatureGuideCard(
            icon: Icons.account_balance_wallet_outlined,
            color: _accent(context, _accentAcquisition),
            title: l10n.guideAcquisitionTaxTitle,
            summary: l10n.guideAcquisitionTaxSummary,
            steps: [
              l10n.guideAcquisitionTaxStep1,
              l10n.guideAcquisitionTaxStep2,
              l10n.guideAcquisitionTaxStep3,
            ],
            preview: const _AcquisitionTaxPreview(),
          ),
        ],
      )),
      _wrapPage(const _LastPage()),
    ];
  }

  Widget _wrapPage(Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.horizontalPadding,
        16,
        AppConstants.horizontalPadding,
        32,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = _buildPages(context, l10n);

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: AppBar(title: Text(l10n.guideTitle)),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _page = i),
              children: pages,
            ),
          ),
          _PageDots(
            count: pages.length,
            current: _page,
            onTap: (i) => _controller.animateToPage(
              i,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ─── 페이지 도트 인디케이터 ───────────────────────────────────────

class _PageDots extends StatelessWidget {
  final int count;
  final int current;
  final ValueChanged<int> onTap;

  const _PageDots({
    required this.count,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.palette.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return GestureDetector(
          onTap: () => onTap(i),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? primary : primary.withOpacity(0.22),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ───────────────────────────── Intro ─────────────────────────────

class _IntroPanel extends StatelessWidget {
  const _IntroPanel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/icons/app_icon_1024.png',
                  width: 54,
                  height: 54,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.appTitle, style: context.typography.heading2),
                    const SizedBox(height: 4),
                    Text(
                      l10n.guideIntroTagline,
                      style: context.typography.bodySecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _StaticFlowPreview(),
        ],
      ),
    );
  }
}

class _StaticFlowPreview extends StatelessWidget {
  const _StaticFlowPreview();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // 원래 고정 hex 였다. 다크에서 배경만 밝아지므로 팔레트에서 파생시킨다.
        color: Color.alphaBlend(
          palette.primary.withOpacity(0.04),
          palette.background,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        children: [
          _StaticFlowItem(
            icon: Icons.touch_app_outlined,
            color: palette.primary,
            title: l10n.guideFlowStep1Title,
            body: l10n.guideFlowStep1Body,
          ),
          const _StaticFlowArrow(),
          _StaticFlowItem(
            icon: Icons.edit_note_outlined,
            color: palette.warning,
            title: l10n.guideFlowStep2Title,
            body: l10n.guideFlowStep2Body,
          ),
          const _StaticFlowArrow(),
          _StaticFlowItem(
            icon: Icons.bar_chart_rounded,
            color: palette.positive,
            title: l10n.guideFlowStep3Title,
            body: l10n.guideFlowStep3Body,
          ),
        ],
      ),
    );
  }
}

class _StaticFlowItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const _StaticFlowItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: typo.heading3.copyWith(fontSize: 16)),
              const SizedBox(height: 4),
              Text(body, style: typo.bodySecondary),
            ],
          ),
        ),
      ],
    );
  }
}

class _StaticFlowArrow extends StatelessWidget {
  const _StaticFlowArrow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 19, top: 8, bottom: 8),
      child: SizedBox(
        height: 16,
        child: VerticalDivider(color: context.palette.divider),
      ),
    );
  }
}

// ───────────────────────── Category Page ─────────────────────────

class _CategoryPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_FeatureGuideCard> cards;

  const _CategoryPage({
    required this.title,
    required this.subtitle,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: typo.heading2),
        const SizedBox(height: 4),
        Text(subtitle, style: typo.bodySecondary),
        const SizedBox(height: 16),
        ...cards.map((card) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: card,
            )),
      ],
    );
  }
}

// ───────────────────────────── Shared ─────────────────────────────

class _FeatureGuideCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String summary;
  final List<String> steps;
  final Widget preview;

  const _FeatureGuideCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.summary,
    required this.steps,
    required this.preview,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final typo = context.typography;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: typo.heading3),
                    const SizedBox(height: 4),
                    Text(summary, style: typo.bodySecondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          preview,
          const SizedBox(height: 14),
          ...steps.asMap().entries.map(
                (entry) => _GuideStepRow(
                  number: entry.key + 1,
                  text: entry.value,
                  color: color,
                ),
              ),
        ],
      ),
    );
  }
}

class _GuideStepRow extends StatelessWidget {
  final int number;
  final String text;
  final Color color;

  const _GuideStepRow({
    required this.number,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Text(
              '$number',
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: context.typography.bodySecondary),
          ),
        ],
      ),
    );
  }
}

// ── 공통 미니 위젯 ──

class _FormulaBox extends StatelessWidget {
  final String formula;
  final Color color;

  const _FormulaBox({required this.formula, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Text(
        formula,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _TableRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: context.typography.bodySecondary),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? context.palette.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── Feature Previews ─────────────────────────────

// 1. 전세 vs 월세 비교
class _JeonseMoonsePreview extends StatelessWidget {
  const _JeonseMoonsePreview();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final typo = context.typography;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: palette.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.guidePreviewJeonseMonthlyLabel,
                        style: typo.caption.copyWith(color: palette.primary)),
                    const SizedBox(height: 6),
                    Text(l10n.guidePreviewJeonseItem1,
                        style: typo.bodySecondary.copyWith(fontSize: 11)),
                    Text(l10n.guidePreviewJeonseItem2,
                        style: typo.bodySecondary.copyWith(fontSize: 11)),
                    const SizedBox(height: 6),
                    Text(l10n.guidePreviewJeonseAmount,
                        style: TextStyle(
                            color: palette.primary,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: palette.warning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.guidePreviewRentMonthlyLabel,
                        style: typo.caption.copyWith(color: palette.warning)),
                    const SizedBox(height: 6),
                    Text(l10n.guidePreviewRentItem1,
                        style: typo.bodySecondary.copyWith(fontSize: 11)),
                    Text(l10n.guidePreviewRentItem2,
                        style: typo.bodySecondary.copyWith(fontSize: 11)),
                    const SizedBox(height: 6),
                    Text(l10n.guidePreviewRentAmount,
                        style: TextStyle(
                            color: palette.warning,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: palette.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            l10n.guidePreviewOpportunityCostFormula,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: palette.primary,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}

// 2. 반전세 계산
class _HalfJeonsePreview extends StatelessWidget {
  const _HalfJeonsePreview();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final color = _accent(context, _accentSemiRent);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormulaBox(
          formula: l10n.guidePreviewSemiRentFormula,
          color: color,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.guidePreviewConversionCapLabel,
                        style: TextStyle(
                            fontSize: 11, color: palette.textSecondary)),
                    const SizedBox(height: 4),
                    Text(l10n.guidePreviewConversionCapValue,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: color)),
                  ],
                ),
              ),
              SizedBox(
                  width: 1,
                  height: 36,
                  child: ColoredBox(color: palette.divider)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.guidePreviewConversionExampleLabel,
                        style: TextStyle(
                            fontSize: 11, color: palette.textSecondary)),
                    const SizedBox(height: 4),
                    Text(l10n.guidePreviewConversionExampleValue,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: color)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 3. 대출이자 계산
class _LoanInterestPreview extends StatelessWidget {
  const _LoanInterestPreview();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final typo = context.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormulaBox(
          formula: l10n.guidePreviewLoanFormula,
          color: palette.warning,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: palette.warning.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.guidePreviewLoanExample, style: typo.caption),
                  _InfoChip(
                    label: l10n.guidePreviewLoanInterestType,
                    color: palette.warning,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.guidePreviewLoanMonthlyLabel,
                      style: TextStyle(
                          fontSize: 13, color: palette.textSecondary)),
                  Text(l10n.guidePreviewLoanMonthlyValue,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: palette.warning)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 4. 월 고정비 계산
class _MonthlyFixedPreview extends StatelessWidget {
  const _MonthlyFixedPreview();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final categories = <(IconData, String)>[
      (Icons.home_outlined, l10n.guidePreviewExpenseHousing),
      (Icons.settings_outlined, l10n.guidePreviewExpenseMaintenance),
      (Icons.phone_outlined, l10n.guidePreviewExpenseCommunication),
      (Icons.directions_bus_outlined, l10n.guidePreviewExpenseTransport),
      (Icons.health_and_safety_outlined, l10n.guidePreviewExpenseInsurance),
      (Icons.subscriptions_outlined, l10n.guidePreviewExpenseSubscription),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 2.4,
          children: categories
              .map((c) => Container(
                    decoration: BoxDecoration(
                      color: palette.positive.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(c.$1, size: 13, color: palette.positive),
                        const SizedBox(width: 4),
                        Text(c.$2,
                            style: TextStyle(
                                fontSize: 11, color: palette.textSecondary)),
                      ],
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: palette.positive.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.guidePreviewMonthlyToYearly,
                  style: TextStyle(fontSize: 12, color: palette.textSecondary)),
              Text(l10n.guidePreviewTimesTwelve,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: palette.positive)),
            ],
          ),
        ),
      ],
    );
  }
}

// 5. 연말정산 세액공제
class _TaxDeductionPreview extends StatelessWidget {
  const _TaxDeductionPreview();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = _accent(context, _accentTaxDeduction);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.home_outlined, size: 14, color: color),
              const SizedBox(width: 4),
              Text(l10n.guidePreviewRentTaxCreditHeader,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          _TableRow(
              label: l10n.guidePreviewSalaryUnder55,
              value: '17%',
              valueColor: color),
          _TableRow(
              label: l10n.guidePreviewSalary55To80,
              value: '15%',
              valueColor: color),
          _TableRow(
              label: l10n.guidePreviewSalaryOver80,
              value: l10n.guidePreviewNotDeductible),
          const Divider(height: 16),
          Row(
            children: [
              Icon(Icons.apartment_outlined, size: 14, color: color),
              const SizedBox(width: 4),
              Text(l10n.guidePreviewJeonseLoanDeductionHeader,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          _TableRow(
              label: l10n.guidePreviewPrincipalAndInterest,
              value: l10n.guidePreviewDeductionLimit,
              valueColor: color),
        ],
      ),
    );
  }
}

// 6. DSR/DTI 계산
class _DsrDtiPreview extends StatelessWidget {
  const _DsrDtiPreview();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormulaBox(
          formula: l10n.guidePreviewDsrDtiFormula,
          color: _accent(context, _accentDsrDti),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child: _DsrBand(
                    label: l10n.guidePreviewBandSafe,
                    range: '~40%',
                    color: palette.positive)),
            const SizedBox(width: 4),
            Expanded(
                child: _DsrBand(
                    label: l10n.guidePreviewBandCaution,
                    range: '40~60%',
                    color: palette.warning)),
            const SizedBox(width: 4),
            Expanded(
                child: _DsrBand(
                    label: l10n.guidePreviewBandRisk,
                    range: '60%+',
                    color: palette.danger)),
          ],
        ),
      ],
    );
  }
}

class _DsrBand extends StatelessWidget {
  final String label;
  final String range;
  final Color color;

  const _DsrBand({
    required this.label,
    required this.range,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(range,
              style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }
}

// 7. 중개보수 계산
class _BrokerFeePreview extends StatelessWidget {
  const _BrokerFeePreview();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final color = _accent(context, _accentBrokerage);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(l10n.guidePreviewDealTypeAmount,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: palette.textSecondary)),
              ),
              Expanded(
                flex: 2,
                child: Text(l10n.guidePreviewMaxRate,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ),
            ],
          ),
          const Divider(height: 12),
          _TableRow(label: l10n.guidePreviewSaleUnder500M, value: '0.4%'),
          _TableRow(label: l10n.guidePreviewSaleOver500M, value: '0.5~0.7%'),
          _TableRow(label: l10n.guidePreviewLeaseUnder100M, value: '0.3%'),
          _TableRow(label: l10n.guidePreviewLeaseOver100M, value: '0.4~0.5%'),
          const Divider(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _InfoChip(label: l10n.guidePreviewVatSeparate, color: color),
            ],
          ),
        ],
      ),
    );
  }
}

// 8. 취득세 계산
class _AcquisitionTaxPreview extends StatelessWidget {
  const _AcquisitionTaxPreview();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final color = _accent(context, _accentAcquisition);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(l10n.guidePreviewHomesAndCondition,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: palette.textSecondary)),
              ),
              Expanded(
                flex: 2,
                child: Text(l10n.guidePreviewTaxRate,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ),
            ],
          ),
          const Divider(height: 12),
          _TableRow(label: l10n.guidePreviewOneHomeUnder600M, value: '1%'),
          _TableRow(
              label: l10n.guidePreviewOneHome600To900M,
              value: l10n.guidePreviewRateBand1To3),
          _TableRow(label: l10n.guidePreviewOneHomeOver900M, value: '3%'),
          _TableRow(label: l10n.guidePreviewTwoHomesRegulated, value: '8%'),
          _TableRow(
              label: l10n.guidePreviewThreeOrMoreHomes,
              value: '12%',
              valueColor: color),
          const Divider(height: 12),
          Row(
            children: [
              _InfoChip(label: l10n.guidePreviewSurtaxNote, color: color),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── 마지막 페이지: 저장/계정/공지/면책 ──────────────────────────────

class _LastPage extends StatelessWidget {
  const _LastPage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final typo = context.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.guideSavedTitle, style: typo.heading2),
        const SizedBox(height: 10),
        _GuidePanel(
          child: Column(
            children: [
              _VisualFlowStep(
                  icon: Icons.save_outlined,
                  title: l10n.guideSaveResultTitle,
                  body: l10n.guideSaveResultBody),
              const _FlowDivider(),
              _VisualFlowStep(
                  icon: Icons.star_border,
                  title: l10n.guideFavoriteMemoTitle,
                  body: l10n.guideFavoriteMemoBody),
              const _FlowDivider(),
              _VisualFlowStep(
                  icon: Icons.picture_as_pdf_outlined,
                  title: l10n.guideExportShareTitle,
                  body: l10n.guideExportShareBody),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(l10n.guideAccountSyncTitle, style: typo.heading2),
        const SizedBox(height: 10),
        _GuidePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InlineVisualHeader(
                icon: Icons.cloud_sync_outlined,
                title: l10n.guideSyncHeader,
                color: palette.primary,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.guideSyncBody,
                style: typo.bodySecondary,
              ),
              const SizedBox(height: 14),
              const _SyncIllustration(),
              const SizedBox(height: 14),
              _InlineVisualHeader(
                icon: Icons.lock_outline,
                title: l10n.guidePinBiometricHeader,
                color: palette.positive,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _GuidePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InlineVisualHeader(
                icon: Icons.campaign_outlined,
                title: l10n.guideNoticePushHeader,
                color: palette.warning,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.guideNoticePushBody,
                style: typo.bodySecondary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _GuidePanel(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: palette.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.guideDisclaimer,
                  style: typo.disclaimer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────── Panels ─────────────────────────────

class _GuidePanel extends StatelessWidget {
  final Widget child;

  const _GuidePanel({required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: palette.cardBorder),
      ),
      child: child,
    );
  }
}

class _VisualFlowStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _VisualFlowStep({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final typo = context.typography;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: palette.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: palette.primary, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: typo.heading3.copyWith(fontSize: 16)),
              const SizedBox(height: 4),
              Text(body, style: typo.bodySecondary),
            ],
          ),
        ),
      ],
    );
  }
}

class _FlowDivider extends StatelessWidget {
  const _FlowDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, top: 8, bottom: 8),
      child: SizedBox(
        height: 18,
        child: VerticalDivider(color: context.palette.divider),
      ),
    );
  }
}

class _InlineVisualHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _InlineVisualHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Expanded(
            child: Text(title,
                style: context.typography.heading3.copyWith(fontSize: 16))),
      ],
    );
  }
}

class _SyncIllustration extends StatelessWidget {
  const _SyncIllustration();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _SyncNode(
            icon: Icons.phone_android,
            label: l10n.guideSyncNodeApp,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.sync_alt, color: context.palette.primary),
        ),
        Expanded(
          child: _SyncNode(
            icon: Icons.cloud_outlined,
            label: l10n.guideSyncNodeServer,
          ),
        ),
      ],
    );
  }
}

class _SyncNode extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SyncNode({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: palette.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: palette.primary),
          const SizedBox(height: 6),
          Text(label, style: context.typography.caption),
        ],
      ),
    );
  }
}
