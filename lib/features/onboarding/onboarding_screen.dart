import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _PageData(
      color: AppColors.primary,
      title: '어떤비용에 오신 걸\n환영합니다',
      body: '주거 계약, 대출, 세금, 고정비까지\n계산 결과를 한곳에서 확인합니다.',
      preview: _HomePreview(),
    ),
    _PageData(
      color: Color(0xFF2563EB),
      title: '전월세 조건을\n나란히 비교하세요',
      body: '전세 vs 월세뿐 아니라 금리 A/B/C 조건까지\n복수 시나리오로 비교할 수 있습니다.',
      preview: _ScenarioPreview(),
    ),
    _PageData(
      color: Color(0xFFDC2626),
      title: '계약 전 위험 신호를\n먼저 확인하세요',
      body: '계약 갱신 5% 상한과 전세사기 위험도 체크로\n권리관계와 보증금 보호 항목을 점검합니다.',
      preview: _ContractSafetyPreview(),
    ),
    _PageData(
      color: Color(0xFF0F766E),
      title: '대출 부담과 세금도\n간단히 계산하세요',
      body: 'DSR/DTI, 연말정산 세액공제,\n중개보수와 취득세까지 함께 확인합니다.',
      preview: _FinanceTaxPreview(),
    ),
    _PageData(
      color: Color(0xFF7C3AED),
      title: '계산 결과를 저장하고\n다시 꺼내보세요',
      body: '결과는 저장, 공유, PDF 내보내기로\n계약 검토와 비교 자료로 활용할 수 있습니다.',
      preview: _ResultPreview(),
    ),
  ];

  Future<void> _finish() async {
    final box = Hive.box('app_settings');
    await box.put('onboarding_done', true);
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    final current = _pages[_page];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text(
                    '건너뛰기',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
              ),
            ),
            _Dots(count: _pages.length, current: _page, color: current.color),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: current.color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLast
                      ? _finish
                      : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                  child: Text(
                    isLast ? '시작하기' : '다음',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _PageData {
  final Color color;
  final String title;
  final String body;
  final Widget preview;

  const _PageData({
    required this.color,
    required this.title,
    required this.body,
    required this.preview,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _PageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 650;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PhoneFrame(color: data.color, child: data.preview),
                SizedBox(height: compact ? 20 : 28),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: compact ? 23 : 25,
                    fontWeight: FontWeight.w800,
                    height: 1.32,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  final Color color;
  final Widget child;

  const _PhoneFrame({
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 258,
      height: 308,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _HomePreview extends StatelessWidget {
  const _HomePreview();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PreviewHeader(title: '오늘의 계산'),
        SizedBox(height: 12),
        _PreviewMenuTile(
          icon: Icons.compare_arrows_rounded,
          color: AppColors.primary,
          title: '전세 vs 월세 비교',
          caption: '월 비용 차이',
          value: '24만원',
        ),
        SizedBox(height: 8),
        _PreviewMenuTile(
          icon: Icons.view_column_rounded,
          color: Color(0xFF2563EB),
          title: '복수 시나리오 비교',
          caption: '금리 A/B/C',
          value: '3개',
        ),
        SizedBox(height: 8),
        _PreviewMenuTile(
          icon: Icons.health_and_safety_outlined,
          color: Color(0xFFDC2626),
          title: '전세사기 위험도',
          caption: '체크리스트',
          value: '주의',
        ),
        Spacer(),
        _MiniTabBar(),
      ],
    );
  }
}

class _ScenarioPreview extends StatelessWidget {
  const _ScenarioPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PreviewHeader(title: '복수 시나리오'),
        const SizedBox(height: 14),
        const _ScenarioBar(label: 'A', value: '4.0%', width: 0.72),
        const SizedBox(height: 10),
        const _ScenarioBar(label: 'B', value: '4.8%', width: 0.86),
        const SizedBox(height: 10),
        const _ScenarioBar(label: 'C', value: '5.5%', width: 0.98),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('월 부담 최저', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Text(
                'A안 1,066,667원',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContractSafetyPreview extends StatelessWidget {
  const _ContractSafetyPreview();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PreviewHeader(title: '계약 안전 점검'),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricBox(
                label: '갱신 상한',
                value: '5%',
                color: Color(0xFFEA580C),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _MetricBox(
                label: '위험도',
                value: '주의',
                color: Color(0xFFDC2626),
              ),
            ),
          ],
        ),
        SizedBox(height: 14),
        _CheckRow(text: '등기부등본 재확인'),
        SizedBox(height: 8),
        _CheckRow(text: '선순위채권 말소 특약'),
        SizedBox(height: 8),
        _CheckRow(text: '보증보험 가입 가능 여부'),
        Spacer(),
        _RiskScoreBar(),
      ],
    );
  }
}

class _FinanceTaxPreview extends StatelessWidget {
  const _FinanceTaxPreview();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PreviewHeader(title: '금융 · 세금'),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricBox(
                label: 'DSR',
                value: '38.4%',
                color: Color(0xFF0F766E),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _MetricBox(
                label: 'DTI',
                value: '27.1%',
                color: Color(0xFF0F766E),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        _AmountRow(label: '월세 세액공제', value: '750,000원'),
        _AmountRow(label: '중개보수 상한', value: '1,200,000원'),
        _AmountRow(label: '예상 취득세', value: '4,800,000원'),
      ],
    );
  }
}

class _ResultPreview extends StatelessWidget {
  const _ResultPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PreviewHeader(title: '계산 결과'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('반전세 계산 결과', style: AppTextStyles.caption),
              const SizedBox(height: 6),
              Text(
                '월세 18만원 높음',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(
                child: _ActionChip(icon: Icons.share_outlined, text: '공유')),
            SizedBox(width: 8),
            Expanded(
                child: _ActionChip(icon: Icons.bookmark_border, text: '저장')),
          ],
        ),
        const SizedBox(height: 8),
        const _ActionChip(
          icon: Icons.picture_as_pdf_outlined,
          text: 'PDF 내보내기',
        ),
      ],
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  final String title;

  const _PreviewHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.heading3),
      ],
    );
  }
}

class _PreviewMenuTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String caption;
  final String value;

  const _PreviewMenuTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.caption,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(caption, style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTabBar extends StatelessWidget {
  const _MiniTabBar();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _TabIcon(icon: Icons.home_rounded, active: true),
        _TabIcon(icon: Icons.history_rounded),
        _TabIcon(icon: Icons.settings_rounded),
      ],
    );
  }
}

class _TabIcon extends StatelessWidget {
  final IconData icon;
  final bool active;

  const _TabIcon({
    required this.icon,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: 20,
      color: active ? AppColors.primary : AppColors.textSecondary,
    );
  }
}

class _ScenarioBar extends StatelessWidget {
  final String label;
  final String value;
  final double width;

  const _ScenarioBar({
    required this.label,
    required this.value,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 22,
          child: Text(label, style: AppTextStyles.caption),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: width,
              backgroundColor: AppColors.divider,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String text;

  const _CheckRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle, size: 17, color: AppColors.positive),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _RiskScoreBar extends StatelessWidget {
  const _RiskScoreBar();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('위험 점수 62점', style: AppTextStyles.caption),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: const LinearProgressIndicator(
            minHeight: 10,
            value: 0.62,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
          ),
        ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;

  const _AmountRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ActionChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 17, color: const Color(0xFF7C3AED)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int current;
  final Color color;

  const _Dots({
    required this.count,
    required this.current,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? color : AppColors.divider,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
