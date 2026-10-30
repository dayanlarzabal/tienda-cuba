#!/usr/bin/env bash
set -euo pipefail

# Genera el APK de Tienda Cuba
# Requiere: Flutter 3.22+, Android SDK, >= 4 GB RAM libres

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT/android"

if ! command -v flutter &>/dev/null; then
  echo "Error: Flutter no está instalado."
  echo "Instálalo desde: https://docs.flutter.dev/get-started/install"
  exit 1
fi

echo "→ flutter pub get"
flutter pub get

echo "→ flutter build apk --release"
flutter build apk --release

APK="build/app/outputs/flutter-apk/app-release.apk"
if [ -f "$APK" ]; then
  mkdir -p "$ROOT/dist"
  cp "$APK" "$ROOT/dist/tienda-cuba.apk"
  echo ""
  echo "✔ APK generado:"
  ls -lh "$ROOT/dist/tienda-cuba.apk"
  echo "  Ruta: $ROOT/dist/tienda-cuba.apk"
else
  echo "✖ No se encontró el APK."
  exit 1
fi
