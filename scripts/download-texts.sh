#!/usr/bin/env bash
# Download license texts from their official URLs.
#
# Reads each JSON file in data/licenses/, extracts the first available URL
# from text_urls or homepage_url, downloads the text, and saves it to
# data/licenses/texts/{key}.txt
#
# Failed downloads are logged to data/licenses/texts/_failed.log
#
# Usage:
#   bash scripts/download-texts.sh

set -euo pipefail

LICENSES_DIR="data/licenses"
TEXTS_DIR="data/licenses/texts"
FAILED_LOG="${TEXTS_DIR}/_failed.log"

mkdir -p "$TEXTS_DIR"
> "$FAILED_LOG"

TOTAL=$(ls "$LICENSES_DIR"/*.json | wc -l)
COUNT=0
SUCCESS=0
FAILED=0
SKIPPED=0

for f in "$LICENSES_DIR"/*.json; do
  key=$(jq -r '.key' "$f")
  COUNT=$((COUNT + 1))

  # Skip if already downloaded
  if [ -f "${TEXTS_DIR}/${key}.txt" ]; then
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Get first URL: prefer text_urls, fall back to homepage_url
  url=$(jq -r '(.text_urls[0] // .homepage_url) // empty' "$f" 2>/dev/null || true)

  if [ -z "$url" ] || [ "$url" = "null" ]; then
    echo "$key|NO_URL" >> "$FAILED_LOG"
    FAILED=$((FAILED + 1))
    continue
  fi

  # Download with timeout
  if curl -sL --max-time 15 -o "${TEXTS_DIR}/${key}.txt" "$url" 2>/dev/null; then
    # Check if we got actual content (not empty or tiny error page)
    SIZE=$(wc -c < "${TEXTS_DIR}/${key}.txt")
    if [ "$SIZE" -lt 50 ]; then
      rm -f "${TEXTS_DIR}/${key}.txt"
      echo "$key|TOO_SMALL|$url" >> "$FAILED_LOG"
      FAILED=$((FAILED + 1))
    else
      SUCCESS=$((SUCCESS + 1))
    fi
  else
    rm -f "${TEXTS_DIR}/${key}.txt"
    echo "$key|DOWNLOAD_FAILED|$url" >> "$FAILED_LOG"
    FAILED=$((FAILED + 1))
  fi

  # Progress every 100
  if [ $((COUNT % 100)) -eq 0 ]; then
    echo "  [$COUNT/$TOTAL] success=$SUCCESS failed=$FAILED skipped=$SKIPPED"
  fi
done

echo ""
echo "Done."
echo "  Total:   $TOTAL"
echo "  Success: $SUCCESS"
echo "  Failed:  $FAILED"
echo "  Skipped: $SKIPPED"
echo "  Failed log: $FAILED_LOG"
