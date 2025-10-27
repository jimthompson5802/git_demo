#!/usr/bin/env bash
# Run all python modules in the project's src/ directory.
# Usage:
#   PYTHON=python3 ./scripts/run_all_src.sh

set -uo pipefail

PYTHON="${PYTHON:-python3}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR/.."
SRC_DIR="$REPO_ROOT/src"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "src directory not found at: $SRC_DIR" >&2
  exit 2
fi

echo "Using Python: $PYTHON"
echo "Running Python files under: $SRC_DIR"
"$PYTHON" --version

mapfile -d '' files < <(find "$SRC_DIR" -maxdepth 1 -type f -name '*.py' -print0 | sort -z)

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No Python files found in $SRC_DIR"
  exit 0
fi

failed=0

for f in "${files[@]}"; do
  # strip trailing NUL if any (mapfile with -d '') may include it
  f="${f%$'\0'}"
  base="$(basename "$f")"
  # skip __init__.py (not typically runnable)
  if [[ "$base" == "__init__.py" ]]; then
    continue
  fi

  echo
  echo "===== Running: $base ====="
  if "$PYTHON" "$f"; then
    echo "--- OK: $base"
  else
    rc=$?
    echo "--- FAILED ($rc): $base" >&2
    failed=1
  fi
done

if [[ $failed -ne 0 ]]; then
  echo
  echo "One or more scripts failed." >&2
  exit 1
fi

echo
echo "All scripts ran (some may have produced their own output)."
exit 0
