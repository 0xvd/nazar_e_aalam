#!/usr/bin/env bash
# =========================================================================== #
#  Nginx rule management — block IPs, manage rate limits
#
#  Usage:
#    ./scripts/nginx-rules.sh block 1.2.3.4                  # block single IP
#    ./scripts/nginx-rules.sh block 1.2.3.0/24               # block CIDR range
#    ./scripts/nginx-rules.sh unblock 1.2.3.4                # unblock
#    ./scripts/nginx-rules.sh list                           # show all blocked
#    ./scripts/nginx-rules.sh test                           # validate config
#    ./scripts/nginx-rules.sh reload                         # apply changes
#    ./scripts/nginx-rules.sh status                         # show zones + test
#    ./scripts/nginx-rules.sh show-config                    # print current file
#
#  Auto-reloads nginx after every modification.
# =========================================================================== #
set -euo pipefail

# ---- Config ----
BLOCKLIST="/etc/nginx/conf.d/blocklist.conf"
NGINX_BIN="${NGINX_BIN:-nginx}"
SUDO="${SUDO:-sudo}"

# ---- Helpers ----
die()    { echo "✗ $*" >&2; exit 1; }
ok()     { echo "✓ $*"; }
info()   { echo "→ $*"; }

require_root() {
    if [ "$EUID" -ne 0 ]; then
        die "Run as root: sudo $0 $*"
    fi
}

ensure_file() {
    if [ ! -f "$BLOCKLIST" ]; then
        info "Creating $BLOCKLIST"
        cat > "$BLOCKLIST" <<'EOF'
# Managed by scripts/nginx-rules.sh — do not edit by hand
# Format: deny <ip>;   or   deny <cidr>;
EOF
        chmod 644 "$BLOCKLIST"
    fi
}

validate_ip() {
    local ip="$1"
    # Accept plain IPv4 or CIDR — IPv6 not supported yet (easy to add)
    if [[ ! "$ip" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}(/[0-9]{1,2})?$ ]]; then
        die "Invalid IP/CIDR: $ip (expected 1.2.3.4 or 1.2.3.0/24)"
    fi
    # Reject privates? No — admins often need to block ranges that overlap.
    # Just sanity-check octets.
    local ifs_old="$IFS"
    IFS='./' read -ra parts <<< "$ip"
    IFS="$ifs_old"
    for p in "${parts[@]}"; do
        if [ "$p" -gt 255 ] 2>/dev/null; then
            die "Octet out of range: $p (in $ip)"
        fi
    done
}

test_and_reload() {
    info "Testing nginx config…"
    if ! $SUDO "$NGINX_BIN" -t 2>&1; then
        die "nginx config is invalid — changes NOT applied. Check output above."
    fi
    ok "nginx config valid"
    info "Reloading nginx…"
    $SUDO systemctl reload nginx
    ok "nginx reloaded"
}

# ---- Commands ----
cmd_block() {
    [ $# -eq 1 ] || die "Usage: $0 block <IP|CIDR>"
    local ip="$1"
    validate_ip "$ip"
    ensure_file

    if grep -qE "^deny ${ip//./\\.};" "$BLOCKLIST"; then
        ok "Already blocked: $ip"
        return
    fi

    info "Blocking $ip"
    echo "deny $ip;" >> "$BLOCKLIST"
    test_and_reload
    ok "Blocked $ip"
}

cmd_unblock() {
    [ $# -eq 1 ] || die "Usage: $0 unblock <IP|CIDR>"
    local ip="$1"
    validate_ip "$ip"
    ensure_file

    if ! grep -qE "^deny ${ip//./\\.};" "$BLOCKLIST"; then
        ok "Not in blocklist: $ip"
        return
    fi

    info "Unblocking $ip"
    # Use temp file + atomic move (safe against concurrent edits)
    local tmp
    tmp="$(mktemp)"
    grep -vE "^deny ${ip//./\\.};" "$BLOCKLIST" > "$tmp"
    mv "$tmp" "$BLOCKLIST"
    chmod 644 "$BLOCKLIST"
    test_and_reload
    ok "Unblocked $ip"
}

cmd_list() {
    ensure_file
    local count
    count=$(grep -cE '^deny ' "$BLOCKLIST" 2>/dev/null || echo 0)
    echo ""
    echo "═══════════════════════════════════════════════════"
    echo "  Blocked IPs: $count"
    echo "═══════════════════════════════════════════════════"
    if [ "$count" -eq 0 ]; then
        echo "  (none)"
    else
        grep -E '^deny ' "$BLOCKLIST" | nl -ba
    fi
    echo "═══════════════════════════════════════════════════"
}

cmd_status() {
    echo ""
    echo "═══════════════════════════════════════════════════"
    echo "  Nginx rate-limit zones"
    echo "═══════════════════════════════════════════════════"
    if [ -f /etc/nginx/conf.d/rate-limits.conf ]; then
        grep -E '^\s*limit_req_zone' /etc/nginx/conf.d/rate-limits.conf || echo "  (none defined)"
    else
        echo "  ⚠ /etc/nginx/conf.d/rate-limits.conf missing"
    fi

    echo ""
    echo "  Applied rules by location"
    echo "═══════════════════════════════════════════════════"
    for site in /etc/nginx/sites-enabled/*; do
        [ -f "$site" ] || continue
        local count
        count=$(grep -cE '^\s*limit_req\s' "$site" 2>/dev/null || echo 0)
        [ "$count" -gt 0 ] && echo "  $(basename "$site"): $count limit_req rules"
    done

    echo ""
    echo "  Blocklist"
    echo "═══════════════════════════════════════════════════"
    cmd_list

    echo ""
    info "Testing nginx config…"
    if $SUDO "$NGINX_BIN" -t >/dev/null 2>&1; then
        ok "nginx config valid"
    else
        die "nginx config INVALID — run: sudo nginx -t"
    fi
}

cmd_test() {
    info "Testing nginx config…"
    $SUDO "$NGINX_BIN" -t
}

cmd_reload() {
    test_and_reload
}

cmd_show_config() {
    ensure_file
    cat "$BLOCKLIST"
}

usage() {
    cat <<EOF
Nginx rule manager

  block <IP|CIDR>      Block an IP or range (auto-reloads nginx)
  unblock <IP|CIDR>    Remove an IP/range from the blocklist
  list                 Show all blocked IPs
  status               Show zones, applied rules, and blocklist
  test                 Validate nginx config
  reload               Reload nginx (after manual edits)
  show-config          Print the blocklist file

Examples:
  sudo \$0 block 45.123.45.67
  sudo \$0 block 203.0.113.0/24
  sudo \$0 unblock 45.123.45.67
  sudo \$0 list
  sudo \$0 status
EOF
}

# ---- Dispatch ----
case "${1:-}" in
    block)        require_root "$@"; shift; cmd_block "$@" ;;
    unblock)      require_root "$@"; shift; cmd_unblock "$@" ;;
    list)         cmd_list ;;
    status)       cmd_status ;;
    test)         require_root "$@"; cmd_test ;;
    reload)       require_root "$@"; cmd_reload ;;
    show-config)  cmd_show_config ;;
    ""|-h|--help|help)  usage ;;
    *)            die "Unknown command: $1 (run with no args for help)" ;;
esac