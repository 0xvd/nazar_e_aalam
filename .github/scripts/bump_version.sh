#!/usr/bin/env bash
set -euo pipefail

PUBSPEC="${PUBSPEC_PATH:-application/pubspec.yaml}"

if [ ! -f "$PUBSPEC" ]; then
  echo "ERROR: pubspec.yaml not found at $PUBSPEC" >&2
  exit 1
fi

CURRENT_LINE=$(grep '^version:' "$PUBSPEC" | head -n1)
CURRENT_VERSION=$(echo "$CURRENT_LINE" | sed 's/version: *//')

if [ -z "$CURRENT_VERSION" ]; then
  echo "ERROR: no 'version:' line in $PUBSPEC" >&2
  exit 1
fi

VERSION_PART="${CURRENT_VERSION%%+*}"
if [[ "$CURRENT_VERSION" == *"+"* ]]; then
  BUILD_PART="${CURRENT_VERSION##*+}"
else
  BUILD_PART="0"
fi

IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION_PART"
MAJOR="${MAJOR:-1}"; MINOR="${MINOR:-0}"; PATCH="${PATCH:-0}"

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

if ! grep -q "^version: $NEW_VERSION$" "$PUBSPEC"; then
  echo "ERROR: sed did not update $PUBSPEC" >&2
  exit 1
fi

echo "Version bumped: $CURRENT_VERSION  ->  $NEW_VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  {
    echo "new_version=$NEW_VERSION"
    echo "version_name=${NEW_MAJOR}.${NEW_MINOR}.0"
    echo "build_number=$NEW_BUILD"
  } >> "$GITHUB_OUTPUT"
fi
