#!/bin/bash
set -e

CREDENTIALS_FILE="$(dirname "$0")/../.appstore_credentials"
if [ ! -f "$CREDENTIALS_FILE" ]; then
  echo "❌ .appstore_credentials 파일이 없습니다."
  exit 1
fi
source "$CREDENTIALS_FILE"

# 빌드 번호 자동 증가
PUBSPEC="$(dirname "$0")/../pubspec.yaml"
CURRENT=$(grep '^version:' "$PUBSPEC" | sed 's/version: //')
VERSION=$(echo "$CURRENT" | cut -d+ -f1)
BUILD=$(echo "$CURRENT" | cut -d+ -f2)
NEW_BUILD=$((BUILD + 1))
sed -i '' "s/^version: .*/version: ${VERSION}+${NEW_BUILD}/" "$PUBSPEC"
echo "▶ 버전: ${VERSION}+${NEW_BUILD}"

echo "▶ [1/3] Flutter IPA 빌드 중..."
flutter build ipa --release --build-number="$NEW_BUILD" 2>&1 | grep -E "archive done|Built|error:|✓" || true

xcodebuild -exportArchive \
  -archivePath build/ios/archive/Runner.xcarchive \
  -exportPath build/ios/ipa \
  -exportOptionsPlist ios/ExportOptions.plist \
  -allowProvisioningUpdates \
  2>&1 | grep -E "EXPORT|error:" || true

IPA_PATH="build/ios/ipa/어떤비용.ipa"
if [ ! -f "$IPA_PATH" ]; then
  echo "❌ IPA 파일을 찾을 수 없습니다: $IPA_PATH"
  exit 1
fi

echo ""
echo "▶ [2/3] App Store Connect 업로드 중..."
xcrun altool --upload-app \
  -f "$IPA_PATH" \
  -t ios \
  --apiKey "$ASC_KEY_ID" \
  --apiIssuer "$ASC_ISSUER_ID" \
  --show-progress \
  2>&1

echo ""
echo "▶ [3/3] 완료!"
echo "  ✅ App Store Connect → TestFlight 탭에서 빌드를 확인하세요. (15~30분 소요)"
