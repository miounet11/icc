#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/stage-website-release-assets.sh \
  --tag <tag> \
  --version <version> \
  --dmg <path> \
  --appcast <path> \
  --output-dir <dir> \
  [--base-url <url>] \
  [--notes-url <url>] \
  [--remote-assets-dir <dir>]

Stages the latest website-hosted release assets:
  downloads/icc-macos.dmg
  downloads/appcast.xml
  downloads/latest.json
  downloads/archive/<tag>/...
  downloads/remote/...
EOF
}

TAG=""
VERSION=""
DMG_PATH=""
APPCAST_PATH=""
OUTPUT_DIR=""
BASE_URL="https://www.iccjk.com/downloads"
NOTES_URL="https://www.iccjk.com/changelog"
REMOTE_ASSETS_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag)
      TAG="${2:-}"
      shift 2
      ;;
    --version)
      VERSION="${2:-}"
      shift 2
      ;;
    --dmg)
      DMG_PATH="${2:-}"
      shift 2
      ;;
    --appcast)
      APPCAST_PATH="${2:-}"
      shift 2
      ;;
    --output-dir)
      OUTPUT_DIR="${2:-}"
      shift 2
      ;;
    --base-url)
      BASE_URL="${2:-}"
      shift 2
      ;;
    --notes-url)
      NOTES_URL="${2:-}"
      shift 2
      ;;
    --remote-assets-dir)
      REMOTE_ASSETS_DIR="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown option $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$TAG" || -z "$VERSION" || -z "$DMG_PATH" || -z "$APPCAST_PATH" || -z "$OUTPUT_DIR" ]]; then
  echo "error: --tag, --version, --dmg, --appcast, and --output-dir are required" >&2
  usage
  exit 1
fi

if [[ ! -f "$DMG_PATH" || ! -f "$APPCAST_PATH" ]]; then
  echo "error: dmg or appcast path does not exist" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"
LATEST_DMG_PATH="${OUTPUT_DIR}/icc-macos.dmg"
LATEST_APPCAST_PATH="${OUTPUT_DIR}/appcast.xml"
LATEST_MANIFEST_PATH="${OUTPUT_DIR}/latest.json"
ARCHIVE_DIR="${OUTPUT_DIR}/archive/${TAG}"
REMOTE_LATEST_DIR="${OUTPUT_DIR}/remote"
REMOTE_VERSION_DIR="${REMOTE_LATEST_DIR}/${TAG}"
REMOTE_MANIFEST_PATH="${REMOTE_LATEST_DIR}/cmuxd-remote-manifest.json"

mkdir -p "$ARCHIVE_DIR" "$REMOTE_LATEST_DIR"
cp "$DMG_PATH" "$LATEST_DMG_PATH"
cp "$APPCAST_PATH" "$LATEST_APPCAST_PATH"
cp "$DMG_PATH" "${ARCHIVE_DIR}/icc-macos.dmg"
cp "$APPCAST_PATH" "${ARCHIVE_DIR}/appcast.xml"

if [[ -n "$REMOTE_ASSETS_DIR" ]]; then
  if [[ ! -d "$REMOTE_ASSETS_DIR" ]]; then
    echo "error: remote assets dir does not exist" >&2
    exit 1
  fi
  rm -rf "$REMOTE_VERSION_DIR"
  mkdir -p "$REMOTE_VERSION_DIR"
  cp -R "${REMOTE_ASSETS_DIR}/." "$REMOTE_VERSION_DIR/"
  if [[ -f "${REMOTE_ASSETS_DIR}/cmuxd-remote-manifest.json" ]]; then
    cp "${REMOTE_ASSETS_DIR}/cmuxd-remote-manifest.json" "$REMOTE_MANIFEST_PATH"
  fi
fi

DMG_SHA256="$(shasum -a 256 "$DMG_PATH" | awk '{print $1}')"
DMG_SIZE="$(stat -f%z "$DMG_PATH")"
PUBLISHED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
BASE_URL="${BASE_URL%/}"
if [[ ! -f "$REMOTE_MANIFEST_PATH" ]]; then
  python3 - <<'PY' "$REMOTE_MANIFEST_PATH" "$TAG" "$VERSION" "$PUBLISHED_AT" "$BASE_URL"
import json
import sys
from pathlib import Path

manifest_path, tag, version, published_at, base_url = sys.argv[1:]
manifest = {
    "schemaVersion": 1,
    "product": "icc",
    "channel": "stable",
    "tag": tag,
    "version": version,
    "publishedAt": published_at,
    "available": False,
    "reason": "Remote helper assets were not staged for this release from this build host.",
    "manifestUrl": f"{base_url}/remote/cmuxd-remote-manifest.json",
}
Path(manifest_path).write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
fi

python3 - <<'PY' "$LATEST_MANIFEST_PATH" "$TAG" "$VERSION" "$PUBLISHED_AT" "$BASE_URL" "$NOTES_URL" "$DMG_SHA256" "$DMG_SIZE" "$REMOTE_ASSETS_DIR"
import json
import sys
from pathlib import Path

manifest_path, tag, version, published_at, base_url, notes_url, dmg_sha256, dmg_size, remote_assets_dir = sys.argv[1:]
manifest = {
    "schemaVersion": 1,
    "product": "icc",
    "channel": "stable",
    "tag": tag,
    "version": version,
    "publishedAt": published_at,
    "notesUrl": notes_url,
    "downloads": {
        "macos": {
            "bundleId": "com.icc.app",
            "artifactType": "dmg",
            "url": f"{base_url}/icc-macos.dmg",
            "archiveUrl": f"{base_url}/archive/{tag}/icc-macos.dmg",
            "appcastUrl": f"{base_url}/appcast.xml",
            "sha256": dmg_sha256,
            "size": int(dmg_size),
        },
        "windows": {
            "available": False,
            "reason": "icc currently ships as a native macOS AppKit application and does not have a real Windows desktop build target yet."
        },
    },
    "update": {
        "feedUrl": f"{base_url}/appcast.xml",
        "manifestUrl": f"{base_url}/latest.json",
    },
}
manifest["remoteDaemon"] = {
    "manifestUrl": f"{base_url}/remote/cmuxd-remote-manifest.json",
    "archiveBaseUrl": f"{base_url}/remote/{tag}",
    "available": bool(remote_assets_dir),
}
Path(manifest_path).write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY

echo "Staged website release assets in ${OUTPUT_DIR}"
