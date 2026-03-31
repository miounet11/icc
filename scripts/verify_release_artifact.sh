#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/verify_release_artifact.sh --dmg <path> [--expected-app <name>] [--expected-applications-link <target>]
EOF
}

DMG_PATH=""
EXPECTED_APP="icc.app"
EXPECTED_APPLICATIONS_LINK="/Applications"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dmg)
      DMG_PATH="${2:-}"
      shift 2
      ;;
    --expected-app)
      EXPECTED_APP="${2:-}"
      shift 2
      ;;
    --expected-applications-link)
      EXPECTED_APPLICATIONS_LINK="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$DMG_PATH" ]]; then
  usage >&2
  exit 1
fi

if [[ ! -f "$DMG_PATH" ]]; then
  echo "DMG not found: $DMG_PATH" >&2
  exit 1
fi

if ! command -v hdiutil >/dev/null 2>&1; then
  echo "hdiutil is required" >&2
  exit 1
fi

attach_plist="$(mktemp)"
mount_point=""

cleanup() {
  if [[ -n "$mount_point" ]]; then
    hdiutil detach "$mount_point" -quiet >/dev/null 2>&1 || true
  fi
  rm -f "$attach_plist"
}
trap cleanup EXIT

hdiutil attach "$DMG_PATH" -nobrowse -readonly -plist > "$attach_plist"
mount_point="$(python3 - <<'PY' "$attach_plist"
import plistlib
import sys

with open(sys.argv[1], "rb") as handle:
    payload = plistlib.load(handle)

for entity in payload.get("system-entities", []):
    mount_point = entity.get("mount-point")
    if mount_point:
        print(mount_point)
        break
PY
)"

if [[ -z "$mount_point" ]]; then
  echo "Unable to determine DMG mount point" >&2
  exit 1
fi

app_path="${mount_point}/${EXPECTED_APP}"
applications_link="${mount_point}/Applications"

[[ -d "$app_path" ]] || { echo "Expected app bundle missing in DMG: $app_path" >&2; exit 1; }
[[ -L "$applications_link" ]] || { echo "DMG is missing /Applications drag target link" >&2; exit 1; }

link_target="$(readlink "$applications_link")"
if [[ "$link_target" != "$EXPECTED_APPLICATIONS_LINK" ]]; then
  echo "Unexpected Applications symlink target: $link_target" >&2
  exit 1
fi

app_plist="${app_path}/Contents/Info.plist"
[[ -f "$app_plist" ]] || { echo "App bundle is missing Info.plist" >&2; exit 1; }

package_type="$(/usr/libexec/PlistBuddy -c 'Print :CFBundlePackageType' "$app_plist" 2>/dev/null || true)"
if [[ "$package_type" != "APPL" ]]; then
  echo "Unexpected CFBundlePackageType: ${package_type:-<missing>}" >&2
  exit 1
fi

if command -v codesign >/dev/null 2>&1; then
  /usr/bin/codesign --verify --deep --strict --verbose=2 "$app_path"
fi

echo "Verified DMG install surface:"
echo "  mount point: $mount_point"
echo "  app bundle: $app_path"
echo "  Applications link: $link_target"
