#!/bin/zsh
set -euo pipefail

cd "${0:A:h:h}"
: "${NOTARY_PROFILE:?Set NOTARY_PROFILE to an existing notarytool Keychain profile name}"

app="dist/Brighter.app"
archive="dist/Brighter.zip"
[[ -d "$app" && -f "$archive" ]] || { print -u2 "Build the app first with scripts/build-app.sh"; exit 1; }
signature=$(codesign -dv --verbose=4 "$app" 2>&1)
if [[ "$signature" != *'Authority=Developer ID Application:'* ]]; then
  print -u2 "Notarization requires a Developer ID Application signature"
  exit 1
fi
if xcrun stapler validate "$app" >/dev/null 2>&1; then
  codesign --verify --deep --strict "$app"
  spctl --assess --type execute --verbose=4 "$app"
  ditto -c -k --sequesterRsrc --keepParent "$app" "$archive"
  print "Already notarized and stapled: $app and $archive"
  exit 0
fi
archive_hash=$(shasum -a 256 "$archive" | cut -d ' ' -f 1)
app_cdhash=$(print -r -- "$signature" | sed -n 's/^CDHash=//p')
[[ -n "$app_cdhash" ]] || { print -u2 "Could not read the app's code directory hash"; exit 1; }

receipt="dist/notary-submission.json"
receipt_hash="dist/notary-submission.sha256"
result="dist/notary-result.json"
submission_id=""
if [[ -s "$receipt" && -s "$receipt_hash" && "$(< "$receipt_hash")" == "$archive_hash" ]]; then
  submission_id=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["id"])' "$receipt")
  print "Resuming notary submission $submission_id"
else
  xcrun notarytool submit "$archive" --keychain-profile "$NOTARY_PROFILE" \
    --output-format json > "$receipt.tmp"
  mv "$receipt.tmp" "$receipt"
  print -r -- "$archive_hash" > "$receipt_hash"
  submission_id=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["id"])' "$receipt")
  print "Submitted $submission_id"
fi

xcrun notarytool wait "$submission_id" --keychain-profile "$NOTARY_PROFILE" \
  --timeout "${NOTARY_TIMEOUT:-10m}" --output-format json > "$result"
notary_status=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["status"])' "$result")
if [[ "$notary_status" != "Accepted" ]]; then
  print -u2 "Notary status: $notary_status. Submission details: $result"
  exit 1
fi
current_archive_hash=$(shasum -a 256 "$archive" | cut -d ' ' -f 1)
current_app_cdhash=$(codesign -dv --verbose=4 "$app" 2>&1 | sed -n 's/^CDHash=//p')
if [[ "$archive_hash" != "$current_archive_hash" || "$app_cdhash" != "$current_app_cdhash" ]]; then
  print -u2 "The app or archive changed after submission. Rebuild and submit the current version; the old ticket cannot be stapled to it."
  exit 1
fi
xcrun stapler staple "$app"
xcrun stapler validate "$app"
ditto -c -k --sequesterRsrc --keepParent "$app" "$archive"
spctl --assess --type execute --verbose=4 "$app"
print "Notarized and stapled: $app and $archive"
