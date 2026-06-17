#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SPLASH_SOURCE="$ROOT/BrandingSources/splash-source.png"
ICON_SOURCE="$ROOT/BrandingSources/icon-source.png"
ASSETS="$ROOT/Orchestrate/Assets.xcassets"

if [[ ! -f "$SPLASH_SOURCE" ]]; then
  echo "Missing $SPLASH_SOURCE"
  echo "Save the first attached image as BrandingSources/splash-source.png"
  exit 1
fi

if [[ ! -f "$ICON_SOURCE" ]]; then
  echo "Missing $ICON_SOURCE"
  echo "Save the second attached image as BrandingSources/icon-source.png"
  exit 1
fi

sips -s format png "$SPLASH_SOURCE" --out "$ASSETS/SplashBackground.imageset/splash-background.png" >/dev/null
sips -z 1024 1024 "$ICON_SOURCE" --out "$ASSETS/AppIcon.appiconset/app-icon-1024.png" >/dev/null

echo "Brand assets prepared."
