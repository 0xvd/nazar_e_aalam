#!/usr/bin/env bash
set -euo pipefail

# Default to the monorepo path, but allow override
PUBSPEC="${PUBSPEC_PATH:-application/pubspec.yaml}"

if [ ! -f "$PUBSPEC" ]; then
  echo "ERROR: pubspec.yaml not found at $PUBSPEC" >&2
  exit 1
fi

CURRENT_LINE=$(grep '^version:' "$PUBSPEC" | head -n1)
CURRENT_VERSION=$(echo "$CURRENT_LINE" | sed 's/version: *//')

# Split "1.2+7" into "1.2" and "7"
VERSION_PART="${CURRENT_VERSION%%+*}"
if [[ "$CURRENT_VERSION" == *"+"* ]]; then
  BUILD_PART="${CURRENT_VERSION##*+}"
else
  BUILD_PART="0"
fi

# Parse major.minor (patch is intentionally ignored per your spec)
IFS='.' read -r MAJOR MINOR _ <<< "$VERSION_PART"

# Your custom rollover: 1.0 → 1.9 → 2.0
if [ "$MINOR" -lt 9 ]; then
  NEW_MINOR=$((MINOR + 1))
  NEW_MAJOR=$MAJOR
else
  NEW_MINOR=0
  NEW_MAJOR=$((MAJOR + 1))
fi

NEW_BUILD=$((BUILD_PART + 1))
NEW_VERSION="${NEW_MAJOR}.${NEW_MINOR}+${NEW_BUILD}"

# Write back
sed -i.bak "s/^version: .*/version: $NEW_VERSION/" "$PUBSPEC"
rm -f "$PUBSPEC.bak"

echo "Version bumped: $CURRENT_VERSION  →  $NEW_VERSION"

# Emit to $GITHUB_ENV so later steps / outputs can use them
echo "NEW_VERSION=$NEW_VERSION"     >> "$GITHUB_ENV"
echo "VERSION_NAME=${NEW_MAJOR}.${NEW_MINOR}" >> "$GITHUB_ENV"
echo "BUILD_NUMBER=$NEW_BUILD"      >> "$GITHUB_ENV"