#!/usr/bin/env bash
# Reads .env at the repo root and invokes flutter with one --dart-define
# per KEY=VALUE pair. Usage:
#   ./scripts/with-env.sh run
#   ./scripts/with-env.sh run -d emulator-5554
#   ./scripts/with-env.sh build apk --release
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE:-$ROOT/.env}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "with-env.sh: $ENV_FILE not found" >&2
  exit 1
fi

defines=()
while IFS= read -r line || [[ -n "$line" ]]; do
  # Strip CR (in case the file was edited on Windows), skip blanks and comments.
  line="${line%$'\r'}"
  [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
  # Require KEY=VALUE; allow surrounding whitespace.
  if [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)[[:space:]]*=[[:space:]]*(.*)$ ]]; then
    key="${BASH_REMATCH[1]}"
    val="${BASH_REMATCH[2]}"
    # Strip optional surrounding single or double quotes.
    if [[ "$val" =~ ^\"(.*)\"$ ]] || [[ "$val" =~ ^\'(.*)\'$ ]]; then
      val="${BASH_REMATCH[1]}"
    fi
    defines+=("--dart-define=${key}=${val}")
  else
    echo "with-env.sh: skipping malformed line: $line" >&2
  fi
done < "$ENV_FILE"

exec flutter "$@" "${defines[@]}"
