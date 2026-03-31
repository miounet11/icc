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

create_dmg_help="$(create-dmg --help 2>&1 || true)"
create_dmg_args=()
stage_dir="$tmp_dir/stage"
mkdir -p "$stage_dir"
cp -R "$APP_PATH" "$stage_dir/"
ln -s /Applications "$stage_dir/Applications"

if grep -q -- '--overwrite' <<<"$create_dmg_help"; then
  create_dmg_args+=(--overwrite)
fi

if grep -q -- '--skip-jenkins' <<<"$create_dmg_help"; then
  create_dmg_args+=(--skip-jenkins)
fi

if grep -q -- '--dmg-title' <<<"$create_dmg_help"; then
  create_dmg_args+=("--dmg-title=$VOLUME_NAME")
elif grep -q -- '--volname' <<<"$create_dmg_help"; then
  create_dmg_args+=(--volname "$VOLUME_NAME")
else
  echo "Unsupported create-dmg version: missing title flag" >&2
  exit 1
fi

if [[ -n "$IDENTITY" ]]; then
  if grep -q -- '--identity' <<<"$create_dmg_help"; then
    create_dmg_args+=("--identity=$IDENTITY")
  elif grep -q -- '--codesign' <<<"$create_dmg_help"; then
    create_dmg_args+=(--codesign "$IDENTITY")
  else
    echo "Unsupported create-dmg version: missing signing flag" >&2
    exit 1
  fi
fi

create_dmg_args+=(
  "$tmp_dir/$(basename "$OUTPUT_PATH")"
  "$stage_dir"
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
