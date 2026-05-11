import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/app_colors.dart';

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
      icon: Icons.home_work_outlined,
      color: Color(0xFF4F8EF7),
      title: '어떤비용에 오신 걸\n환영합니다!',
      body: '전세·월세·대출·생활비를 한 번에.\n복잡한 주거 비용을 쉽고 빠르게\n계산해 드립니다.',
    ),
    _PageData(
      icon: Icons.compare_arrows_rounded,
      color: Color(0xFF6C5CE7),
      title: '전세 vs 월세 비교',
      body:
          '전세대출 이자와 월세 중 어느 쪽이\n실제로 더 유리한지 비교합니다.\n기회비용(예금이율)까지 고려한\n정확한 총비용을 계산해 드립니다.',
    ),
    _PageData(
      icon: Icons.swap_horiz_rounded,
      color: Color(0xFF00B894),
      title: '반전세 계산',
      body:
          '보증금 일부를 월세로 전환한\n반전세 계약이 적정한지 확인합니다.\n전월세 전환율을 기준으로\n적정 월세와의 차이를 알려줍니다.',
    ),
    _PageData(
      icon: Icons.account_balance_outlined,
      color: Color(0xFFE17055),
      title: '대출이자 계산',
      body:
          '대출금액·연이율·기간을 입력하면\n월 이자와 총 이자를 즉시 계산합니다.\n금리 변동에 따른 이자 부담을\n미리 파악해 보세요.',
    ),
    _PageData(
      icon: Icons.receipt_long_outlined,
      color: Color(0xFFFDAB1D),
      title: '월 고정비 계산',
      body:
          '주거비·관리비·통신비·보험료 등\n매달 나가는 고정 지출을 한눈에.\n연간 총 지출까지 함께 확인하고\n생활비를 계획해 보세요.',
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('건너뛰기',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14)),
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
            _Dots(count: _pages.length, current: _page),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_page].color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: isLast
                      ? _finish
                      : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                  child: Text(isLast ? '시작하기' : '다음',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PageData {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _PageData({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _PageData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 60, color: data.color),
          ),
          const SizedBox(height: 40),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.7,
              color: AppColors.textSecondary,
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
  const _Dots({required this.count, required this.current});

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
            color: active ? AppColors.primary : AppColors.divider,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
