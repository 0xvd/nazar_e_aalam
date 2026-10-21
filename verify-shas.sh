#!/usr/bin/env bash
set -euo pipefail

check() {
  local action="$1" sha="$2" tag="$3"

  # 1. Does the pinned SHA resolve to a real commit?
  local valid
  valid=$(curl -s "https://api.github.com/repos/${action}/commits/${sha}" | jq -r '.sha // empty')

  # 2. What SHA does the tag point to right now?
  local tag_sha
  tag_sha=$(curl -s "https://api.github.com/repos/${action}/git/refs/tags/${tag}" | jq -r '.object.sha // "?"')

  local v="INVALID"; [ -n "$valid" ] && v="valid"
  local f="?"
  if [ "$sha" = "$tag_sha" ]; then f="matches tag"
  elif [ -n "$tag_sha" ] && [ "$tag_sha" != "?" ]; then f="behind → ${tag_sha:0:12}"; fi

  printf "%-38s %-12s %-8s %s\n" "$action@$tag" "${sha:0:12}" "$v" "$f"
}

# ---- The SHAs currently in your workflows ----
check "actions/checkout"             "11d5960a326750d5838078e36cf38b85af677262" "v4"
check "actions/setup-java"           "cf277c60eb25467037889841efdb72551f06f6c3" "v4"
check "actions/upload-artifact"      "ea165f8d65b6e75b540449e92b4886f43607fa02" "v4"
check "actions/download-artifact"    "d3f86a106a0bac45b974a628896c90dbdf5c8093" "v4"
check "subosito/flutter-action"      "44ac965b96f18d999802d4b807e3256d5a3f9fa1" "v2.16.0"
check "softprops/action-gh-release"  "a06a81a03ee405af7f2048a818ed3f03bbf83c7b" "v2.5.0"