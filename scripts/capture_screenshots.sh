#!/bin/bash
set -e

SIMULATOR_ID="1FC14AAC-3ED2-4F06-8750-145D65432B31"
OUTPUT_DIR="store_assets/screenshots"
mkdir -p "$OUTPUT_DIR"

echo "▶ Flutter integration test 시작 (iPhone 15 Pro Max)"

flutter test integration_test/screenshot_test.dart \
  -d "$SIMULATOR_ID" \
  --reporter=compact 2>&1 | while IFS= read -r line; do
    echo "$line"
    if [[ "$line" == *"SNAP:"* ]]; then
      NAME=$(echo "$line" | grep -o 'SNAP:[^ ]*' | cut -d: -f2)
      OUT="$OUTPUT_DIR/${NAME}.png"
      xcrun simctl io "$SIMULATOR_ID" screenshot "$OUT"
      echo "  📸 캡처: $OUT"
    fi
done

echo ""
echo "✅ 완료! 저장 위치: $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR"
