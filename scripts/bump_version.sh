#!/usr/bin/env bash
set -euo pipefail

PUBSPEC="${PUBSPEC_PATH:-application/pubspec.yaml}"

if [ ! -f "$PUBSPEC" ]; then
  echo "ERROR: pubspec.yaml not found at $PUBSPEC" >&2
  exit 1
fi

CURRENT_LINE=$(grep '^version:' "$PUBSPEC" | head -n1)
CURRENT_VERSION=$(echo "$CURRENT_LINE" | sed 's/version: *//')

# Split "1.2.0+3" into "1.2.0" and "3"
VERSION_PART="${CURRENT_VERSION%%+*}"
if [[ "$CURRENT_VERSION" == *"+"* ]]; then
  BUILD_PART="${CURRENT_VERSION##*+}"
else
  BUILD_PART="0"
fi

# Parse major.minor.patch — but per your scheme, only minor matters
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION_PART"
MAJOR="${MAJOR:-1}"; MINOR="${MINOR:-0}"; PATCH="${PATCH:-0}"

# Custom rollover: 1.0 → 1.9 → 2.0
if [ "$MINOR" -lt 9 ]; then
  NEW_MINOR=$((MINOR + 1))
  NEW_MAJOR=$MAJOR
else
  NEW_MINOR=0
  NEW_MAJOR=$((MAJOR + 1))
fi

NEW_BUILD=$((BUILD_PART + 1))

NEW_VERSION="${NEW_MAJOR}.${NEW_MINOR}.0+${NEW_BUILD}"

sed -i.bak "s/^version: .*/version: $NEW_VERSION/" "$PUBSPEC"
rm -f "$PUBSPEC.bak"

echo "Version bumped: $CURRENT_VERSION  →  $NEW_VERSION"

# Emit outputs for GitHub Actions (no-op outside Actions)
emit() { if [ -n "${GITHUB_ENV:-}" ]; then echo "$1=$2" >> "$GITHUB_ENV"; fi; }
emit NEW_VERSION  "$NEW_VERSION"
emit VERSION_NAME "${NEW_MAJOR}.${NEW_MINOR}"   # 2-part display name for tags
emit BUILD_NUMBER "$NEW_BUILD"
