#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"
mkdir -p dist/app-store
xcodebuild -project Brighter.xcodeproj -scheme Brighter -configuration Release \
  -destination 'generic/platform=macOS' \
  -archivePath "$PWD/dist/app-store/Brighter.xcarchive" \
  -derivedDataPath "$PWD/.build/xcode-app-store" \
  -allowProvisioningUpdates archive
xcodebuild -exportArchive \
  -archivePath "$PWD/dist/app-store/Brighter.xcarchive" \
  -exportPath "$PWD/dist/app-store/export" \
  -exportOptionsPlist Resources/ExportOptions-AppStore.plist \
  -allowProvisioningUpdates
