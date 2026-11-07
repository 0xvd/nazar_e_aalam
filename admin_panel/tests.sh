#!/usr/bin/env bash
# =========================================================================== #
#  Nazar-e-Aalam — endpoint smoke tests
#
#  Usage:
#    ./tests.sh                              # run all tests
#    ./tests.sh --test auth,mosques          # run only selected groups
#    ./tests.sh --test mosques               # run one group
#    ./tests.sh --list                       # list available groups
#
#  Environment:
#    BASE=http://localhost:8000
#    EMAIL=admin@example.com
#    PASS=admin123
# =========================================================================== #
set -uo pipefail

BASE="${BASE:-http://localhost:8000}"
EMAIL="${EMAIL:-admin@example.com}"
PASS="${PASS:-admin123}"

PASS_COUNT=0
FAIL_COUNT=0
TOKEN=""

# ---- Test group registry --------------------------------------------------
# Order matters — auth runs first to obtain TOKEN.
ALL_GROUPS=(
    server
    auth
    crud
    dhikr
    devices
    chapters
    verses
    administrators
    settings
    reciters
    prayer
    hijri
    backup
    mosques
)
SELECTED_GROUPS=()

# ---- CLI parsing ----------------------------------------------------------
print_usage() {
    cat <<EOF
Usage: $0 [options]

Options:
  --test <groups>   Comma-separated list of groups to run
                    e.g. --test auth,mosques
  --list            List available groups and exit
  -h, --help        Show this help

Groups:
  $(printf '%s ' "${ALL_GROUPS[@]}")
EOF
}

list_groups() {
    echo "Available test groups:"
    for g in "${ALL_GROUPS[@]}"; do
        echo "  - $g"
    done
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --test)
            shift
            if [[ $# -eq 0 ]]; then
                echo "❌ --test requires a value (e.g., --test auth,mosques)"
                exit 1
            fi
            IFS=',' read -ra SELECTED_GROUPS <<< "$1"
            shift
            ;;
        --test=*)
            IFS=',' read -ra SELECTED_GROUPS <<< "${1#--test=}"
            shift
            ;;
        --list)
            list_groups
            exit 0
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "❌ Unknown argument: $1"
            print_usage
            exit 1
            ;;
    esac
done

