#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/release-config.sh"

# Build, sign, notarize, create DMG, generate appcast, and upload to GitHub release.
# Usage: ./scripts/build-sign-upload.sh <tag> [--allow-overwrite]
# Requires: source ~/.secrets/cmuxterm.env && export SPARKLE_PRIVATE_KEY

usage() {
  cat <<'EOF'
Usage: ./scripts/build-sign-upload.sh <tag> [--allow-overwrite]

Options:
  --allow-overwrite   Permit replacing existing release assets for the same tag.
                      Use only for emergency rerolls.
EOF
}

ALLOW_OVERWRITE="false"
POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --allow-overwrite)
      ALLOW_OVERWRITE="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done
set -- "${POSITIONAL[@]}"

if [[ $# -ne 1 ]]; then
  usage >&2
  exit 1
fi

TAG="$1"
VERSION="$(icc_release_version "$TAG")"
ICC_RELEASE_DMG_NAME="$(icc_release_dmg_name "$VERSION")"
SIGN_HASH="A050CC7E193C8221BDBA204E731B046CDCCC1B30"
ENTITLEMENTS="cmux.entitlements"
APP_PATH="build/Build/Products/Release/${ICC_APP_BUNDLE_NAME}"

# --- Pre-flight ---
source ~/.secrets/cmuxterm.env
export SPARKLE_PRIVATE_KEY
for tool in zig xcodebuild create-dmg xcrun codesign ditto gh; do
  command -v "$tool" >/dev/null || { echo "MISSING: $tool" >&2; exit 1; }
done
echo "Pre-flight checks passed"

# --- Build GhosttyKit (if needed) ---
if [ ! -d "GhosttyKit.xcframework" ]; then
  echo "Building GhosttyKit..."
  cd ghostty && zig build -Demit-xcframework=true -Demit-macos-app=false -Dxcframework-target=universal -Doptimize=ReleaseFast && cd ..
  rm -rf GhosttyKit.xcframework
  cp -R ghostty/macos/GhosttyKit.xcframework GhosttyKit.xcframework
else
  echo "GhosttyKit.xcframework exists, skipping build"
fi

# --- Build app (Release, unsigned) ---
echo "Building app..."
rm -rf build/
xcodebuild -scheme cmux -configuration Release -derivedDataPath build CODE_SIGNING_ALLOWED=NO build 2>&1 | tail -5
echo "Build succeeded"

HELPER_PATH="$APP_PATH/Contents/Resources/bin/ghostty"
if [ ! -x "$HELPER_PATH" ]; then
  echo "Ghostty theme picker helper not found at $HELPER_PATH" >&2
  exit 1
fi

# --- Inject Sparkle keys ---
echo "Injecting Sparkle keys..."
SPARKLE_PUBLIC_KEY_DERIVED=$(swift scripts/derive_sparkle_public_key.swift "$SPARKLE_PRIVATE_KEY")
APP_PLIST="$APP_PATH/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Delete :SUPublicEDKey" "$APP_PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Delete :SUFeedURL" "$APP_PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :SUPublicEDKey string $SPARKLE_PUBLIC_KEY_DERIVED" "$APP_PLIST"
/usr/libexec/PlistBuddy -c "Add :SUFeedURL string $ICC_STABLE_FEED_URL" "$APP_PLIST"
echo "Sparkle keys injected"

# --- Codesign ---
echo "Codesigning..."
CLI_PATH="$APP_PATH/Contents/Resources/bin/$ICC_CLI_NAME"
if [ -f "$CLI_PATH" ]; then
  /usr/bin/codesign --force --options runtime --timestamp --sign "$SIGN_HASH" --entitlements "$ENTITLEMENTS" "$CLI_PATH"
fi
if [ -f "$HELPER_PATH" ]; then
  /usr/bin/codesign --force --options runtime --timestamp --sign "$SIGN_HASH" --entitlements "$ENTITLEMENTS" "$HELPER_PATH"
fi
/usr/bin/codesign --force --options runtime --timestamp --sign "$SIGN_HASH" --entitlements "$ENTITLEMENTS" --deep "$APP_PATH"
/usr/bin/codesign --verify --deep --strict --verbose=2 "$APP_PATH"
echo "Codesign verified"

# --- Notarize app ---
echo "Notarizing app..."
ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "${ICC_APP_NAME}-notary.zip"
xcrun notarytool submit "${ICC_APP_NAME}-notary.zip" \
  --apple-id "$APPLE_ID" --team-id "$APPLE_TEAM_ID" --password "$APPLE_APP_SPECIFIC_PASSWORD" --wait
xcrun stapler staple "$APP_PATH"
xcrun stapler validate "$APP_PATH"
rm -f "${ICC_APP_NAME}-notary.zip"
echo "App notarized"

# --- Create and notarize DMG ---
echo "Creating DMG..."
rm -f "$ICC_RELEASE_DMG_NAME"
create-dmg --codesign "$SIGN_HASH" "$ICC_RELEASE_DMG_NAME" "$APP_PATH"
echo "Notarizing DMG..."
xcrun notarytool submit "$ICC_RELEASE_DMG_NAME" \
  --apple-id "$APPLE_ID" --team-id "$APPLE_TEAM_ID" --password "$APPLE_APP_SPECIFIC_PASSWORD" --wait
xcrun stapler staple "$ICC_RELEASE_DMG_NAME"
xcrun stapler validate "$ICC_RELEASE_DMG_NAME"
echo "DMG notarized"

# --- Generate Sparkle appcast ---
echo "Generating appcast..."
./scripts/sparkle_generate_appcast.sh "$ICC_RELEASE_DMG_NAME" "$TAG" "$ICC_STABLE_APPCAST_NAME"

# --- Create GitHub release (if needed) and upload ---
if gh release view "$TAG" >/dev/null 2>&1; then
  echo "Release $TAG already exists"
  EXISTING_ASSETS="$(gh release view "$TAG" --json assets --jq '.assets[].name' || true)"
  HAS_CONFLICTING_ASSET="false"
  for asset in "$ICC_RELEASE_DMG_NAME" "$ICC_STABLE_APPCAST_NAME"; do
    if printf '%s\n' "$EXISTING_ASSETS" | grep -Fxq "$asset"; then
      HAS_CONFLICTING_ASSET="true"
      break
    fi
  done

  if [[ "$HAS_CONFLICTING_ASSET" == "true" && "$ALLOW_OVERWRITE" != "true" ]]; then
    echo "ERROR: Refusing to overwrite signed release assets for existing tag $TAG." >&2
    echo "Use a new tag, or rerun with --allow-overwrite for an emergency reroll." >&2
    exit 1
  fi

  if [[ "$ALLOW_OVERWRITE" == "true" ]]; then
    echo "Uploading with overwrite enabled for existing release $TAG..."
    gh release upload "$TAG" "$ICC_RELEASE_DMG_NAME" "$ICC_STABLE_APPCAST_NAME" --clobber
  else
    echo "Uploading to existing release $TAG..."
    gh release upload "$TAG" "$ICC_RELEASE_DMG_NAME" "$ICC_STABLE_APPCAST_NAME"
  fi
else
  echo "Creating release $TAG and uploading..."
  gh release create "$TAG" "$ICC_RELEASE_DMG_NAME" "$ICC_STABLE_APPCAST_NAME" --title "$TAG" --notes "See CHANGELOG.md for details"
fi

# --- Verify ---
gh release view "$TAG"

# --- Update Homebrew cask (skip for nightlies) ---
if [[ "$TAG" != *"-nightly"* ]]; then
  VERSION="${TAG#v}"
  DMG_SHA256=$(shasum -a 256 "$ICC_RELEASE_DMG_NAME" | cut -d' ' -f1)
  echo "Updating homebrew cask to $VERSION (SHA: $DMG_SHA256)..."
  CASK_FILE="homebrew-cmux/Casks/cmux.rb"
  if [ -n "$ICC_HOMEBREW_TAP_REPOSITORY" ] && [ -f "$CASK_FILE" ]; then
    cat > "$CASK_FILE" << CASKEOF
cask "icc" do
  version "${VERSION}"
  sha256 "${DMG_SHA256}"

  url "https://github.com/miounet11/icc/releases/download/v#{version}/icc-v#{version}-macos.dmg"
  name "icc"
  desc "Native macOS terminal workspace app for AI execution"
  homepage "https://github.com/miounet11/icc"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :ventura"

  app "icc.app"
  binary "#{appdir}/icc.app/Contents/Resources/bin/icc"

  zap trash: [
    "~/Library/Application Support/icc",
    "~/Library/Caches/icc",
    "~/Library/Preferences/com.icc.app.plist",
  ]
end
CASKEOF
    cd homebrew-cmux
    git add Casks/cmux.rb
    if git diff --staged --quiet; then
      echo "Homebrew cask already up to date"
    else
      git commit -m "Update icc to ${VERSION}"
      git push
      echo "Homebrew cask updated"
    fi
    cd ..
  else
    echo "WARNING: Homebrew tap automation is not configured, skipping cask update"
  fi
fi

# --- Cleanup ---
rm -rf build/ "$ICC_RELEASE_DMG_NAME" "$ICC_STABLE_APPCAST_NAME"
echo ""
echo "=== Release $TAG complete ==="
say "icc release complete"
