#!/bin/zsh
set -euo pipefail

cd "${0:A:h:h}"
swift build -c release --scratch-path .build

swift scripts/generate-icon.swift
for size in 16 32 128 256 512; do
  sips -z "$size" "$size" Resources/Brighter.iconset/icon_512x512@2x.png \
    --out "Resources/Brighter.iconset/icon_${size}x${size}.png" >/dev/null
  double=$((size * 2))
  if (( double != 1024 )); then
    sips -z "$double" "$double" Resources/Brighter.iconset/icon_512x512@2x.png \
      --out "Resources/Brighter.iconset/icon_${size}x${size}@2x.png" >/dev/null
  fi
done
iconutil -c icns Resources/Brighter.iconset -o Resources/Brighter.icns

app="dist/Brighter.app"
rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp .build/release/Brighter "$app/Contents/MacOS/Brighter"
cp Resources/Info.plist "$app/Contents/Info.plist"
cp Resources/Brighter.icns "$app/Contents/Resources/Brighter.icns"
cp Resources/PrivacyInfo.xcprivacy "$app/Contents/Resources/PrivacyInfo.xcprivacy"
cp -R Resources/en.lproj Resources/tr.lproj "$app/Contents/Resources/"

identity="${SIGN_IDENTITY:--}"
if [[ "$identity" == "-" ]]; then
  codesign --force --sign - "$app"
else
  codesign --force --options runtime --timestamp --sign "$identity" "$app"
fi
codesign --verify --deep --strict --verbose=2 "$app"
ditto -c -k --sequesterRsrc --keepParent "$app" dist/Brighter.zip
print "Built $app and dist/Brighter.zip"
