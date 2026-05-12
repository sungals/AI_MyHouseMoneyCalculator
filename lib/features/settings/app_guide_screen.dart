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
        children: const [
          _GuideSection(
            title: '앱 소개',
            body:
                '어떤비용은 주거 비용과 생활 금융 계산을 한 곳에서 관리하는 계산 앱입니다. 전세와 월세 비교, 반전세 전환, 대출이자, 월 고정비, 연말정산 공제, DSR/DTI, 중개보수, 취득세를 계산하고 결과를 저장할 수 있습니다.',
          ),
          _GuideSection(
            title: '기본 사용 흐름',
            body:
                '홈 화면에서 필요한 계산기를 선택하고 금액과 조건을 입력한 뒤 계산하기를 누릅니다. 계산 결과가 나오면 저장 버튼으로 기록에 남길 수 있고, 저장한 계산은 홈의 최근 기록 또는 저장한 계산 보기에서 다시 확인할 수 있습니다.',
          ),
          _GuideSection(
            title: '저장 기록 관리',
            body:
                '저장한 계산 화면에서는 제목, 요약, 메모로 검색할 수 있습니다. 계산 유형별 필터와 즐겨찾기 필터를 사용할 수 있고, 상세 화면에서 메모를 추가하거나 CSV/PDF로 내보낼 수 있습니다.',
          ),
          _GuideSection(
            title: '로그인과 동기화',
            body:
                '이메일로 로그인하면 저장 기록이 Supabase 계정 기준으로 동기화됩니다. 오프라인 상태에서 저장하거나 삭제한 기록도 로컬에 먼저 반영되고, 네트워크가 가능한 시점에 서버와 동기화됩니다.\n\n로그아웃은 설정 화면 최하단의 로그아웃 버튼으로 진행할 수 있습니다.',
          ),
          _GuideSection(
            title: '간편로그인',
            body:
                '설정에서 PIN을 등록하면 앱 재진입 시 PIN 또는 생체인증으로 보호할 수 있습니다. PIN 변경과 생체인증 재설정도 설정에서 진행할 수 있습니다.\n\n계정 관리(이메일 확인, 회원탈퇴)는 설정 > 계정 관리 화면에서 진행합니다. 회원탈퇴 시 계정과 저장된 모든 기록이 즉시 삭제되며 되돌릴 수 없습니다.',
          ),
          _GuideSection(
            title: '공지와 푸시 알림',
            body:
                '로그인 상태에서 공지 푸시 알림을 켜두면 새 공지가 등록될 때 알림을 받을 수 있습니다. 알림을 누르면 공지 상세 화면으로 이동하며, 상단 뒤로가기 버튼으로 홈으로 돌아올 수 있습니다. 읽은 공지는 읽음 상태로 표시됩니다.',
          ),
          _GuideSection(
            title: '계산 결과 안내',
            body:
                '앱의 계산 결과는 입력값을 기준으로 한 참고용 간이 계산입니다. 실제 대출, 세금, 중개보수, 계약 조건은 지역, 시점, 개인 상황, 관련 법령에 따라 달라질 수 있으므로 최종 결정 전 전문가 또는 공식 기관을 통해 확인해야 합니다.',
          ),
        ],
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  final String title;
  final String body;

  const _GuideSection({
    required this.title,
    required this.body,
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
          Text(title, style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(body, style: AppTextStyles.bodySecondary),
        ],
      ),
    );
  }
}
