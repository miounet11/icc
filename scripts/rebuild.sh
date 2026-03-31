#!/bin/bash
# Rebuild and restart icc app

set -e

cd "$(dirname "$0")/.."

# Kill existing app if running
pkill -9 -f "icc" 2>/dev/null || true

# Build
swift build

# Copy to app bundle
cp .build/debug/icc .build/debug/icc.app/Contents/MacOS/

# Open the app
open .build/debug/icc.app