# Default: run all
if [[ ${#SELECTED_GROUPS[@]} -eq 0 ]]; then
    SELECTED_GROUPS=("${ALL_GROUPS[@]}")
fi

# Validate requested groups
for g in "${SELECTED_GROUPS[@]}"; do
    found=0
    for valid in "${ALL_GROUPS[@]}"; do
        if [[ "$g" == "$valid" ]]; then found=1; break; fi
    done
    if [[ $found -eq 0 ]]; then
        echo "❌ Unknown test group: $g"
        list_groups
        exit 1
    fi
done

should_run() {
    local g="$1"
    for s in "${SELECTED_GROUPS[@]}"; do
        [[ "$s" == "$g" ]] && return 0
    done
    return 1
}

# ---- output helpers -------------------------------------------------------
say()   { echo -e "\n\033[1;36m=== $* ===\033[0m"; }
ok()    { echo -e "  \033[0;32m✓\033[0m $1"; PASS_COUNT=$((PASS_COUNT+1)); }
err()   { echo -e "  \033[0;31m✗\033[0m $1"; FAIL_COUNT=$((FAIL_COUNT+1)); }

check_status() {
    local label="$1" expected="$2"
    shift 2
    local actual
    actual=$(curl -s -o /dev/null -w "%{http_code}" "$@")
    if [ "$actual" = "$expected" ]; then
        ok "$label ($actual)"
    else
        err "$label (expected $expected, got $actual)"
    fi
}

check_json_field() {
    local label="$1" expected="$2" path="$3"
    shift 3
    local actual
    actual=$(curl -s "$@" | python -c "
import sys, json
try:
    d = json.load(sys.stdin)
    v = d
    for k in '$path'.split('.'):
        v = v[int(k)] if k.isdigit() else v[k]
    print(v)
except Exception:
    print('__missing__')
" 2>/dev/null)
    if [ "$actual" = "$expected" ]; then
        ok "$label = $actual"
    else
        err "$label (expected $expected, got $actual)"
    fi
}

# ---- preflight: is the server even running? ------------------------------
preflight() {
    local code
    code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$BASE/health" 2>/dev/null || true)

    if [ -z "$code" ] || [ "$code" = "000" ]; then
        echo ""
        echo -e "\033[0;31m❌ Server not reachable at $BASE\033[0m"
        echo ""
        echo "   Start it first:"
        echo "     cd ~/mydata/nazar_e_alam/admin_panel"
        echo "     py main.py"
        echo ""
        echo "   Or if you run it elsewhere:"
        echo "     BASE=http://your-host:8000 ./tests.sh"
        echo ""
        exit 2
    fi
}

# ---- run preflight --------------------------------------------------------
preflight

# =========================================================================== #
#  TESTS
# =========================================================================== #

# ---- Server --------------------------------------------------------------
if should_run "server"; then
    say "Server"
    check_status "GET /health" 200 "$BASE/health"
fi

# ---- Auth ----------------------------------------------------------------
if should_run "auth"; then
    say "Authentication"

    check_status "POST /auth/login (bad body)" 422 \
        -X POST "$BASE/auth/login" -H "Content-Type: application/json" -d '{}'

    check_status "POST /auth/login (wrong password)" 401 \
        -X POST "$BASE/auth/login" -H "Content-Type: application/json" \
        -d "{\"email\":\"$EMAIL\",\"password\":\"wrongwrong\"}"

    TOKEN=$(curl -s -X POST "$BASE/auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"$EMAIL\",\"password\":\"$PASS\"}" \
        | python -c "import sys,json; print(json.load(sys.stdin).get('access_token',''))")

    if [ -z "$TOKEN" ]; then
        err "Login failed — cannot continue"
        echo ""; echo "  Passed: $PASS_COUNT   Failed: $FAIL_COUNT"
        exit 1
    fi
    ok "Login → token received (${#TOKEN} chars)"

    check_status "GET /auth/me (authed)" 200 \
        "$BASE/auth/me" -H "Authorization: Bearer $TOKEN"

    check_status "GET /auth/me (no token)" 401 "$BASE/auth/me"

    check_status "GET /auth/me (bad token)" 401 \
        "$BASE/auth/me" -H "Authorization: Bearer not.a.real.token"
fi

# ---- If TOKEN is needed but not set, fetch it silently --------------------
# Some groups (crud, administrators, etc.) require TOKEN. If the user
# didn't select "auth", fetch it here so their selected groups still work.
if [ -z "$TOKEN" ]; then
    needs_token=0
    for g in crud chapters verses administrators settings prayer hijri backup devices mosques dhikr; do
        if should_run "$g"; then needs_token=1; break; fi
    done
    if [ $needs_token -eq 1 ]; then
        TOKEN=$(curl -s -X POST "$BASE/auth/login" \
            -H "Content-Type: application/json" \
            -d "{\"email\":\"$EMAIL\",\"password\":\"$PASS\"}" \
            | python -c "import sys,json; print(json.load(sys.stdin).get('access_token',''))")
        if [ -z "$TOKEN" ]; then
            echo -e "\033[0;31m❌ Could not obtain token for authenticated tests\033[0m"
            exit 1
        fi
    fi
fi

# ---- Generic CRUD --------------------------------------------------------
if should_run "crud"; then
    crud_test() {
        local resource="$1" label="$2" body="$3"
        say "$label"

        check_status "GET /$resource" 200 "$BASE/$resource"

        check_status "POST /$resource (no auth)" 401 \
            -X POST "$BASE/$resource" -H "Content-Type: application/json" -d "$body"

        local resp id
        resp=$(curl -s -X POST "$BASE/$resource" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" -d "$body")
        id=$(echo "$resp" | python -c "import sys,json; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)

        if [ -z "$id" ]; then
            err "POST /$resource (authed) — could not create: $resp"
            return
        fi
        ok "POST /$resource (authed) → id=$id"

        check_status "GET /$resource/$id" 200 "$BASE/$resource/$id"
        check_status "GET /$resource/999999" 404 "$BASE/$resource/999999"

        check_status "PATCH /$resource/$id (empty)" 400 \
            -X PATCH "$BASE/$resource/$id" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" -d '{}'

        check_status "DELETE /$resource/$id" 204 \
            -X DELETE "$BASE/$resource/$id" -H "Authorization: Bearer $TOKEN"

        check_status "GET /$resource/$id (after delete)" 404 "$BASE/$resource/$id"
    }

    crud_test "duas" "Duas" \
        '{"position":99,"en_short_name":"Test","ar_short_name":"اختبار"}'
    crud_test "dhikrs" "Dhikrs" \
        '{"position":99,"en_short_name":"Test","ar_short_name":"اختبار"}'
    crud_test "wallpapers" "Wallpapers" \
        '{"name":"Test","image":"https://example.com/x.jpg"}'
    crud_test "sifat-names" "SifatNames" \
        '{"position":99,"name":"Test"}'
    crud_test "haram-codes" "HaramCodes" \
        '{"code":"TEST99","name":"Test"}'
    crud_test "translators" "Translators" \
        '{"full_name":"Test","short_name":"T","language":"English","language_code":"en"}'
fi

# ---- Chapters ------------------------------------------------------------
if should_run "chapters"; then
    say "Chapters"
    check_status "GET /chapters" 200 "$BASE/chapters"
    check_status "GET /chapters/1" 200 "$BASE/chapters/1"
    check_status "GET /chapters/114" 200 "$BASE/chapters/114"
    check_status "GET /chapters/999" 404 "$BASE/chapters/999"

    check_json_field "Chapters count = 114" "114" "meta.total" \
        "$BASE/chapters?limit=500"

    check_json_field "Chapter 1 arabic_name" "الفاتحة" "arabic_name" \
        "$BASE/chapters/1"

    check_json_field "Chapter 36 name" "يس" "arabic_name" "$BASE/chapters/36"
fi

# ---- Verses --------------------------------------------------------------
if should_run "verses"; then
    say "Chapter verses & translations"

    TRANS_RESP=$(curl -s -X POST "$BASE/translators" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"full_name":"Sahih International","short_name":"Sahih","language":"English","language_code":"en"}')
    TID=$(echo "$TRANS_RESP" | python -c "import sys,json; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
    [ -n "$TID" ] && ok "Created translator id=$TID" || err "Translator create failed: $TRANS_RESP"

    VCOUNT=$(curl -s "$BASE/chapters/1/verses" -H "Authorization: Bearer $TOKEN" \
        | python -c "import sys,json; print(json.load(sys.stdin)['meta']['total'])")
    [ "$VCOUNT" = "0" ] && ok "Chapter 1 verses initially empty" || err "Chapter 1 verses count: expected 0, got $VCOUNT"

    VERSE_RESP=$(curl -s -X POST "$BASE/chapters/1/verses" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"verse_number":1,"verse_key":"1:1","arabic_name":"بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ","english_transliteration":"Bismillah ir-Rahman ir-Rahim","hizb_number":1,"rub_el_hizb_number":1,"ruku_number":1,"manzil_number":1,"sajdah_number":0,"page_number":1,"juz_number":1}')
    VID=$(echo "$VERSE_RESP" | python -c "import sys,json; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
    [ -n "$VID" ] && ok "Created verse id=$VID in chapter 1" || err "Verse create failed: $VERSE_RESP"

    check_status "GET /chapters/1/verses/$VID" 200 "$BASE/chapters/1/verses/$VID"
    check_status "GET /chapters/2/verses/$VID (wrong chapter)" 404 "$BASE/chapters/2/verses/$VID"

    TR_RESP=$(curl -s -X POST "$BASE/chapters/1/verses/$VID/translations" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"translator_id\":$TID,\"verse_number\":1,\"translate_name\":\"In the name of Allah, the Entirely Merciful, the Especially Merciful.\"}")
    TRID=$(echo "$TR_RESP" | python -c "import sys,json; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
    [ -n "$TRID" ] && ok "Created translation id=$TRID" || err "Translation create failed: $TR_RESP"

    check_status "GET translation by id" 200 \
        "$BASE/chapters/1/verses/$VID/translations/$TRID"

    FULL=$(curl -s "$BASE/chapters/1/verses-full")
    FCOUNT=$(echo "$FULL" | python -c "import sys,json; print(json.load(sys.stdin).get('total_verses',-1))" 2>/dev/null)
    [ "$FCOUNT" = "1" ] && ok "Composite: 1 verse in chapter 1" || err "Composite: expected 1 verse, got $FCOUNT"

    FTRANS=$(echo "$FULL" | python -c "import sys,json; d=json.load(sys.stdin); print(len(d['verses'][0]['translations']))" 2>/dev/null)
    [ "$FTRANS" = "1" ] && ok "Composite: verse 1 has 1 translation" || err "Composite: expected 1 translation, got $FTRANS"

    FARABIC=$(echo "$FULL" | python -c "import sys,json; print(json.load(sys.stdin)['verses'][0]['arabic_name'])" 2>/dev/null)
    [ -n "$FARABIC" ] && ok "Composite: arabic text present" || err "Composite: arabic text missing"

    FFILT=$(curl -s "$BASE/chapters/1/verses-full?translator_id=999999" \
        | python -c "import sys,json; d=json.load(sys.stdin); print(sum(len(v['translations']) for v in d['verses']))" 2>/dev/null)
    [ "$FFILT" = "0" ] && ok "Composite: unknown translator yields 0 translations" || err "Composite filter: expected 0, got $FFILT"

    check_status "DELETE translation $TRID" 204 \
        -X DELETE "$BASE/chapters/1/verses/$VID/translations/$TRID" -H "Authorization: Bearer $TOKEN"
    check_status "DELETE verse $VID" 204 \
        -X DELETE "$BASE/chapters/1/verses/$VID" -H "Authorization: Bearer $TOKEN"
    check_status "DELETE translator $TID" 204 \
        -X DELETE "$BASE/translators/$TID" -H "Authorization: Bearer $TOKEN"
fi

# ---- Administrators ------------------------------------------------------
if should_run "administrators"; then
    say "Administrators"

    ADMIN_EMAIL="test-admin-$(date +%s)-${RANDOM}@example.com"
    ADMIN_PASS="testpass123"
    ADMIN_PASS2="newpass456"

    check_status "GET /administrators (no auth)" 401 "$BASE/administrators"

    ADMIN_COUNT=$(curl -s "$BASE/administrators" -H "Authorization: Bearer $TOKEN" \
        | python -c "import sys,json; print(json.load(sys.stdin)['meta']['total'])" 2>/dev/null)
    if [ -n "$ADMIN_COUNT" ] && [ "$ADMIN_COUNT" -ge 1 ]; then
        ok "Administrators count = $ADMIN_COUNT"
    else
        err "Administrators count (got '$ADMIN_COUNT')"
    fi

    NEW_RESP=$(curl -s -X POST "$BASE/administrators" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASS\",\"first_name\":\"Test\",\"last_name\":\"Admin\"}")
    NEW_ID=$(echo "$NEW_RESP" | python -c "import sys,json; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
    [ -n "$NEW_ID" ] && ok "Created admin id=$NEW_ID ($ADMIN_EMAIL)" || err "Admin create failed: $NEW_RESP"

    check_status "GET /administrators/$NEW_ID" 200 \
        "$BASE/administrators/$NEW_ID" -H "Authorization: Bearer $TOKEN"

    check_status "POST /administrators (duplicate email)" 409 \
        -X POST "$BASE/administrators" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"otherpass123\"}"

    check_status "POST /administrators (bad body)" 422 \
        -X POST "$BASE/administrators" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{}'

    check_status "POST /administrators (short password)" 422 \
        -X POST "$BASE/administrators" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"email":"x@example.com","password":"123"}'

    NEW_TOKEN=$(curl -s -X POST "$BASE/auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASS\"}" \
        | python -c "import sys,json; print(json.load(sys.stdin).get('access_token',''))")
    [ -n "$NEW_TOKEN" ] && ok "New admin can log in" || err "New admin login failed"

    DUA_RESP=$(curl -s -X POST "$BASE/duas" \
        -H "Authorization: Bearer $NEW_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"position":100,"en_short_name":"temp-test"}')
    DUA_ID=$(echo "$DUA_RESP" | python -c "import sys,json; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
    [ -n "$DUA_ID" ] && ok "New admin can create dua (id=$DUA_ID)" \
        || err "New admin could not create dua"
    curl -s -o /dev/null -X DELETE "$BASE/duas/$DUA_ID" -H "Authorization: Bearer $TOKEN"

    check_status "PATCH admin password" 200 \
        -X PATCH "$BASE/administrators/$NEW_ID" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"password\":\"$ADMIN_PASS2\"}"

    check_status "Old password rejected" 401 \
        -X POST "$BASE/auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASS\"}"

    NEW_TOKEN2=$(curl -s -X POST "$BASE/auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASS2\"}" \
        | python -c "import sys,json; print(json.load(sys.stdin).get('access_token',''))")
    [ -n "$NEW_TOKEN2" ] && ok "New password accepted" || err "New password rejected"

    MY_ID=$(curl -s "$BASE/auth/me" -H "Authorization: Bearer $TOKEN" \
        | python -c "import sys,json; print(json.load(sys.stdin)['id'])")

    check_status "Self-demotion rejected" 400 \
        -X PATCH "$BASE/administrators/$MY_ID" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"is_admin":false}'

    check_status "Self-delete rejected" 400 \
        -X DELETE "$BASE/administrators/$MY_ID" -H "Authorization: Bearer $TOKEN"

    check_status "Demote new admin" 200 \
        -X PATCH "$BASE/administrators/$NEW_ID" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"is_admin":false}'

    check_status "Demoted admin blocked from POST /duas" 403 \
        -X POST "$BASE/duas" \
        -H "Authorization: Bearer $NEW_TOKEN2" \
        -H "Content-Type: application/json" \
        -d '{"position":101}'

    check_status "GET demoted user by ID (still accessible)" 200 \
        "$BASE/administrators/$NEW_ID" -H "Authorization: Bearer $TOKEN"

    POST_DEMOTE_COUNT=$(curl -s "$BASE/administrators?limit=500" -H "Authorization: Bearer $TOKEN" \
        | python -c "import sys,json; print(json.load(sys.stdin)['meta']['total'])" 2>/dev/null)
    [ "$POST_DEMOTE_COUNT" = "$ADMIN_COUNT" ] && ok "Demoted user excluded from list ($POST_DEMOTE_COUNT)" \
        || err "List after demote: expected $ADMIN_COUNT, got $POST_DEMOTE_COUNT"

    DEMOTED_FLAG=$(curl -s "$BASE/administrators/$NEW_ID" -H "Authorization: Bearer $TOKEN" \
        | python -c "import sys,json; print(json.load(sys.stdin).get('is_admin','missing'))" 2>/dev/null)
    [ "$DEMOTED_FLAG" = "False" ] && ok "Demoted user has is_admin=false" \
        || err "Demoted user is_admin: expected False, got $DEMOTED_FLAG"

    check_status "Re-promote admin" 200 \
        -X PATCH "$BASE/administrators/$NEW_ID" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"is_admin":true}'

    check_status "DELETE admin $NEW_ID" 204 \
        -X DELETE "$BASE/administrators/$NEW_ID" -H "Authorization: Bearer $TOKEN"

    check_status "GET deleted admin" 404 \
        "$BASE/administrators/$NEW_ID" -H "Authorization: Bearer $TOKEN"
fi

# ---- Settings ------------------------------------------------------------
if should_run "settings"; then
    say "Settings"

    for s in _test_theme _test_layout _test_lang _test_null; do
        curl -s -o /dev/null -X DELETE "$BASE/settings/$s" -H "Authorization: Bearer $TOKEN"
    done

    check_status "GET /settings" 200 "$BASE/settings"
    check_status "GET /settings/map" 200 "$BASE/settings/map"

    check_status "PUT /settings/_test_theme (no auth)" 401 \
        -X PUT "$BASE/settings/_test_theme" \
        -H "Content-Type: application/json" -d '{"value":"midnight"}'

    check_status "PUT /settings/_test_theme → 201 (created)" 201 \
        -X PUT "$BASE/settings/_test_theme" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"value":"midnight"}'

    check_status "PUT /settings/_test_theme → 200 (updated)" 200 \
        -X PUT "$BASE/settings/_test_theme" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"value":"emerald"}'

    check_json_field "Setting _test_theme value" "emerald" "value" \
        "$BASE/settings/_test_theme"

    MAP_VAL=$(curl -s "$BASE/settings/map" | python -c "
import sys, json
print(json.load(sys.stdin)['values'].get('_test_theme', '__missing__'))
" 2>/dev/null)
    [ "$MAP_VAL" = "emerald" ] && ok "Map contains _test_theme=emerald" \
        || err "Map missing _test_theme (got $MAP_VAL)"

    check_status "PUT /settings/bulk" 200 \
        -X PUT "$BASE/settings/bulk" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"values":{"_test_theme":"amoled","_test_layout":"classic","_test_lang":"en"}}'

    BULK_VAL=$(curl -s "$BASE/settings/_test_theme" | python -c "
import sys, json
print(json.load(sys.stdin)['value'])
" 2>/dev/null)
    [ "$BULK_VAL" = "amoled" ] && ok "Bulk update _test_theme=amoled" \
        || err "Bulk update: expected amoled, got $BULK_VAL"

    check_status "PUT /settings/_test_null" 201 \
        -X PUT "$BASE/settings/_test_null" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"value":null}'

    NULL_VAL=$(curl -s "$BASE/settings/_test_null" | python -c "
import sys, json
print(json.load(sys.stdin)['value'])
" 2>/dev/null)
    [ "$NULL_VAL" = "None" ] && ok "Null value roundtrips" \
        || err "Null value: expected None, got $NULL_VAL"

    check_status "GET /settings/nonexistent → 404" 404 "$BASE/settings/nonexistent"

    check_status "DELETE /settings/_test_theme → 204" 204 \
        -X DELETE "$BASE/settings/_test_theme" -H "Authorization: Bearer $TOKEN"

    check_status "GET /settings/_test_theme after delete" 404 "$BASE/settings/_test_theme"

    for s in _test_layout _test_lang _test_null; do
        curl -s -o /dev/null -X DELETE "$BASE/settings/$s" -H "Authorization: Bearer $TOKEN"
    done
fi

# ---- Reciters ------------------------------------------------------------
if should_run "reciters"; then
    say "Reciters"

    check_status "GET /reciters" 200 "$BASE/reciters"

    check_json_field "Reciter count = 6" "6" "meta.total" \
        "$BASE/reciters"

    check_status "GET /reciters/mishary-rashid-alafasy/surah/1" 200 \
        "$BASE/reciters/mishary-rashid-alafasy/surah/1"

    AYAH_COUNT=$(curl -s "$BASE/reciters/mishary-rashid-alafasy/surah/1" \
        | python -c "import sys,json; print(len(json.load(sys.stdin).get('ayah_list',[])))" 2>/dev/null)
    if [ "$AYAH_COUNT" = "7" ]; then
        ok "Surah 1 ayah_list has 7 entries"
    else
        err "Surah 1 ayah_list count (expected 7, got $AYAH_COUNT)"
    fi

    check_status "GET /reciters/{slug}/surah/999" 400 \
        "$BASE/reciters/mishary-rashid-alafasy/surah/999"

    check_status "GET /reciters/nonexistent/surah/1" 404 \
        "$BASE/reciters/nonexistent/surah/1"

    check_status "GET /reciters/{slug}/surahs" 200 \
        "$BASE/reciters/mishary-rashid-alafasy/surahs"

    SURAHS_COUNT=$(curl -s "$BASE/reciters/mishary-rashid-alafasy/surahs" \
        | python -c "import sys,json; print(len(json.load(sys.stdin).get('surahs',[])))" 2>/dev/null)
    if [ "$SURAHS_COUNT" = "114" ]; then
        ok "Surahs list has 114 entries"
    else
        err "Surahs list count (expected 114, got $SURAHS_COUNT)"
    fi

    check_json_field "Surah 1 arabic_name" "الفاتحة" "surahs.0.arabic_name" \
        "$BASE/reciters/mishary-rashid-alafasy/surahs"

    check_json_field "Host present" \
        "$(grep '^R2_PUBLIC_BASE_URL=' .env 2>/dev/null | cut -d= -f2- | sed 's:/$::')" \
        "host" \
        "$BASE/reciters/mishary-rashid-alafasy/surah/1"
fi

# ---- Prayer times --------------------------------------------------------
if should_run "prayer"; then
    say "Prayer times"

    check_status "GET /prayer-times/cities" 200 "$BASE/prayer-times/cities"

    CITIES_COUNT=$(curl -s "$BASE/prayer-times/cities" | python -c "
import sys, json
print(len(json.load(sys.stdin)))
" 2>/dev/null)
    [ "$CITIES_COUNT" -ge 40 ] && ok "City catalogue has $CITIES_COUNT entries" \
        || err "City catalogue count (expected >=40, got $CITIES_COUNT)"

    check_status "POST /prayer-times/seed (no auth)" 401 \
        -X POST "$BASE/prayer-times/seed" \
        -H "Content-Type: application/json" \
        -d '{"city":"nadiad","year":2026}'

    SEED_RESP=$(curl -s -X POST "$BASE/prayer-times/seed" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"city":"nadiad","year":2026,"replace":true}')
    SEED_INSERTED=$(echo "$SEED_RESP" | python -c "
import sys, json; print(json.load(sys.stdin).get('inserted', -1))
" 2>/dev/null)
    [ "$SEED_INSERTED" = "365" ] && ok "Seeded 365 days for Nadiad 2026" \
        || err "Seed inserted (expected 365, got $SEED_INSERTED)"

    check_status "POST /prayer-times/seed (unknown city)" 400 \
        -X POST "$BASE/prayer-times/seed" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"city":"zzz-no-such-city","year":2026}'

    check_status "GET /prayer-times?city=nadiad" 200 \
        "$BASE/prayer-times?city=nadiad&limit=400"

    FILTERED=$(curl -s "$BASE/prayer-times?city=nadiad&from=2026-10-20&to=2026-10-20" \
        | python -c "import sys, json; print(json.load(sys.stdin)['meta']['total'])" 2>/dev/null)
    [ "$FILTERED" = "1" ] && ok "Date-range filter returns 1 row for 2026-10-20" \
        || err "Date-range filter (expected 1, got $FILTERED)"

    NADIAD_ROW=$(curl -s "$BASE/prayer-times?city=nadiad&from=2026-10-23&to=2026-10-23" | python -c "
import sys, json
rows = json.load(sys.stdin)['items']
if rows:
    r = rows[0]
    print(f\"{r['fajr_start']}|{r['zuhr_start']}|{r['maghrib_start']}|{r['is_friday']}\")
" 2>/dev/null)

    FAJR_VAL=$(echo "$NADIAD_ROW" | cut -d'|' -f1)
    FRIDAY_FLAG=$(echo "$NADIAD_ROW" | cut -d'|' -f4)
    [ -n "$FAJR_VAL" ] && [ "$FAJR_VAL" != "None" ] \
        && ok "Nadiad 2026-10-23 fajr = $FAJR_VAL" \
        || err "Nadiad fajr missing (got '$FAJR_VAL')"
    [ "$FRIDAY_FLAG" = "True" ] && ok "2026-10-23 correctly flagged as Friday" \
        || err "Friday flag (expected True, got '$FRIDAY_FLAG')"

    ROW_ID=$(curl -s "$BASE/prayer-times?city=nadiad&from=2026-10-23&to=2026-10-23" \
        | python -c "import sys, json; print(json.load(sys.stdin)['items'][0]['id'])" 2>/dev/null)

    check_status "PATCH /prayer-times/$ROW_ID (jummah override)" 200 \
        -X PATCH "$BASE/prayer-times/$ROW_ID" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"zuhr_start":"13:10"}'

    NEW_JUMMAH=$(curl -s "$BASE/prayer-times/$ROW_ID" | python -c "
import sys, json; print(json.load(sys.stdin)['zuhr_start'])
" 2>/dev/null)
    [ "$NEW_JUMMAH" = "13:10" ] && ok "Jummah override saved: $NEW_JUMMAH" \
        || err "Jummah override (expected 13:10, got $NEW_JUMMAH)"

    check_status "DELETE /prayer-times/$ROW_ID" 204 \
        -X DELETE "$BASE/prayer-times/$ROW_ID" -H "Authorization: Bearer $TOKEN"
fi

# ---- Hijri ---------------------------------------------------------------
if should_run "hijri"; then
    say "Hijri"

    check_status "GET /hijri/now (no city)" 422 "$BASE/hijri/now"
    check_status "GET /hijri/now (unknown city)" 404 "$BASE/hijri/now?city=zzz-no-such"
    check_status "GET /hijri/now?city=nadiad" 200 "$BASE/hijri/now?city=nadiad"

    HIJRI_DAY=$(curl -s "$BASE/hijri/now?city=nadiad" \
        | python -c "import sys,json; print(json.load(sys.stdin).get('hijri_day',-1))" 2>/dev/null)
    if [ "$HIJRI_DAY" -ge 1 ] && [ "$HIJRI_DAY" -le 30 ]; then
        ok "Hijri day = $HIJRI_DAY"
    else
        err "Hijri day out of range: $HIJRI_DAY"
    fi

    HIJRI_MONTH=$(curl -s "$BASE/hijri/now?city=nadiad" \
        | python -c "import sys,json; print(json.load(sys.stdin).get('hijri_month_name',''))" 2>/dev/null)
    [ -n "$HIJRI_MONTH" ] && ok "Hijri month name = $HIJRI_MONTH" \
        || err "Hijri month name missing"

    HIJRI_SOURCE=$(curl -s "$BASE/hijri/now?city=nadiad" \
        | python -c "import sys,json; print(json.load(sys.stdin).get('source',''))" 2>/dev/null)
    case "$HIJRI_SOURCE" in
        baseline|confirmed|tentative) ok "Hijri source = $HIJRI_SOURCE" ;;
        *) err "Invalid hijri source: $HIJRI_SOURCE" ;;
    esac

    check_status "POST /hijri/refresh (no auth)" 401 -X POST "$BASE/hijri/refresh"
    check_status "POST /hijri/refresh (authed)" 202 \
        -X POST "$BASE/hijri/refresh" -H "Authorization: Bearer $TOKEN"
fi

# ---- Backup --------------------------------------------------------------
if should_run "backup"; then
    say "Backup API"

    check_status "GET /admin/backup/status (no auth)" 401 "$BASE/admin/backup/status"
    check_status "POST /admin/backup (no auth)" 401 -X POST "$BASE/admin/backup"

    check_status "GET /admin/backup/status (authed)" 200 \
        "$BASE/admin/backup/status" -H "Authorization: Bearer $TOKEN"

    SCHED_ENABLED=$(curl -s "$BASE/admin/backup/status" -H "Authorization: Bearer $TOKEN" \
        | python -c "import sys,json; print(json.load(sys.stdin)['scheduler_enabled'])" 2>/dev/null)
    [ "$SCHED_ENABLED" = "True" ] && ok "Backup scheduler enabled" \
        || err "Backup scheduler disabled (got $SCHED_ENABLED)"

    BACKUP_RESP=$(curl -s -X POST "$BASE/admin/backup" -H "Authorization: Bearer $TOKEN")
    BACKUP_FILE=$(echo "$BACKUP_RESP" | python -c "import sys,json; print(json.load(sys.stdin).get('filename',''))" 2>/dev/null)
    BACKUP_R2=$(echo "$BACKUP_RESP" | python -c "import sys,json; print(json.load(sys.stdin).get('uploaded_to_r2',''))" 2>/dev/null)
    [ -n "$BACKUP_FILE" ] && ok "Manual backup created: $BACKUP_FILE" \
        || err "Manual backup failed: $BACKUP_RESP"
    [ "$BACKUP_R2" = "True" ] && ok "Backup uploaded to R2" \
        || err "Backup R2 upload failed (uploaded_to_r2=$BACKUP_R2)"

    BACKUP_COUNT=$(curl -s "$BASE/admin/backup" -H "Authorization: Bearer $TOKEN" \
        | python -c "import sys,json; print(json.load(sys.stdin)['count'])" 2>/dev/null)
    [ "$BACKUP_COUNT" -ge 1 ] && ok "Backup list has $BACKUP_COUNT entries" \
        || err "Backup list empty"

    VERIFY_RESP=$(curl -s -X POST "$BASE/admin/backup/verify" -H "Authorization: Bearer $TOKEN")
    VERIFY_STATUS=$(echo "$VERIFY_RESP" | python -c "import sys,json; print(json.load(sys.stdin).get('status',''))" 2>/dev/null)
    if [ "$VERIFY_STATUS" = "ok" ]; then
        ok "Backup verify: ok"
    else
        VERIFY_OUT=$(echo "$VERIFY_RESP" | python -c "
import sys, json
out = json.load(sys.stdin).get('output', '')
print(' | '.join(out.strip().splitlines()[-5:])[:400])
" 2>/dev/null)
        err "Backup verify failed: $VERIFY_STATUS — $VERIFY_OUT"
    fi
fi

# ---- Mosques API ---------------------------------------------------------
if should_run "mosques"; then
    say "Mosques API"

    check_status "GET /mosques/nearby (valid coords)" 200 \
        "$BASE/mosques/nearby?lat=22.689772&lon=72.855056&radius_m=2000"

    check_status "GET /mosques/nearby (bad lat)" 422 \
        "$BASE/mosques/nearby?lat=999&lon=72.855056"

    check_status "GET /mosques/nearby (bad lon)" 422 \
        "$BASE/mosques/nearby?lat=22.689772&lon=999"

    check_status "GET /mosques/nearby (missing lat)" 422 \
        "$BASE/mosques/nearby?lon=72.855056"

    check_status "GET /mosques/nearby (missing lon)" 422 \
        "$BASE/mosques/nearby?lat=22.689772"

    MOSQUE_RESP=$(curl -s "$BASE/mosques/nearby?lat=22.689772&lon=72.855056&radius_m=2000")

    MOSQUE_SOURCE=$(echo "$MOSQUE_RESP" | python -c "
import sys, json
try:
    print(json.load(sys.stdin).get('source', '__missing__'))
except Exception:
    print('__invalid__')
" 2>/dev/null)

    case "$MOSQUE_SOURCE" in
        google|time.now) ok "Mosque source = $MOSQUE_SOURCE" ;;
        *) err "Mosque source (expected google or time.now, got '$MOSQUE_SOURCE')" ;;
    esac

    MOSQUE_COUNT=$(echo "$MOSQUE_RESP" | python -c "
import sys, json
try:
    print(json.load(sys.stdin).get('count', -1))
except Exception:
    print(-1)
" 2>/dev/null)

    if [ "$MOSQUE_COUNT" -ge 0 ]; then
        ok "Mosque count = $MOSQUE_COUNT"
    else
        err "Mosque count (got '$MOSQUE_COUNT')"
    fi

    MOSQUE_SHAPE=$(echo "$MOSQUE_RESP" | python -c "
import sys, json
try:
    d = json.load(sys.stdin)
    ms = d.get('mosques', [])
    if not ms:
        print('__empty__')
    else:
        m = ms[0]
        required = {'name', 'address', 'google_maps_url', 'source'}
        missing = required - set(m.keys())
        print('missing:' + ','.join(missing) if missing else 'ok')
except Exception as e:
    print('__error__:' + str(e))
" 2>/dev/null)

    if [ "$MOSQUE_SHAPE" = "ok" ]; then
        ok "Mosque object shape valid (name, address, google_maps_url, source)"
    elif [ "$MOSQUE_SHAPE" = "__empty__" ]; then
        err "Mosque object shape — empty result (no mosques nearby)"
    else
        err "Mosque object shape invalid: $MOSQUE_SHAPE"
    fi

    MOSQUE_LINK=$(echo "$MOSQUE_RESP" | python -c "
import sys, json
try:
    d = json.load(sys.stdin)
    ms = d.get('mosques', [])
    if not ms:
        print('__empty__')
    else:
        url = ms[0].get('google_maps_url', '')
        print('ok' if url.startswith('https://www.google.com/maps/') else 'bad:' + url[:60])
except Exception:
    print('__error__')
" 2>/dev/null)

    case "$MOSQUE_LINK" in
        ok) ok "google_maps_url is a valid Google Maps link" ;;
        __empty__) err "google_maps_url check — no mosques to test" ;;
        *) err "google_maps_url invalid: $MOSQUE_LINK" ;;
    esac
fi


if should_run "devices"; then
    say "Device registration"

    UUID_A="test-device-$(date +%s)-a"
    UUID_B="test-device-$(date +%s)-b"

    check_status "POST /auth/device/register (missing uuid)" 422 \
        -X POST "$BASE/auth/device/register" \
        -H "Content-Type: application/json" \
        -d '{"platform":"ios"}'

    check_status "POST /auth/device/register (short uuid)" 422 \
        -X POST "$BASE/auth/device/register" \
        -H "Content-Type: application/json" \
        -d '{"device_uuid":"abc"}'

    # First-time register
    RESP_A=$(curl -s -X POST "$BASE/auth/device/register" \
        -H "Content-Type: application/json" \
        -d "{\"device_uuid\":\"$UUID_A\",\"platform\":\"ios\",\"device_model\":\"iPhone15\",\"os_version\":\"17.4\"}")
    TOKEN_A=$(echo "$RESP_A" | python -c "import sys,json; print(json.load(sys.stdin).get('access_token',''))" 2>/dev/null)
    NEW_A=$(echo "$RESP_A" | python -c "import sys,json; print(json.load(sys.stdin).get('is_new_user',''))" 2>/dev/null)
    USER_A=$(echo "$RESP_A" | python -c "import sys,json; print(json.load(sys.stdin).get('user_id',''))" 2>/dev/null)

    [ -n "$TOKEN_A" ] && ok "First register → token issued (${#TOKEN_A} chars, user_id=$USER_A)" \
        || err "First register failed: $RESP_A"
    [ "$NEW_A" = "True" ] && ok "First register → is_new_user=True" \
        || err "First register → expected is_new_user=True, got $NEW_A"

    check_status "GET /auth/me (device token)" 200 \
        "$BASE/auth/me" -H "Authorization: Bearer $TOKEN_A"

    check_status "GET /auth/me (device token, admin-only route)" 403 \
        -X DELETE "$BASE/duas/999999" -H "Authorization: Bearer $TOKEN_A"

    # Security: token from device A must NOT be able to claim a fresh UUID B
    check_status "Register uuid_b with token_a → 403" 403 \
        -X POST "$BASE/auth/device/register" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN_A" \
        -d "{\"device_uuid\":\"$UUID_B\"}"

    # Legitimate: new UUID, no token → new user
    RESP_B=$(curl -s -X POST "$BASE/auth/device/register" \
        -H "Content-Type: application/json" \
        -d "{\"device_uuid\":\"$UUID_B\",\"platform\":\"android\"}")
    USER_B=$(echo "$RESP_B" | python -c "import sys,json; print(json.load(sys.stdin).get('user_id',''))" 2>/dev/null)
    [ -n "$USER_B" ] && [ "$USER_B" != "$USER_A" ] \
        && ok "New uuid, no token → new user ($USER_B vs $USER_A)" \
        || err "New uuid, no token → expected new user, got $USER_B"

    # Security: existing UUID without token → 401
    check_status "Register existing uuid without token → 401" 401 \
        -X POST "$BASE/auth/device/register" \
        -H "Content-Type: application/json" \
        -d "{\"device_uuid\":\"$UUID_A\"}"

    # Resume with token → same user
    RESP_A2=$(curl -s -X POST "$BASE/auth/device/register" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN_A" \
        -d "{\"device_uuid\":\"$UUID_A\"}")
    NEW_A2=$(echo "$RESP_A2" | python -c "import sys,json; print(json.load(sys.stdin).get('is_new_user',''))" 2>/dev/null)
    USER_A2=$(echo "$RESP_A2" | python -c "import sys,json; print(json.load(sys.stdin).get('user_id',''))" 2>/dev/null)
    [ "$NEW_A2" = "False" ] && ok "Resume (same uuid + token) → is_new_user=False" \
        || err "Resume → expected is_new_user=False, got $NEW_A2"
    [ "$USER_A2" = "$USER_A" ] && ok "Resume → same user_id ($USER_A)" \
        || err "Resume → expected user_id=$USER_A, got $USER_A2"

    # Admin device management
    if [ -n "$TOKEN" ]; then
        check_status "GET /administrators/$USER_A/devices (authed)" 200 \
            "$BASE/administrators/$USER_A/devices" -H "Authorization: Bearer $TOKEN"

        COUNT_A=$(curl -s "$BASE/administrators/$USER_A/devices" -H "Authorization: Bearer $TOKEN" \
            | python -c "import sys,json; d=json.load(sys.stdin); print(len(d))" 2>/dev/null)
        [ "$COUNT_A" = "1" ] && ok "User A has 1 device" \
            || err "User A devices count (expected 1, got $COUNT_A)"

        check_status "POST revoke device A" 204 \
            -X POST "$BASE/administrators/$USER_A/devices/$UUID_A/revoke" \
            -H "Authorization: Bearer $TOKEN"

        check_status "Register revoked uuid → 403" 403 \
            -X POST "$BASE/auth/device/register" \
            -H "Content-Type: application/json" \
            -d "{\"device_uuid\":\"$UUID_A\"}"
    else
        err "Skipped admin device tests — no TOKEN"
    fi
fi


if should_run "dhikr"; then
    say "Dhikr campaigns & submissions"

    # Register a fresh guest device for this test run (independent of "devices" group)
    DHIKR_UUID="dhikr-test-$(date +%s)-$RANDOM"
    DHIKR_RESP=$(curl -s -X POST "$BASE/auth/device/register" \
        -H "Content-Type: application/json" \
        -d "{\"device_uuid\":\"$DHIKR_UUID\",\"platform\":\"ios\"}")
    TOKEN_A=$(echo "$DHIKR_RESP" | python -c "import sys,json; print(json.load(sys.stdin).get('access_token',''))" 2>/dev/null)

    [ -n "$TOKEN_A" ] && ok "Guest device registered for dhikr tests" \
        || err "Could not register guest device: $DHIKR_RESP"

    # Config API (public)
    check_status "GET /dhikr/config (public)" 200 "$BASE/dhikr/config"

    IS_OPEN=$(curl -s "$BASE/dhikr/config" | python -c "import sys,json; print(json.load(sys.stdin).get('is_open'))")
    ok "Config is_open = $IS_OPEN"

    # Create campaign (admin)
    SLUG="test-dhikr-$(date +%s)-$RANDOM"
    TODAY=$(date +%Y-%m-%d)
    FUTURE=$(date -d "+7 days" +%Y-%m-%d 2>/dev/null || date -v+7d +%Y-%m-%d)

    CAMP_RESP=$(curl -s -X POST "$BASE/admin/dhikr/campaigns" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"title\":\"Test Dhikr\",\"slug\":\"$SLUG\",\"starts_on\":\"$TODAY\",\"ends_on\":\"$FUTURE\"}")
    CAMP_ID=$(echo "$CAMP_RESP" | python -c "import sys,json; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
    [ -n "$CAMP_ID" ] && ok "Created campaign id=$CAMP_ID" || err "Campaign create failed: $CAMP_RESP"

    # Duplicate slug
    check_status "POST campaign (duplicate slug)" 409 \
        -X POST "$BASE/admin/dhikr/campaigns" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"title\":\"Dup\",\"slug\":\"$SLUG\",\"starts_on\":\"$TODAY\",\"ends_on\":\"$FUTURE\"}"

    # Submit before activation → 400
    check_status "POST /dhikr/submit (campaign inactive)" 400 \
        -X POST "$BASE/dhikr/submit" \
        -H "Authorization: Bearer $TOKEN_A" \
        -H "Content-Type: application/json" \
        -d "{\"campaign_id\":$CAMP_ID,\"count\":100}"

    # Activate
    check_status "POST toggle campaign → active" 200 \
        -X POST "$BASE/admin/dhikr/campaigns/$CAMP_ID/toggle" \
        -H "Authorization: Bearer $TOKEN"

    # Config now shows it as active
    ACTIVE_ID=$(curl -s "$BASE/dhikr/config" | python -c "
import sys,json
d=json.load(sys.stdin)
print(d.get('active',{}).get('id') if d.get('active') else '')
" 2>/dev/null)
    [ "$ACTIVE_ID" = "$CAMP_ID" ] && ok "Config reflects active campaign ($ACTIVE_ID)" \
        || err "Config active (expected $CAMP_ID, got '$ACTIVE_ID')"

    # Submit now works
    check_status "POST /dhikr/submit (no auth)" 401 \
        -X POST "$BASE/dhikr/submit" \
        -H "Content-Type: application/json" \
        -d "{\"campaign_id\":$CAMP_ID,\"count\":100}"

    SUB_RESP=$(curl -s -X POST "$BASE/dhikr/submit" \
        -H "Authorization: Bearer $TOKEN_A" \
        -H "Content-Type: application/json" \
        -d "{\"campaign_id\":$CAMP_ID,\"count\":100,\"full_name\":\"Test User\",\"phone\":\"+911234567890\"}")
    SUB_ID=$(echo "$SUB_RESP" | python -c "import sys,json; print(json.load(sys.stdin).get('submission_id',''))" 2>/dev/null)
    [ -n "$SUB_ID" ] && ok "Submitted dhikr id=$SUB_ID" || err "Submit failed: $SUB_RESP"

    # Unknown campaign → 400
    check_status "POST /dhikr/submit (unknown campaign)" 400 \
        -X POST "$BASE/dhikr/submit" \
        -H "Authorization: Bearer $TOKEN_A" \
        -H "Content-Type: application/json" \
        -d '{"campaign_id":999999,"count":10}'

    # Admin lists submissions
    check_status "GET /admin/dhikr/campaigns/$CAMP_ID/submissions" 200 \
        "$BASE/admin/dhikr/campaigns/$CAMP_ID/submissions" \
        -H "Authorization: Bearer $TOKEN"

    SUB_COUNT=$(curl -s "$BASE/admin/dhikr/campaigns/$CAMP_ID/submissions" \
        -H "Authorization: Bearer $TOKEN" \
        | python -c "import sys,json; print(json.load(sys.stdin).get('total',-1))" 2>/dev/null)
    [ "$SUB_COUNT" = "1" ] && ok "Admin sees 1 submission" || err "Submission count (expected 1, got $SUB_COUNT)"

    # Stats
    STATS=$(curl -s "$BASE/admin/dhikr/campaigns/$CAMP_ID/stats" \
        -H "Authorization: Bearer $TOKEN")
    STATS_TOTAL=$(echo "$STATS" | python -c "import sys,json; print(json.load(sys.stdin).get('total_dhikrs',-1))" 2>/dev/null)
    [ "$STATS_TOTAL" = "100" ] && ok "Stats total_dhikrs = 100" || err "Stats total (expected 100, got $STATS_TOTAL)"

    # Mark handled
    check_status "PATCH submission handled" 200 \
        -X PATCH "$BASE/admin/dhikr/submissions/$SUB_ID" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"status":"handled","admin_note":"Verified"}'

    # Deactivate and verify config flips
    check_status "POST toggle campaign → inactive" 200 \
        -X POST "$BASE/admin/dhikr/campaigns/$CAMP_ID/toggle" \
        -H "Authorization: Bearer $TOKEN"

    NEW_OPEN=$(curl -s "$BASE/dhikr/config" | python -c "import sys,json; print(json.load(sys.stdin).get('is_open'))")
    [ "$NEW_OPEN" = "False" ] && ok "Config is_open=False after toggle" \
        || err "Config is_open (expected False, got $NEW_OPEN)"

    # Cleanup: cannot delete campaign with submissions
    check_status "DELETE campaign with submissions → 409" 409 \
        -X DELETE "$BASE/admin/dhikr/campaigns/$CAMP_ID" \
        -H "Authorization: Bearer $TOKEN"
fi


# =========================================================================== #
#  Summary
# =========================================================================== #
echo ""
echo "════════════════════════════════════════════════════════════"
if [ "$FAIL_COUNT" -eq 0 ]; then
    echo -e "  \033[0;32m✅ All $PASS_COUNT tests passed\033[0m"
else
    echo -e "  \033[0;31m❌ $FAIL_COUNT failed, $PASS_COUNT passed\033[0m"
fi
echo "════════════════════════════════════════════════════════════"
[ "$FAIL_COUNT" -eq 0 ]