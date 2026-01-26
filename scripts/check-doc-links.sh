#!/usr/bin/env bash
set -euo pipefail

DOC_DIR="docs"

if [ ! -d "$DOC_DIR" ]; then
  echo "No docs/ directory found."
  exit 0
fi

echo "Checking markdown links under $DOC_DIR (basic sanity check)..."

FAILED=0

while IFS= read -r -d '' file; do
  while IFS= read -r line; do
    if [[ "$line" =~ \]\(([^)]+)\) ]]; then
      link="${BASH_REMATCH[1]}"
      if [[ "$link" == http* ]]; then
        continue
      fi
      if [[ "$link" == \#* ]]; then
        continue
      fi
      if [[ "$link" == mailto:* ]]; then
        continue
      fi

      target="$DOC_DIR/$link"
      if [[ "$link" == /* ]]; then
        target=".$link"
      fi

      if [[ ! -e "$target" ]]; then
        echo "Broken link in $file: $link"
        FAILED=1
      fi
    fi
  done < "$file"
done < <(find "$DOC_DIR" -type f -name "*.md" -print0)

if [ "$FAILED" -ne 0 ]; then
  echo "Docs link check failed."
  exit 1
fi

echo "Docs link check passed."
