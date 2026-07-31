import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppGuideScreen extends StatefulWidget {
  const AppGuideScreen({super.key});

  @override
  State<AppGuideScreen> createState() => _AppGuideScreenState();
}

class _AppGuideScreenState extends State<AppGuideScreen> {
  final _controller = PageController();
  int _page = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _wrapPage(const _IntroPanel()),
      _wrapPage(const _CategoryPage(
        title: '임대차 계산',
        subtitle: '전월세 비용 비교와 반전세 적정가를 확인합니다.',
        cards: [
          _FeatureGuideCard(
            icon: Icons.compare_arrows_rounded,
            color: AppColors.primary,
            title: '전세 vs 월세 비교',
            summary: '전세 대출이자와 월세를 같은 기간 기준으로 비교합니다.',
            steps: ['전세 보증금, 대출금, 금리 입력', '월세 보증금과 월세 입력', '월 비용과 총 비용 차이 확인'],
            preview: _JeonseMoonsePreview(),
          ),
          _FeatureGuideCard(
            icon: Icons.swap_horiz_rounded,
            color: Color(0xFF7C3AED),
            title: '반전세 계산',
            summary: '보증금 차액을 월세로 바꿨을 때 적정한지 확인합니다.',
            steps: ['기존 보증금과 변경 보증금 입력', '월세와 전월세 전환율 입력', '과하거나 유리한 월세인지 확인'],
            preview: _HalfJeonsePreview(),
          ),
        ],
      )),
      _wrapPage(const _CategoryPage(
        title: '대출 · 금융',
        subtitle: '대출 이자, 상환 한도, 월 지출을 계산합니다.',
        cards: [
          _FeatureGuideCard(
            icon: Icons.account_balance_rounded,
            color: AppColors.warning,
            title: '대출이자 계산',
            summary: '대출금, 금리, 기간으로 월 이자와 총 이자를 계산합니다.',
            steps: ['대출금 입력', '연 금리와 개월 수 입력', '월 이자와 기간 총 이자 확인'],
            preview: _LoanInterestPreview(),
          ),
          _FeatureGuideCard(
            icon: Icons.speed_rounded,
            color: Color(0xFF0F766E),
            title: 'DSR/DTI 계산',
            summary: '연소득 대비 대출 상환 부담을 비율로 확인합니다.',
            steps: ['연소득 입력', '주택담보대출과 기타 대출 입력', 'DSR/DTI 비율 확인'],
            preview: _DsrDtiPreview(),
          ),
          _FeatureGuideCard(
            icon: Icons.receipt_long_rounded,
            color: AppColors.positive,
            title: '월 고정비 계산',
            summary: '주거비와 생활비를 합산해 월 지출 구조를 봅니다.',
            steps: ['월세, 관리비, 통신비 등 항목 입력', '월 합계와 연간 합계 확인', '저장 후 반복 지출 비교'],
            preview: _MonthlyFixedPreview(),
          ),
        ],
      )),
      _wrapPage(const _CategoryPage(
        title: '세금 · 비용',
        subtitle: '주거 관련 세금과 비용을 간이 계산합니다.',
        cards: [
          _FeatureGuideCard(
            icon: Icons.receipt_outlined,
            color: Color(0xFF0891B2),
            title: '연말정산 세액공제',
            summary: '월세와 전세대출 관련 공제 가능 금액을 간이 계산합니다.',
            steps: ['소득과 주거 유형 선택', '월세 또는 전세대출 조건 입력', '예상 공제액 확인'],
            preview: _TaxDeductionPreview(),
          ),
          _FeatureGuideCard(
            icon: Icons.handshake_outlined,
            color: Color(0xFF9333EA),
            title: '중개보수 계산',
            summary: '매매와 임대차 중개보수 상한을 빠르게 확인합니다.',
            steps: ['거래 유형 선택', '거래 금액 입력', '상한 요율과 예상 보수 확인'],
            preview: _BrokerFeePreview(),
          ),
          _FeatureGuideCard(
            icon: Icons.account_balance_wallet_outlined,
            color: Color(0xFFBE123C),
            title: '취득세 계산',
            summary: '취득가액, 보유 주택 수, 지역 조건으로 간이 계산합니다.',
            steps: ['취득가액 입력', '보유 주택 수와 조정지역 여부 선택', '세율과 예상 세액 확인'],
            preview: _AcquisitionTaxPreview(),
          ),
        ],
      )),
      _wrapPage(const _LastPage()),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('앱 설명 및 사용법')),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _page = i),
              children: _pages,
            ),
          ),
          _PageDots(
            count: _pages.length,
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
                color: active
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.22),
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: AppColors.cardBorder),
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
                    Text(AppConstants.appName, style: AppTextStyles.heading2),
                    const SizedBox(height: 4),
                    Text(
                      '계산부터 저장, 공유까지 한 흐름으로 사용하는 생활금융 계산 앱입니다.',
                      style: AppTextStyles.bodySecondary,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Column(
        children: [
          _StaticFlowItem(
            icon: Icons.touch_app_outlined,
            color: AppColors.primary,
            title: '1. 계산기 선택',
            body: '홈에서 필요한 주거 비용 계산기를 고릅니다.',
          ),
          _StaticFlowArrow(),
          _StaticFlowItem(
            icon: Icons.edit_note_outlined,
            color: AppColors.warning,
            title: '2. 금액과 조건 입력',
            body: '입력 금액은 3억2천만원처럼 한글 금액으로 함께 표시됩니다.',
          ),
          _StaticFlowArrow(),
          _StaticFlowItem(
            icon: Icons.bar_chart_rounded,
            color: AppColors.positive,
            title: '3. 결과 저장과 공유',
            body: '계산 결과를 저장하고 최근계산 탭에서 PDF/CSV로 내보냅니다.',
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
              Text(title, style: AppTextStyles.heading3.copyWith(fontSize: 16)),
              const SizedBox(height: 4),
              Text(body, style: AppTextStyles.bodySecondary),
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
    return const Padding(
      padding: EdgeInsets.only(left: 19, top: 8, bottom: 8),
      child: SizedBox(
        height: 16,
        child: VerticalDivider(color: AppColors.divider),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.heading2),
        const SizedBox(height: 4),
        Text(subtitle, style: AppTextStyles.bodySecondary),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: AppColors.cardBorder),
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
                    Text(title, style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text(summary, style: AppTextStyles.bodySecondary),
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
          Expanded(child: Text(text, style: AppTextStyles.bodySecondary)),
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
            child: Text(label, style: AppTextStyles.bodySecondary),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('전세 월비용',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.primary)),
                    const SizedBox(height: 6),
                    Text('대출이자',
                        style:
                            AppTextStyles.bodySecondary.copyWith(fontSize: 11)),
                    Text('+ 자기자본 기회비용',
                        style:
                            AppTextStyles.bodySecondary.copyWith(fontSize: 11)),
                    const SizedBox(height: 6),
                    const Text('월 116만원',
                        style: TextStyle(
                            color: AppColors.primary,
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
                  color: AppColors.warning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('월세 월비용',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.warning)),
                    const SizedBox(height: 6),
                    Text('월세 + 관리비',
                        style:
                            AppTextStyles.bodySecondary.copyWith(fontSize: 11)),
                    Text('+ 보증금 기회비용',
                        style:
                            AppTextStyles.bodySecondary.copyWith(fontSize: 11)),
                    const SizedBox(height: 6),
                    const Text('월 145만원',
                        style: TextStyle(
                            color: AppColors.warning,
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
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '기회비용 = 보증금 × 시중금리 ÷ 12',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.primary,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FormulaBox(
          formula: '적정월세 = (전세금 − 보증금) × 전환율 ÷ 12',
          color: Color(0xFF7C3AED),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('전환율 법정 상한',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                    SizedBox(height: 4),
                    Text('기준금리 + 2%p',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7C3AED))),
                  ],
                ),
              ),
              SizedBox(
                  width: 1,
                  height: 36,
                  child: ColoredBox(color: AppColors.divider)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('현재 전환율 예시',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                    SizedBox(height: 4),
                    Text('약 4.5%',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7C3AED))),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FormulaBox(
          formula: '월 이자 = 대출금 × 연이율 ÷ 12\n총 이자 = 월 이자 × 기간(개월)',
          color: AppColors.warning,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('예시: 3억2천 × 4.0% ÷ 12', style: AppTextStyles.caption),
                  _InfoChip(label: '단리(거치식)', color: AppColors.warning),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('월 이자',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                  Text('1,066,667원',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warning)),
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

  static const _categories = [
    (Icons.home_outlined, '주거비'),
    (Icons.settings_outlined, '관리비'),
    (Icons.phone_outlined, '통신비'),
    (Icons.directions_bus_outlined, '교통비'),
    (Icons.health_and_safety_outlined, '보험료'),
    (Icons.subscriptions_outlined, '구독료'),
  ];

  @override
  Widget build(BuildContext context) {
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
          children: _categories
              .map((c) => Container(
                    decoration: BoxDecoration(
                      color: AppColors.positive.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(c.$1, size: 13, color: AppColors.positive),
                        const SizedBox(width: 4),
                        Text(c.$2,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.positive.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('월 합계 → 연간 합계',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text('× 12개월 자동 계산',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.positive)),
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
    const color = Color(0xFF0891B2);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.home_outlined, size: 14, color: color),
              SizedBox(width: 4),
              Text('월세 세액공제',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          SizedBox(height: 6),
          _TableRow(label: '총급여 5,500만원 이하', value: '17%', valueColor: color),
          _TableRow(label: '5,500 ~ 8,000만원', value: '15%', valueColor: color),
          _TableRow(label: '8,000만원 초과', value: '공제 불가'),
          Divider(height: 16),
          Row(
            children: [
              Icon(Icons.apartment_outlined, size: 14, color: color),
              SizedBox(width: 4),
              Text('전세대출 소득공제',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          SizedBox(height: 6),
          _TableRow(
              label: '원리금 상환액 × 40%', value: '한도 300만원', valueColor: color),
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormulaBox(
          formula:
              'DSR = 모든대출 연간 원리금 ÷ 연소득 × 100%\nDTI = (주담대 원리금 + 기타 이자) ÷ 연소득 × 100%',
          color: Color(0xFF0F766E),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child: _DsrBand(
                    label: '안전', range: '~40%', color: AppColors.positive)),
            SizedBox(width: 4),
            Expanded(
                child: _DsrBand(
                    label: '주의', range: '40~60%', color: AppColors.warning)),
            SizedBox(width: 4),
            Expanded(
                child: _DsrBand(
                    label: '위험', range: '60%+', color: AppColors.danger)),
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
    const color = Color(0xFF9333EA);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('거래 유형 / 금액',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary)),
              ),
              Expanded(
                flex: 2,
                child: Text('상한 요율',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ),
            ],
          ),
          Divider(height: 12),
          _TableRow(label: '매매 · 5억 미만', value: '0.4%'),
          _TableRow(label: '매매 · 5억 이상', value: '0.5~0.7%'),
          _TableRow(label: '임대차 · 1억 미만', value: '0.3%'),
          _TableRow(label: '임대차 · 1억 이상', value: '0.4~0.5%'),
          Divider(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _InfoChip(label: '부가세 10% 별도', color: color),
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
    const color = Color(0xFFBE123C);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('보유 주택 수 / 조건',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary)),
              ),
              Expanded(
                flex: 2,
                child: Text('세율',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ),
            ],
          ),
          Divider(height: 12),
          _TableRow(label: '1주택 · 6억 이하', value: '1%'),
          _TableRow(label: '1주택 · 6~9억', value: '1~3% 구간'),
          _TableRow(label: '1주택 · 9억 초과', value: '3%'),
          _TableRow(label: '2주택 (조정지역)', value: '8%'),
          _TableRow(label: '3주택 이상', value: '12%', valueColor: color),
          Divider(height: 12),
          Row(
            children: [
              _InfoChip(label: '농특세·교육세 포함 시 추가', color: color),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('저장한 계산 활용', style: AppTextStyles.heading2),
        const SizedBox(height: 10),
        _GuidePanel(
          child: Column(
            children: [
              _VisualFlowStep(
                  icon: Icons.save_outlined,
                  title: '결과 저장',
                  body: '계산 결과 화면에서 저장하면 최근계산 탭에 기록됩니다.'),
              _FlowDivider(),
              _VisualFlowStep(
                  icon: Icons.star_border,
                  title: '즐겨찾기와 메모',
                  body: '자주 보는 계산은 즐겨찾기하고, 상세 화면에서 메모를 남길 수 있습니다.'),
              _FlowDivider(),
              _VisualFlowStep(
                  icon: Icons.picture_as_pdf_outlined,
                  title: 'PDF/CSV 공유',
                  body: '상세 화면에서 PDF와 CSV로 내보내거나 공유합니다.'),
            ],
          ),
        ),
        SizedBox(height: 16),
        Text('계정, 동기화, 공지', style: AppTextStyles.heading2),
        SizedBox(height: 10),
        _GuidePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InlineVisualHeader(
                icon: Icons.cloud_sync_outlined,
                title: '로그인하면 기록이 동기화됩니다',
                color: AppColors.primary,
              ),
              SizedBox(height: 10),
              Text(
                '오프라인 상태에서는 로컬에 먼저 저장되고, 네트워크가 가능할 때 서버와 맞춰집니다.',
                style: AppTextStyles.bodySecondary,
              ),
              SizedBox(height: 14),
              _SyncIllustration(),
              SizedBox(height: 14),
              _InlineVisualHeader(
                icon: Icons.lock_outline,
                title: 'PIN과 생체인증으로 앱 재진입 보호',
                color: AppColors.positive,
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        _GuidePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InlineVisualHeader(
                icon: Icons.campaign_outlined,
                title: '공지와 푸시 알림',
                color: AppColors.warning,
              ),
              SizedBox(height: 10),
              Text(
                '공지사항은 설정에서 확인할 수 있고, 로그인 상태에서 푸시 알림을 켜면 새 공지 등록 시 알림을 받을 수 있습니다.',
                style: AppTextStyles.bodySecondary,
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        _GuidePanel(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: AppColors.textSecondary),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '앱의 계산 결과는 입력값을 기준으로 한 참고용 간이 계산입니다. 실제 대출, 세금, 중개보수, 계약 조건은 지역, 시점, 개인 상황, 관련 법령에 따라 달라질 수 있으므로 최종 결정 전 전문가 또는 공식 기관을 통해 확인해야 합니다.',
                  style: AppTextStyles.disclaimer,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: AppColors.cardBorder),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.heading3.copyWith(fontSize: 16)),
              const SizedBox(height: 4),
              Text(body, style: AppTextStyles.bodySecondary),
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
    return const Padding(
      padding: EdgeInsets.only(left: 18, top: 8, bottom: 8),
      child: SizedBox(
          height: 18, child: VerticalDivider(color: AppColors.divider)),
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
                style: AppTextStyles.heading3.copyWith(fontSize: 16))),
      ],
    );
  }
}

class _SyncIllustration extends StatelessWidget {
  const _SyncIllustration();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _SyncNode(icon: Icons.phone_android, label: '앱')),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.sync_alt, color: AppColors.primary),
        ),
        Expanded(child: _SyncNode(icon: Icons.cloud_outlined, label: '서버')),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
