import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppGuideScreen extends StatelessWidget {
  const AppGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('앱 설명 및 사용법')),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        children: [
          const _IntroPanel(),
          const SizedBox(height: 16),
          const _SectionTitle('계산 기능별 사용법'),
          const SizedBox(height: 10),
          _FeatureGuideCard(
            icon: Icons.compare_arrows_rounded,
            color: AppColors.primary,
            title: '전세 vs 월세 비교',
            summary: '전세 대출이자와 월세를 같은 기간 기준으로 비교합니다.',
            steps: const [
              '전세 보증금, 대출금, 금리 입력',
              '월세 보증금과 월세 입력',
              '월 비용과 총 비용 차이 확인'
            ],
            preview: _ComparisonPreview(),
          ),
          const _FeatureGuideCard(
            icon: Icons.swap_horiz_rounded,
            color: Color(0xFF7C3AED),
            title: '반전세 계산',
            summary: '보증금 차액을 월세로 바꿨을 때 적정한지 확인합니다.',
            steps: ['기존 보증금과 변경 보증금 입력', '월세와 전월세 전환율 입력', '과하거나 유리한 월세인지 확인'],
            preview: _RatePreview(
                label: '전환율', value: '4.5%', color: Color(0xFF7C3AED)),
          ),
          const _FeatureGuideCard(
            icon: Icons.account_balance_rounded,
            color: AppColors.warning,
            title: '대출이자 계산',
            summary: '대출금, 금리, 기간으로 월 이자와 총 이자를 계산합니다.',
            steps: ['대출금 입력', '연 금리와 개월 수 입력', '월 이자와 기간 총 이자 확인'],
            preview: _AmountPreview(
                title: '월 이자', amount: '1,066,667원', label: '대출금 3억2천만원'),
          ),
          _FeatureGuideCard(
            icon: Icons.receipt_long_rounded,
            color: AppColors.positive,
            title: '월 고정비 계산',
            summary: '주거비와 생활비를 합산해 월 지출 구조를 봅니다.',
            steps: const [
              '월세, 관리비, 통신비 등 항목 입력',
              '월 합계와 연간 합계 확인',
              '저장 후 반복 지출 비교'
            ],
            preview: _ExpensePreview(),
          ),
          const _FeatureGuideCard(
            icon: Icons.receipt_outlined,
            color: Color(0xFF0891B2),
            title: '연말정산 세액공제',
            summary: '월세와 전세대출 관련 공제 가능 금액을 간이 계산합니다.',
            steps: ['소득과 주거 유형 선택', '월세 또는 전세대출 조건 입력', '예상 공제액 확인'],
            preview: _AmountPreview(
                title: '예상 공제', amount: '750,000원', label: '입력 조건 기준'),
          ),
          const _FeatureGuideCard(
            icon: Icons.speed_rounded,
            color: Color(0xFF0F766E),
            title: 'DSR/DTI 계산',
            summary: '연소득 대비 대출 상환 부담을 비율로 확인합니다.',
            steps: ['연소득 입력', '주택담보대출과 기타 대출 입력', 'DSR/DTI 비율 확인'],
            preview: _RatePreview(
                label: 'DSR', value: '38.4%', color: Color(0xFF0F766E)),
          ),
          const _FeatureGuideCard(
            icon: Icons.handshake_outlined,
            color: Color(0xFF9333EA),
            title: '중개보수 계산',
            summary: '매매와 임대차 중개보수 상한을 빠르게 확인합니다.',
            steps: ['거래 유형 선택', '거래 금액 입력', '상한 요율과 예상 보수 확인'],
            preview: _AmountPreview(
                title: '중개보수 상한', amount: '1,200,000원', label: '주택 임대차 기준'),
          ),
          const _FeatureGuideCard(
            icon: Icons.account_balance_wallet_outlined,
            color: Color(0xFFBE123C),
            title: '취득세 계산',
            summary: '취득가액, 보유 주택 수, 지역 조건으로 간이 계산합니다.',
            steps: ['취득가액 입력', '보유 주택 수와 조정지역 여부 선택', '세율과 예상 세액 확인'],
            preview: _AmountPreview(
                title: '예상 취득세', amount: '4,800,000원', label: '입력 조건 기준'),
          ),
          const SizedBox(height: 16),
          const _SectionTitle('저장한 계산 활용'),
          const SizedBox(height: 10),
          const _WorkflowPanel(),
          const SizedBox(height: 16),
          const _SectionTitle('계정, 동기화, 공지'),
          const SizedBox(height: 10),
          const _AccountGuidePanel(),
          const SizedBox(height: 16),
          const _NoticeGuidePanel(),
          const SizedBox(height: 16),
          const _DisclaimerPanel(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppConstants.appName, style: AppTextStyles.heading2),
                    SizedBox(height: 4),
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

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.heading2);
  }
}

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
      margin: const EdgeInsets.only(bottom: 12),
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

class _ComparisonPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
            child: _MiniResultColumn(
                label: '전세', amount: '월 116만원', color: AppColors.primary)),
        SizedBox(width: 10),
        Expanded(
            child: _MiniResultColumn(
                label: '월세', amount: '월 145만원', color: AppColors.warning)),
      ],
    );
  }
}

class _MiniResultColumn extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _MiniResultColumn({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 6),
          Text(amount,
              style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _RatePreview extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _RatePreview({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.donut_large_rounded, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTextStyles.bodySecondary)),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _AmountPreview extends StatelessWidget {
  final String title;
  final String amount;
  final String label;

  const _AmountPreview({
    required this.title,
    required this.amount,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.caption),
          const SizedBox(height: 6),
          Text(amount,
              style: AppTextStyles.resultAmount.copyWith(fontSize: 22)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _ExpensePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      ('주거비', 0.72),
      ('관리비', 0.32),
      ('통신비', 0.22),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.positive.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                        width: 52,
                        child: Text(item.$1, style: AppTextStyles.caption)),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: item.$2,
                          backgroundColor: Colors.white,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.positive),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _WorkflowPanel extends StatelessWidget {
  const _WorkflowPanel();

  @override
  Widget build(BuildContext context) {
    return const _GuidePanel(
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
    );
  }
}

class _AccountGuidePanel extends StatelessWidget {
  const _AccountGuidePanel();

  @override
  Widget build(BuildContext context) {
    return _GuidePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InlineVisualHeader(
            icon: Icons.cloud_sync_outlined,
            title: '로그인하면 기록이 동기화됩니다',
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          const Text(
            '오프라인 상태에서는 로컬에 먼저 저장되고, 네트워크가 가능할 때 서버와 맞춰집니다.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 14),
          _SyncIllustration(),
          const SizedBox(height: 14),
          const _InlineVisualHeader(
            icon: Icons.lock_outline,
            title: 'PIN과 생체인증으로 앱 재진입 보호',
            color: AppColors.positive,
          ),
        ],
      ),
    );
  }
}

class _NoticeGuidePanel extends StatelessWidget {
  const _NoticeGuidePanel();

  @override
  Widget build(BuildContext context) {
    return const _GuidePanel(
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
    );
  }
}

class _DisclaimerPanel extends StatelessWidget {
  const _DisclaimerPanel();

  @override
  Widget build(BuildContext context) {
    return const _GuidePanel(
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
    );
  }
}

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
