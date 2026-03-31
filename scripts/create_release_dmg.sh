#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/create_release_dmg.sh --app-path <path> --output <path> [--identity <signing-identity>] [--volume-name <name>]
EOF
}

APP_PATH=""
OUTPUT_PATH=""
IDENTITY=""
VOLUME_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-path)
      APP_PATH="${2:-}"
      shift 2
      ;;
    --output)
      OUTPUT_PATH="${2:-}"
      shift 2
      ;;
    --identity|--codesign-identity)
      IDENTITY="${2:-}"
      shift 2
      ;;
    --volume-name)
      VOLUME_NAME="${2:-}"
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

if [[ -z "$APP_PATH" || -z "$OUTPUT_PATH" ]]; then
  usage >&2
  exit 1
fi

if [[ ! -d "$APP_PATH" ]]; then
  echo "App bundle not found: $APP_PATH" >&2
  exit 1
fi

if ! command -v create-dmg >/dev/null 2>&1; then
  echo "create-dmg is required" >&2
  exit 1
fi

APP_PATH="$(cd "$(dirname "$APP_PATH")" && pwd)/$(basename "$APP_PATH")"
OUTPUT_PATH="$(python3 -c 'import os,sys; print(os.path.abspath(sys.argv[1]))' "$OUTPUT_PATH")"
APP_NAME="$(basename "$APP_PATH")"
OUTPUT_DIR="$(dirname "$OUTPUT_PATH")"
mkdir -p "$OUTPUT_DIR"

if [[ -z "$VOLUME_NAME" ]]; then
  VOLUME_NAME="${APP_NAME%.app}"
fi

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

create_dmg_args=(
  --overwrite
  "--dmg-title=$VOLUME_NAME"
)

if [[ -n "$IDENTITY" ]]; then
  create_dmg_args+=("--identity=$IDENTITY")
fi

create_dmg_args+=(
  "$APP_PATH"
  "$tmp_dir"
)

create-dmg "${create_dmg_args[@]}"

created_dmg="$(find "$tmp_dir" -maxdepth 1 -name '*.dmg' | head -n 1)"
if [[ -z "$created_dmg" ]]; then
  echo "Failed to locate created DMG" >&2
  exit 1
fi

rm -f "$OUTPUT_PATH"
mv "$created_dmg" "$OUTPUT_PATH"
echo "Created DMG at $OUTPUT_PATH"
