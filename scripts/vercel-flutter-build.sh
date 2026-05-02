#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${API_BASE_URL:-}" ]]; then
  echo "Missing API_BASE_URL. Set it in Vercel Project Settings → Environment Variables (Production & Preview)." >&2
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLUTTER_DIR="${ROOT}/.flutter-sdk"

if [[ ! -x "${FLUTTER_DIR}/bin/flutter" ]]; then
  rm -rf "${FLUTTER_DIR}"
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"

cd "${ROOT}"
flutter precache --web
flutter pub get
flutter build web --release --dart-define=API_BASE="${API_BASE_URL}"
