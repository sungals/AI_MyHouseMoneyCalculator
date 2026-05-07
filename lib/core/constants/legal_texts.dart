class LegalDocument {
  final String title;
  final String updatedAt;
  final List<LegalSection> sections;

  const LegalDocument({
    required this.title,
    required this.updatedAt,
    required this.sections,
  });
}

class LegalSection {
  final String title;
  final List<String> paragraphs;

  const LegalSection({
    required this.title,
    required this.paragraphs,
  });
}

class LegalTexts {
  LegalTexts._();

  static const terms = LegalDocument(
    title: '이용약관',
    updatedAt: '최종 수정일: 2026년 5월 6일',
    sections: [
      LegalSection(
        title: '1. 서비스의 목적',
        paragraphs: [
          '어떤비용은 전세, 월세, 반전세, 대출이자, 고정비 등 생활금융 계산을 돕기 위한 정보성 계산 도구입니다.',
          '앱에서 제공하는 계산 결과는 참고용이며, 금융상품 계약이나 법률·세무 판단의 근거로 사용할 수 없습니다.',
        ],
      ),
      LegalSection(
        title: '2. 계정 및 데이터',
        paragraphs: [
          '사용자는 이메일 계정을 통해 계산 기록을 저장하고 기기 간 동기화할 수 있습니다.',
          '사용자는 본인의 계정 정보를 안전하게 관리해야 하며, 계정 사용으로 발생하는 결과에 대한 책임은 사용자에게 있습니다.',
        ],
      ),
      LegalSection(
        title: '3. 서비스 이용 제한',
        paragraphs: [
          '앱의 정상적인 운영을 방해하거나 타인의 권리를 침해하는 방식으로 서비스를 이용할 수 없습니다.',
          '회사는 서비스 안정성, 보안, 법령 준수를 위해 필요한 경우 일부 기능을 제한할 수 있습니다.',
        ],
      ),
      LegalSection(
        title: '4. 면책',
        paragraphs: [
          '계산 결과는 입력값과 앱의 계산 기준에 따라 산출되며 실제 금융기관, 임대차 계약, 세무 기준과 다를 수 있습니다.',
          '중요한 의사결정 전에는 반드시 전문가 또는 관련 기관에 확인하시기 바랍니다.',
        ],
      ),
      LegalSection(
        title: '5. 약관 변경',
        paragraphs: [
          '약관이 변경되는 경우 앱 또는 관련 페이지를 통해 변경 내용을 안내합니다.',
          '변경 후 서비스를 계속 이용하는 경우 변경된 약관에 동의한 것으로 봅니다.',
        ],
      ),
      LegalSection(
        title: '6. 문의',
        paragraphs: [
          '서비스 이용 관련 문의는 sungals@gmail.com 으로 연락해 주세요.',
        ],
      ),
    ],
  );

  static const privacy = LegalDocument(
    title: '개인정보 처리방침',
    updatedAt: '최종 수정일: 2026년 5월 1일',
    sections: [
      LegalSection(
        title: '1. 수집하는 개인정보',
        paragraphs: [
          '계정 정보: 회원가입 및 로그인 시 이메일 주소를 수집합니다.',
          '계산 데이터: 사용자가 입력한 금액과 계산 결과는 로그인 시 서버에 저장될 수 있습니다.',
          '앱 설정: 온보딩 완료 여부, PIN 설정 여부, 생체인증 사용 여부 등은 기기 내에 저장됩니다.',
        ],
      ),
      LegalSection(
        title: '2. 개인정보 수집 및 이용 목적',
        paragraphs: [
          '계산 결과 저장 및 기기 간 동기화 서비스를 제공합니다.',
          '서비스 운영, 보안 유지, 기능 개선 및 문의 응대에 이용합니다.',
        ],
      ),
      LegalSection(
        title: '3. 보유 및 이용 기간',
        paragraphs: [
          '개인정보는 회원 탈퇴 시 또는 수집 목적이 달성된 후 지체 없이 파기합니다.',
          '관련 법령에 따라 보존이 필요한 경우 해당 기간 동안 보관할 수 있습니다.',
        ],
      ),
      LegalSection(
        title: '4. 제3자 제공',
        paragraphs: [
          '어떤비용은 사용자의 개인정보를 원칙적으로 외부에 제공하지 않습니다.',
          '다만 사용자가 사전에 동의한 경우 또는 법령에 따른 요청이 있는 경우는 예외로 합니다.',
        ],
      ),
      LegalSection(
        title: '5. 제3자 서비스',
        paragraphs: [
          'Supabase: 계정 인증 및 데이터 저장을 위해 사용합니다.',
        ],
      ),
      LegalSection(
        title: '6. 사용자의 권리',
        paragraphs: [
          '사용자는 개인정보 열람, 수정, 삭제, 계정 탈퇴 및 데이터 삭제를 요청할 수 있습니다.',
          '요청은 sungals@gmail.com 으로 문의해 주세요.',
        ],
      ),
    ],
  );
}
