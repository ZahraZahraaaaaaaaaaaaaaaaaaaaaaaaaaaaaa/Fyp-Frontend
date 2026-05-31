#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${API_BASE_URL:-}" ]]; then
  echo "Missing API_BASE_URL. Set it in Vercel Project Settings → Environment Variables (Production & Preview)." >&2
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLUTTER_DIR="${ROOT}/.flutter-sdk"
export CI=true
export PUB_CACHE="${ROOT}/.pub-cache"

# Vercel often runs as root; re-run this script as an unprivileged user for Flutter.
if [[ "$(id -u)" == "0" && -z "${FLUTTER_VERCEL_AS_BUILDER:-}" ]]; then
  if ! id -u builder >/dev/null 2>&1; then
    useradd -m -u 1001 builder
  fi
  chown -R builder:builder "${ROOT}" "${FLUTTER_DIR}" "${PUB_CACHE}" 2>/dev/null || true
  exec su builder -c "cd \"${ROOT}\" && FLUTTER_VERCEL_AS_BUILDER=1 API_BASE_URL=\"${API_BASE_URL}\" bash scripts/vercel-flutter-build.sh"
fi

if [[ ! -x "${FLUTTER_DIR}/bin/flutter" ]]; then
  rm -rf "${FLUTTER_DIR}"
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "${FLUTTER_DIR}"
fi

git config --global --add safe.directory "${FLUTTER_DIR}" 2>/dev/null || true

export PATH="${FLUTTER_DIR}/bin:${PATH}"
cd "${ROOT}"
flutter config --no-analytics >/dev/null 2>&1 || true
flutter precache --web
flutter pub get
flutter build web --release --dart-define=API_BASE="${API_BASE_URL}"
