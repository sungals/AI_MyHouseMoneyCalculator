#!/usr/bin/env bash
# 다크모드/i18n 전환 잔여물 검사.
# Phase 1이 끝나면 모든 항목이 0이어야 한다.
set -uo pipefail

fail=0

report() {
  local label="$1"
  local hits="$2"
  echo "== $label =="
  if [ -n "$hits" ]; then
    echo "$hits" | head -40
    echo "위반: $(echo "$hits" | wc -l | tr -d ' ')건"
    fail=1
  else
    echo "0건"
  fi
  echo
}

report "AppColors 직접 참조 (팔레트 정의부 제외)" "$(
  grep -rn "AppColors\." lib/ --include='*.dart' \
    | grep -v "lib/core/theme/app_colors.dart" \
    | grep -v "lib/core/theme/app_palette.dart" \
    || true
)"

report "AppTextStyles 참조" "$(
  grep -rn "AppTextStyles\." lib/ --include='*.dart' || true
)"

report "한글 문자열 리터럴 (legal_texts.dart, l10n 제외)" "$(
  grep -rnoE "'[^']*[가-힣][^']*'" lib/ --include='*.dart' \
    | grep -v "lib/core/constants/legal_texts.dart" \
    | grep -v "lib/l10n/" \
    || true
)"

report "lib/domain 한글 리터럴" "$(
  grep -rnoE "'[^']*[가-힣][^']*'" lib/domain --include='*.dart' || true
)"

if [ "$fail" -eq 0 ]; then
  echo "통과: 잔여물 없음"
else
  echo "실패: 위 항목을 해소해야 한다"
fi
exit "$fail"
