#!/usr/bin/env bash
# =========================================================================== #
#  Nazar-e-Aalam — one-shot Nginx setup
#  Serves the admin panel statically + proxies the API to FastAPI.
#
#  Usage:  sudo bash scripts/setup-nginx.sh admin.yourdomain.com
# =========================================================================== #
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "✗ Run as root: sudo bash $0 admin.yourdomain.com"
    exit 1
fi

DOMAIN="${1:?Usage: sudo bash $0 <domain>}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FRONTEND_DIR="$(cd "$PROJECT_ROOT/../frontend" && pwd)"

if [ ! -f "$FRONTEND_DIR/index.html" ]; then
    echo "✗ No index.html in $FRONTEND_DIR"
    exit 1
fi

echo "════════════════════════════════════════════════════"
echo "  Domain:   $DOMAIN"
echo "  Frontend: $FRONTEND_DIR"
echo "════════════════════════════════════════════════════"

# ---- 1. Rate-limit zones (shared, loaded first) ---------------------------
echo "→ /etc/nginx/conf.d/rate-limits.conf"
cat > /etc/nginx/conf.d/rate-limits.conf <<'EOF'
# Nazar-e-Aalam rate-limit zones.
limit_req_zone $binary_remote_addr zone=nazar_login:10m rate=5r/m;
limit_req_zone $binary_remote_addr zone=nazar_api:10m   rate=30r/s;
limit_req_status 429;
EOF

# ---- 2. Blocklist (managed by nginx-rules.sh) -----------------------------
echo "→ /etc/nginx/conf.d/blocklist.conf"
if [ ! -f /etc/nginx/conf.d/blocklist.conf ]; then
    cat > /etc/nginx/conf.d/blocklist.conf <<'EOF'
# Managed by scripts/nginx-rules.sh — do not edit by hand
# Format: deny <ip>;   or   deny <cidr>;
EOF
fi

# ---- 3. Site config -------------------------------------------------------
echo "→ /etc/nginx/sites-available/$DOMAIN"
cat > "/etc/nginx/sites-available/$DOMAIN" <<EOF
# ---- HTTP → HTTPS ----
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$host\$request_uri;
}

# ---- HTTPS ----
server {
    listen 443 ssl http2;
    server_name $DOMAIN;

    ssl_certificate     /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_protocols       TLSv1.2 TLSv1.3;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options    "nosniff" always;
    add_header X-Frame-Options           "DENY" always;
    add_header Referrer-Policy           "strict-origin-when-cross-origin" always;

    client_max_body_size 20M;

    include /etc/nginx/conf.d/blocklist.conf;

    # ---- Bootstrap endpoint (exact match) ----
    location = /panel_config {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host              \$host;
        proxy_set_header X-Real-IP         \$remote_addr;
        proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # ---- Health check ----
    location = /health {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
    }

    # ---- Login (strict rate limit) ----
    location = /api/auth/login {
        limit_req zone=nazar_login burst=3 nodelay;
        rewrite ^/api(/.*)\$ \$1 break;
        proxy_pass http://127.0.0.1:8000;
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
    }

    # ---- Frontend root ----
    location = / {
        return 302 /panel/;
    }

    # ---- Panel static files ----
    location /panel/ {
        alias $FRONTEND_DIR/;
        try_files \$uri \$uri/ =404;

        # Never cache HTML — every deploy takes effect immediately
        location ~* \.html\$ {
            expires -1;
            add_header Cache-Control "no-cache, must-revalidate" always;
        }

        # JS/CSS — short cache (1 hour). Small team → hard-refresh after deploy.
        location ~* \.(js|css)\$ {
            expires 1h;
            add_header Cache-Control "public, max-age=3600" always;
        }

        # Fonts/images — cache hard (1 year, immutable)
        location ~* \.(woff2?|ttf|eot|png|jpe?g|gif|svg|ico|webp)\$ {
            expires 1y;
            add_header Cache-Control "public, immutable" always;
            access_log off;
        }
    }

    # Anything else → 404 (no catch-all routes)
    location / {
        return 404;
    }
}
EOF

# ---- 4. Enable + reload ---------------------------------------------------
echo "→ Enabling site"
ln -sf "/etc/nginx/sites-available/$DOMAIN" "/etc/nginx/sites-enabled/$DOMAIN"
rm -f /etc/nginx/sites-enabled/default

echo "→ Testing nginx config"
nginx -t

echo "→ Reloading nginx"
systemctl reload nginx

echo ""
echo "════════════════════════════════════════════════════"
echo "  ✅ Nginx configured"
echo "════════════════════════════════════════════════════"
echo ""
echo "  Next:"
echo "    sudo certbot --nginx -d $DOMAIN"
echo ""
echo "  Then test:"
echo "    curl -sI https://$DOMAIN/panel/index.html | head -1    # 200"
echo "    curl -s  https://$DOMAIN/panel_config | head -c 200    # JSON"
echo "    curl -s  https://$DOMAIN/api/health                    # ok"