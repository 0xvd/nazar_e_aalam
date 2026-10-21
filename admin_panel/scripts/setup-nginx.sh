#!/usr/bin/env bash
# =========================================================================== #
#  Nazar-e-Aalam — one-shot Nginx setup
#  Serves the admin panel statically + proxies the API to FastAPI.
#
#  Usage:
#    sudo bash scripts/setup-nginx.sh admin.yourdomain.com
#
#  Two-phase setup:
#    1. First run  → writes HTTP-only config (works before certbot exists)
#    2. Certbot    → sudo certbot --nginx -d <domain>
#    3. Re-run     → writes full HTTPS config
# =========================================================================== #
set -euo pipefail

# --- Root check -----------------------------------------------------------
if [ "$EUID" -ne 0 ]; then
    echo "✗ Run as root: sudo bash $0 <domain>"
    exit 1
fi

DOMAIN="${1:?Usage: sudo bash $0 <domain>}"

# --- Locate project directories -------------------------------------------
# Resolve symlinks so the script works from any CWD.
SCRIPT_SRC="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_SRC" ]; do
    DIR="$(cd -P "$(dirname "$SCRIPT_SRC")" && pwd)"
    SCRIPT_SRC="$(readlink "$SCRIPT_SRC")"
    [[ "$SCRIPT_SRC" != /* ]] && SCRIPT_SRC="$DIR/$SCRIPT_SRC"
done
BACKEND_DIR="$(cd -P "$(dirname "$SCRIPT_SRC")/.." && pwd)"
FRONTEND_DIR="$BACKEND_DIR/panel"

# --- Pre-flight -----------------------------------------------------------
echo "════════════════════════════════════════════════════"
echo "  Domain:   $DOMAIN"
echo "  Backend:  $BACKEND_DIR"
echo "  Frontend: $FRONTEND_DIR"
echo "════════════════════════════════════════════════════"

for f in index.html assets/js/api.js assets/js/app.js assets/css/style.css; do
    if [ ! -f "$FRONTEND_DIR/$f" ]; then
        echo "✗ Missing $FRONTEND_DIR/$f"
        echo "  Expected panel/ inside $BACKEND_DIR"
        exit 1
    fi
done

if ! command -v nginx >/dev/null; then
    echo "✗ nginx not installed. Run: sudo apt install nginx"
    exit 1
fi

# --- Backend liveness (warn, don't fail) ----------------------------------
if ! curl -sf --max-time 2 http://127.0.0.1:8000/health >/dev/null 2>&1; then
    echo ""
    echo "⚠  Backend not responding on 127.0.0.1:8000/health"
    echo "   Start it first: sudo systemctl start nazar-e-alam"
    echo "   (continuing — nginx config is still valid)"
    echo ""
fi

# --- 1. Rate-limit zones (shared, loaded first) ---------------------------
echo "→ /etc/nginx/conf.d/rate-limits.conf"
cat > /etc/nginx/conf.d/rate-limits.conf <<'EOF'
# Nazar-e-Aalam rate-limit zones.
limit_req_zone $binary_remote_addr zone=nazar_login:10m rate=5r/m;
limit_req_zone $binary_remote_addr zone=nazar_api:10m   rate=30r/s;
limit_req_status 429;
EOF

# --- 2. Blocklist (managed by nginx-rules.sh) -----------------------------
echo "→ /etc/nginx/conf.d/blocklist.conf"
if [ ! -f /etc/nginx/conf.d/blocklist.conf ]; then
    cat > /etc/nginx/conf.d/blocklist.conf <<'EOF'
# Managed by scripts/nginx-rules.sh — do not edit by hand
# Format: deny <ip>;   or   deny <cidr>;
EOF
fi

# --- 3. Detect cert state -------------------------------------------------
CERT_DIR="/etc/letsencrypt/live/$DOMAIN"
HAS_CERT=0
if [ -f "$CERT_DIR/fullchain.pem" ] && [ -f "$CERT_DIR/privkey.pem" ]; then
    HAS_CERT=1
fi

SITE="/etc/nginx/sites-available/$DOMAIN"
MODE="$([ "$HAS_CERT" -eq 1 ] && echo HTTPS || echo HTTP-bootstrap)"
echo "→ $SITE (mode: $MODE)"

# =========================================================================== #
#  4a. HTTP-only config (first run — before certbot)
# =========================================================================== #
if [ "$HAS_CERT" -eq 0 ]; then
    cat > "$SITE" <<EOF
# Nazar-e-Aalam — HTTP bootstrap (no TLS yet).
# Run certbot, then re-run this script to switch to HTTPS.
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN;

    client_max_body_size 20M;

    include /etc/nginx/conf.d/blocklist.conf;

    # ACME challenge for certbot
    location /.well-known/acme-challenge/ {
        root /var/www/html;
        default_type "text/plain";
    }

    # ---- Bootstrap ----
    location = /panel_config {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host              \$host;
        proxy_set_header X-Real-IP         \$remote_addr;
        proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # ---- Health ----
    location = /health {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host              \$host;
        proxy_set_header X-Real-IP         \$remote_addr;
        proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # ---- Login (strict rate limit) ----
    location = /api/auth/login {
        limit_req zone=nazar_login burst=3 nodelay;
        rewrite ^/api(/.*)\$ \$1 break;
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host              \$host;
        proxy_set_header X-Real-IP         \$remote_addr;
        proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # ---- Everything else under /api/ ----
    location /api/ {
        limit_req zone=nazar_api burst=40 nodelay;
        rewrite ^/api/?(.*)\$ /\$1 break;
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host              \$host;
        proxy_set_header X-Real-IP         \$remote_addr;
        proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 120s;
        proxy_send_timeout 120s;
    }

    # ---- Root redirect ----
    location = /       { return 302 /panel/; }
    location = /panel  { return 301 /panel/; }

    # ---- Panel static files ----
    location /panel/ {
        root $BACKEND_DIR;
        try_files \$uri \$uri/ =404;

        location ~* \.html\$ {
            expires -1;
            add_header Cache-Control "no-cache, must-revalidate" always;
        }
        location ~* \.(js|css)\$ {
            expires 1h;
            add_header Cache-Control "public, max-age=3600" always;
        }
        location ~* \.(woff2?|ttf|eot|png|jpe?g|gif|svg|ico|webp)\$ {
            expires 1y;
            add_header Cache-Control "public, immutable" always;
            access_log off;
        }
    }

    location / { return 404; }
}
EOF
fi

# =========================================================================== #
#  4b. Full HTTPS config (after certbot)
# =========================================================================== #
if [ "$HAS_CERT" -eq 1 ]; then
    cat > "$SITE" <<EOF
# Nazar-e-Aalam — production HTTPS config.

# ---- HTTP → HTTPS ----
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN;

    location /.well-known/acme-challenge/ {
        root /var/www/html;
        default_type "text/plain";
    }

    location / { return 301 https://\$host\$request_uri; }
}

# ---- HTTPS ----
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN;

    ssl_certificate     $CERT_DIR/fullchain.pem;
    ssl_certificate_key $CERT_DIR/privkey.pem;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;
    ssl_session_cache   shared:SSL:10m;
    ssl_session_timeout 1d;

    # Security headers (mirror FastAPI middleware)
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Content-Type-Options    "nosniff" always;
    add_header X-Frame-Options           "DENY" always;
    add_header Referrer-Policy           "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy        "geolocation=(), microphone=(), camera=()" always;

    client_max_body_size 20M;

    include /etc/nginx/conf.d/blocklist.conf;

    # ---- Bootstrap ----
    location = /panel_config {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host              \$host;
        proxy_set_header X-Real-IP         \$remote_addr;
        proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # ---- Health ----
    location = /health {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host              \$host;
        proxy_set_header X-Real-IP         \$remote_addr;
        proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # ---- Login ----
    location = /api/auth/login {
        limit_req zone=nazar_login burst=3 nodelay;
        rewrite ^/api(/.*)\$ \$1 break;
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host              \$host;
        proxy_set_header X-Real-IP         \$remote_addr;
        proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # ---- API ----
    location /api/ {
        limit_req zone=nazar_api burst=40 nodelay;
        rewrite ^/api/?(.*)\$ /\$1 break;
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host              \$host;
        proxy_set_header X-Real-IP         \$remote_addr;
        proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 120s;
        proxy_send_timeout 120s;
    }

    # ---- Root redirect ----
    location = /       { return 302 /panel/; }
    location = /panel  { return 301 /panel/; }

    # ---- Panel static files ----
    location /panel/ {
        root $BACKEND_DIR;
        try_files \$uri \$uri/ =404;

        location ~* \.html\$ {
            expires -1;
            add_header Cache-Control "no-cache, must-revalidate" always;
        }
        location ~* \.(js|css)\$ {
            expires 1h;
            add_header Cache-Control "public, max-age=3600" always;
        }
        location ~* \.(woff2?|ttf|eot|png|jpe?g|gif|svg|ico|webp)\$ {
            expires 1y;
            add_header Cache-Control "public, immutable" always;
            access_log off;
        }
    }

    location / { return 404; }
}
EOF
fi

# --- 5. Enable site -------------------------------------------------------
echo "→ Enabling site"
ln -sf "$SITE" "/etc/nginx/sites-enabled/$DOMAIN"
rm -f /etc/nginx/sites-enabled/default

# --- 6. Test + reload -----------------------------------------------------
echo "→ Testing nginx config"
if ! nginx -t; then
    echo ""
    echo "✗ nginx -t failed. Fix the error above and re-run."
    exit 1
fi

echo "→ Reloading nginx"
systemctl reload nginx

# --- 7. Next steps --------------------------------------------------------
echo ""
echo "════════════════════════════════════════════════════"
echo "  ✅ Nginx configured ($MODE)"
echo "════════════════════════════════════════════════════"
echo ""

if [ "$HAS_CERT" -eq 0 ]; then
    echo "  Phase 1 complete — HTTP only."
    echo ""
    echo "  → Issue a certificate:"
    echo "      sudo certbot --nginx -d $DOMAIN"
    echo ""
    echo "  → Then re-run this script to switch to HTTPS:"
    echo "      sudo bash $0 $DOMAIN"
    echo ""
    echo "  Test now (HTTP):"
    echo "      curl -sI http://$DOMAIN/panel/index.html | head -1"
    echo "      curl -s  http://$DOMAIN/panel_config | head -c 200"
else
    echo "  Phase 2 complete — HTTPS live."
    echo ""
    echo "  Test:"
    echo "      curl -sI https://$DOMAIN/panel/index.html | head -1       # 200"
    echo "      curl -s  https://$DOMAIN/panel_config | jq .api_base     # \"/api\""
    echo "      curl -s  https://$DOMAIN/api/health                      # ok"
    echo ""
    echo "  Verify certbot auto-renewal:"
    echo "      sudo systemctl list-timers | grep certbot"
fi
echo ""