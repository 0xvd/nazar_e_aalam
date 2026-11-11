/* Nazar-e-Aalam — admin panel (production, API-driven). */
"use strict";

// ============================================================================
// Auth guard — must be first
// ============================================================================
if (!api.isAuthenticated()) {
  api.redirectLogin();
  throw new Error("REDIRECT");
}

// ============================================================================
// Helpers
// ============================================================================
const $ = (s, r = document) => r.querySelector(s);
const $$ = (s, r = document) => [...r.querySelectorAll(s)];
const esc = (s) =>
  String(s ?? "").replace(
    /[&<>"']/g,
    (c) =>
      ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[
        c
      ],
  );
const pad = (n) => String(n).padStart(2, "0");
const cap = (s) =>
  String(s || "")
    .charAt(0)
    .toUpperCase() + String(s || "").slice(1);
const toast = api.toast;

function fmtDuration(totalSec) {
  const h = Math.floor(totalSec / 3600);
  const m = Math.floor((totalSec % 3600) / 60);
  const s = Math.floor(totalSec % 60);
  return `${pad(h)}:${pad(m)}:${pad(s)}`;
}
// ---- 12/24-hour display preference --------------------------------
const TIME_FMT_KEY = "nea:time_fmt_v1"; // "12" | "24"
let _timeFmt = "12"; // default 12-hour

function _loadTimeFmt() {
  try {
    const v = localStorage.getItem(TIME_FMT_KEY);
    if (v === "12" || v === "24") return v;
  } catch {}
  return "12";
}
function _saveTimeFmt(v) {
  try {
    localStorage.setItem(TIME_FMT_KEY, v);
  } catch {}
}
function getTimeFmt() {
  return _timeFmt;
}
function setTimeFmt(v) {
  if (v !== "12" && v !== "24") return;
  _timeFmt = v;
  _saveTimeFmt(v);
}

// Format HH:MM (24h input) → display string honoring current preference
// Returns { text, suffix } — suffix is "" for 24h, "AM"/"PM" for 12h
function fmtTimeParts(hhmm) {
  if (!hhmm) return { text: "—", suffix: "" };
  const m = String(hhmm).match(/^(\d{1,2}):(\d{2})/);
  if (!m) return { text: String(hhmm), suffix: "" };
  let h = parseInt(m[1], 10);
  const min = m[2];
  if (_timeFmt === "24") {
    return { text: `${pad(h)}:${min}`, suffix: "" };
  }
  const suffix = h >= 12 ? "PM" : "AM";
  h = h % 12 || 12;
  return { text: `${h}:${min}`, suffix };
}

// HTML-safe version with muted AM/PM badge
function fmtTimeHtml(hhmm) {
  if (!hhmm) return "—";
  const { text, suffix } = fmtTimeParts(hhmm);
  if (!suffix) return esc(text);
  return `${esc(text)}<span class="ampm">${suffix}</span>`;
}

// Plain text version (for titles, toasts)
function fmtTimeText(hhmm) {
  if (!hhmm) return "—";
  const { text, suffix } = fmtTimeParts(hhmm);
  return suffix ? `${text} ${suffix}` : text;
}

// ---- 12-hour time formatting helpers -------------------------------
function to12h(hhmm) {
  if (!hhmm) return hhmm;
  const m = String(hhmm).match(/^(\d{1,2}):(\d{2})/);
  if (!m) return hhmm;
  let h = parseInt(m[1], 10);
  const min = m[2];
  const suffix = h >= 12 ? "PM" : "AM";
  h = h % 12;
  if (h === 0) h = 12;
  return `${h}:${min}`;
}

function fmtTime12(hhmm) {
  // Preference-aware: delegates to fmtTimeHtml which respects _timeFmt
  return fmtTimeHtml(hhmm);
}

// Convert HH:MM to 12h + AM/PM suffix (for plain text / titles)
function hhmmTo12Parts(hhmm) {
  if (!hhmm) return { time: "—", suffix: "" };
  const m = String(hhmm).match(/^(\d{1,2}):(\d{2})/);
  if (!m) return { time: esc(hhmm), suffix: "" };
  let h = parseInt(m[1], 10);
  const suffix = h >= 12 ? "PM" : "AM";
  h = h % 12 || 12;
  return { time: `${h}:${m[2]}`, suffix };
}

async function apiCall(promise, { success = null, errorPrefix = "" } = {}) {
  try {
    const r = await promise;
    if (success) toast(success);
    return r;
  } catch (e) {
    toast(
      (errorPrefix ? errorPrefix + ": " : "") + (e.message || "Request failed"),
      true,
    );
    throw e;
  }
}

// ============================================================================
// Icons
// ============================================================================
const ICONS = {
  dash: '<rect x="3" y="3" width="7" height="9" rx="2"/><rect x="14" y="3" width="7" height="5" rx="2"/><rect x="14" y="12" width="7" height="9" rx="2"/><rect x="3" y="16" width="7" height="5" rx="2"/>',
  shield: '<path d="M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6z"/>',
  user: '<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/>',
  users:
    '<circle cx="9" cy="8" r="3.5"/><path d="M2 21c0-3.5 3-5.5 7-5.5s7 2 7 5.5"/><path d="M17 4.5a3.5 3.5 0 010 7"/><path d="M22 21c0-2.5-1.5-4.2-4-5"/>',
  lock: '<rect x="4" y="10" width="16" height="11" rx="2"/><path d="M8 10V7a4 4 0 018 0v3"/>',
  key: '<circle cx="8" cy="12" r="4"/><path d="M12 12h8l2 2-2 2-2-2-2 2"/>',
  logout:
    '<path d="M9 4H5v16h4"/><path d="M16 8l4 4-4 4"/><path d="M20 12H9"/>',
  clock: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
  head: '<path d="M4 15v-3a8 8 0 0116 0v3"/><path d="M3 14h4v6H3zM17 14h4v6h-4z"/>',
  heart:
    '<path d="M12 21s-8-5-8-11a4.5 4.5 0 018-2.5A4.5 4.5 0 0120 10c0 6-8 11-8 11z"/>',
  beads:
    '<circle cx="6" cy="9" r="2"/><circle cx="12" cy="5" r="2"/><circle cx="18" cy="9" r="2"/><circle cx="18" cy="16" r="2"/><circle cx="12" cy="20" r="2"/><circle cx="6" cy="16" r="2"/>',
  img: '<rect x="3" y="4" width="18" height="16" rx="3"/><circle cx="9" cy="10" r="1.5"/><path d="M21 16l-5-5-9 9"/>',
  camera: '<path d="M4 7h3l2-3h6l2 3h3v13H4z"/><circle cx="12" cy="13" r="4"/>',
  star: '<path d="M12 2l2.5 4.5 5-1.5-1.5 5 4.5 2-4.5 2 1.5 5-5-1.5L12 22l-2.5-4.5-5 1.5 1.5-5-4.5-2 4.5-2-1.5-5 5 1.5z"/>',
  globe:
    '<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c3 3 3 15 0 18M12 3c-3 3-3 15 0 18"/>',
  set: '<path d="M4 6h9M17 6h3M4 12h3M11 12h9M4 18h11M19 18h1"/><circle cx="15" cy="6" r="2"/><circle cx="9" cy="12" r="2"/><circle cx="17" cy="18" r="2"/>',
  book: '<path d="M5 4h14v16H7a2 2 0 01-2-2z"/><path d="M9 8h6"/>',
  folder:
    '<path d="M3 7a2 2 0 012-2h4l2 2h8a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2z"/>',
  search: '<circle cx="11" cy="11" r="7"/><path d="M20 20l-4-4"/>',
  plus: '<path d="M12 5v14M5 12h14"/>',
  check: '<path d="M5 12l5 5 9-10"/>',
  edit: '<path d="M4 20h4L19 9l-4-4L4 16z"/>',
  trash: '<path d="M4 7h16M10 11v6M14 11v6M6 7l1 13h10l1-13M9 7V4h6v3"/>',
  play: '<path d="M8 5l11 7-11 7z"/>',
  pause: '<path d="M8 5v14M16 5v14"/>',
  upload: '<path d="M12 16V4M7 9l5-5 5 5M4 20h16"/>',
  down: '<path d="M12 4v12M7 11l5 5 5-5M4 20h16"/>',
  x: '<path d="M6 6l12 12M18 6L6 18"/>',
  refresh:
    '<path d="M4 4v6h6M20 20v-6h-6"/><path d="M20 10a8 8 0 10-8 8 8 8 0 006-3"/>',
  menu: '<path d="M4 7h16M4 12h16M4 17h16"/>',
  bell: '<path d="M18 16H6l1.5-2V9a4.5 4.5 0 019 0v5L18 16z"/><path d="M10 19a2 2 0 004 0"/>',
  mobile:
    '<rect x="6" y="2" width="12" height="20" rx="2"/><path d="M10 18h4"/>',
  roles:
    '<circle cx="9" cy="7" r="3"/><path d="M2 21v-2a5 5 0 0110 0v2"/><circle cx="17" cy="9" r="2.2"/><path d="M14 21v-1.5a4 4 0 017.5-1.5"/>',
};

const ic = (n) => {
  const path = ICONS[n];
  if (!path) {
    if (typeof console !== "undefined") console.warn("[ic] missing icon:", n);
    return "";
  }
  return `<svg class="i" viewBox="0 0 24 24" aria-hidden="true">${path}</svg>`;
};

// ============================================================================
// Modal + form + confirm
// ============================================================================
let modalCtx = null;
let lastFocus = null;
const modalOpen = () => $("#modal").classList.contains("on");

function openModal(html, small = false) {
  lastFocus = document.activeElement;
  const m = $("#modal");
  m.innerHTML = `<div class="mb glass${small ? " sm" : ""}" role="dialog" aria-modal="true" aria-labelledby="mt">${html}</div>`;
  m.classList.add("on");
  m.setAttribute("aria-hidden", "false");
  document.body.classList.add("noscroll");
  setTimeout(() => {
    const f = m.querySelector(
      "input:not([type=hidden]):not([type=file]),textarea,select,.btn",
    );
    if (f) f.focus();
  }, 30);
}

function closeModal() {
  const m = $("#modal");
  m.classList.remove("on");
  m.innerHTML = "";
  m.setAttribute("aria-hidden", "true");
  document.body.classList.remove("noscroll");
  modalCtx = null;
  if (lastFocus && lastFocus.focus && document.contains(lastFocus))
    lastFocus.focus();
}

function confirmBox({ title, msg, ok = "Delete", onOk }) {
  openModal(
    `<div class="mh"><h3 id="mt">${esc(title)}</h3>
            <button type="button" class="x" data-act="close" aria-label="Close">${ic("x")}</button></div>
         <p class="msg">${esc(msg)}</p>
         <div class="mfoot">
            <button type="button" class="b3" data-act="close">Cancel</button>
            <button type="button" class="btn danger" data-act="confirm">${esc(ok)}</button>
         </div>`,
    true,
  );
  modalCtx = { onOk };
}

function fieldHtml(f, v) {
  const id = "f_" + f.k;
  const val = v ?? f.def ?? "";
  const rtl = f.ar ? ' dir="rtl"' : "";
  const cls = "in" + (f.ar ? " ar" : "");
  let inp;
  if (f.t === "area")
    inp = `<textarea class="${cls}" id="${id}" name="${f.k}" rows="${f.rows || 3}"${rtl}>${esc(val)}</textarea>`;
  else if (f.t === "select")
    inp = `<select class="${cls}" id="${id}" name="${f.k}">${f.o.map((o) => `<option${o === val ? " selected" : ""}>${esc(o)}</option>`).join("")}</select>`;
  else
    inp = `<input class="${cls}" id="${id}" name="${f.k}" type="${f.t || "text"}" value="${esc(val)}"${rtl}${f.min != null ? ` min="${f.min}"` : ""}${f.max != null ? ` max="${f.max}"` : ""}${f.t === "number" ? ' step="1"' : ""} autocomplete="off">`;
  return `<div class="${f.full ? "full" : ""}">
        <label for="${id}">${esc(f.l)}${f.req ? '<span class="rq" aria-hidden="true">*</span>' : ""}</label>
        ${inp}
        ${f.h ? `<div class="hint">${esc(f.h)}</div>` : ""}
    </div>`;
}

function formModal({ title, fields, data = {}, okLabel = "Save", onSubmit }) {
  openModal(
    `<form id="mform" novalidate>
            <div class="mh"><h3 id="mt">${esc(title)}</h3>
                <button type="button" class="x" data-act="close" aria-label="Close">${ic("x")}</button></div>
            <div class="mf">${fields.map((f) => fieldHtml(f, data[f.k])).join("")}</div>
            <div class="err" id="merr" role="alert"></div>
            <div class="mfoot">
                <button type="button" class="b3" data-act="close">Cancel</button>
                <button class="btn" type="submit"><span class="bt">${esc(okLabel)}</span><span class="sp2"></span></button>
            </div>
         </form>`,
  );
  $("#mform").onsubmit = async (e) => {
    e.preventDefault();
    const form = e.target;
    const btn = $(".btn", form);
    const vals = {};
    let bad = null;
    $$(".in", form).forEach((i) => i.removeAttribute("aria-invalid"));

    for (const f of fields) {
      const el = form.querySelector(`[name="${f.k}"]`);
      if (!el) continue;
      let v = String(el.value).trim();
      const fail = (msg) => {
        if (!bad) bad = { el, msg };
      };

      if (f.req && !v) {
        fail(`${f.l} is required.`);
        continue;
      }
      if (v && f.t === "email" && !/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(v))
        fail("Enter a valid email address.");
      if (f.t === "number") {
        if (!v && f.def != null) v = f.def;
        else if (!v) v = null;
        else {
          const n = Number(v);
          if (!Number.isInteger(n)) fail(`${f.l} must be a whole number.`);
          else if (f.min != null && n < f.min)
            fail(`${f.l} must be ≥ ${f.min}.`);
          else if (f.max != null && n > f.max)
            fail(`${f.l} must be ≤ ${f.max}.`);
          else v = n;
        }
      }
      vals[f.k] = v === "" ? null : v;
    }

    const show = (el, msg) => {
      if (el) el.setAttribute("aria-invalid", "true");
      $("#merr").textContent = msg;
      if (el) el.focus();
    };
    if (bad) return show(bad.el, bad.msg);

    $("#merr").textContent = "";
    btn.classList.add("load");
    btn.disabled = true;
    try {
      const err = await onSubmit(vals);
      if (err) show(null, err);
      else closeModal();
    } catch (err) {
      show(null, err.message || "Request failed");
    } finally {
      btn.classList.remove("load");
      btn.disabled = false;
    }
  };
}

// ============================================================================
// Navigation
// ============================================================================
const NAV = [
  ["Dashboard", "dash"],
  ["Administrators", "shield"],
  ["Roles", "roles"], // ← ADD
  ["Invitations", "key"],
  ["Prayer Times", "clock"],
  ["Reciters", "head"],
  ["Duas", "heart"],
  ["Dhikrs", "beads"],
  ["Wallpapers", "img"],
  ["Sifat Names", "star"],
  ["Haram Codes", "book"],
  // ["Translators", "globe"],
  ["Uploads", "upload"],
  ["Backup", "down"],
  ["Sync", "refresh"], // ← new
  ["Dhikr Campaigns", "check"], // ← new
  ["Devices", "mobile"], // ← new
  // ["Location", "globe"], // ← new
  ["Settings", "set"],
];

const state = {
  page: "Dashboard",
  user: api.user,
  settings: null,
  cities: null,
  tick: null, // dashboard countdown interval
  prayerTimes: null, // today's times for the dashboard city
  prayerCity: null, // dashboard city selection
  prayerCityList: null, // city catalogue (cached)
  previewAudio: null,
  previewSlug: null,
  roles: null,
  reciterSlug: null, // ← new: when set, Reciters page shows detail
  surahPlayer: null, // ← new: { slug, surah, host, ayahList, index, audio }
  detected: null, // { lat, lon, city, state, country, source, cached }
  _detectedToastShown: false,
};

// ============================================================================
// Permissions
// ============================================================================
// `api.user` is only {id,email,first_name,last_name,is_admin}. Permissions
// live on the roles. Refresh them from GET /me (extended) or GET /roles
// + resolve the current user's role_ids.
async function currentPermissions() {
  if (state._permissions) return state._permissions;
  try {
    // /me returns roles with permissions in our new backend
    const me = await api.get("/me");
    const perms = new Set();
    (me.roles || []).forEach((r) => {
      (r.permissions || []).forEach((p) => perms.add(p));
    });
    state._permissions = perms;
  } catch {
    state._permissions = new Set();
  }
  return state._permissions;
}

function can(perm) {
  if (!state._permissions) return true; // not yet loaded → don't hide anything
  return state._permissions.has(perm);
}

async function refreshPermissions() {
  state._permissions = null;
  await currentPermissions();
}

async function ensureRoles() {
  if (state.roles) return state.roles;
  const cached = api.cache.get("roles", 5 * 60_000);
  if (cached) {
    state.roles = cached;
    return cached;
  }
  try {
    state.roles = await api.get("/roles");
    api.cache.set("roles", state.roles);
  } catch {
    state.roles = [];
  }
  return state.roles;
}

async function ensureSettings(force = false) {
  if (state.settings && !force) return state.settings;
  if (!force) {
    const cached = api.cache.get("settings", 5 * 60_000);
    if (cached) {
      state.settings = cached;
      return cached;
    }
  }
  try {
    const r = await api.get("/settings/map?context=app");
    state.settings = r.values || {};
    api.cache.set("settings", state.settings);
  } catch {
    state.settings = state.settings || {};
  }
  return state.settings;
}

async function ensureCities(force = false) {
  if (state.cities && !force) return state.cities;
  if (!force) {
    const cached = api.cache.get("cities", 60 * 60_000);
    if (cached) {
      state.cities = cached;
      return cached;
    }
  }
  try {
    state.cities = await api.get("/prayer-times/cities");
    api.cache.set("cities", state.cities);
  } catch {
    state.cities = state.cities || [];
  }
  return state.cities;
}

async function ensurePrayerCities() {
  if (state.prayerCityList) return state.prayerCityList;
  try {
    state.prayerCityList = await api.get("/prayer-times/cities");
  } catch {
    state.prayerCityList = [];
  }
  return state.prayerCityList;
}

function permissionFor(key) {
  return (
    {
      Duas: "duas",
      Dhikrs: "dhikrs",
      "Sifat Names": "sifat",
      "Haram Codes": "haram-codes",
      // Translators: "translators",
      Administrators: "administrators",
    }[key] || key.toLowerCase().replace(/\s+/g, "-")
  );
}

// ============================================================================
// Shell
// ============================================================================
function renderNav() {
  const NAV_PERM = {
    Dashboard: null,
    Administrators: "administrators:read",
    Roles: "roles:read", // ← ADD
    Invitations: "invitations:read",
    "Prayer Times": "prayer-times:read",
    Reciters: "reciters:read",
    Duas: "duas:read",
    Dhikrs: "dhikrs:read",
    Wallpapers: "wallpapers:read",
    "Sifat Names": "sifat:read",
    "Haram Codes": "haram-codes:read",
    // Translators: "translators:read",
    Uploads: "uploads:read",
    Backup: "backup:read",
    Sync: "sync:read",
    "Dhikr Campaigns": "dhikr-campaigns:read",
    Devices: "devices:read",
    Settings: "settings:read",
  };
  $("#nav").innerHTML = NAV.filter(([n]) => {
    const p = NAV_PERM[n];
    return !p || can(p);
  })
    .map(
      ([n, i], k) => `<a href="#${encodeURIComponent(n)}" style="--i:${k}"
            class="${n === state.page ? "act" : ""}"
            ${n === state.page ? 'aria-current="page"' : ""}
            data-act="go" data-p="${esc(n)}">${ic(i)}${esc(n)}</a>`,
    )
    .join("");
}

function applyUserHeader() {
  const u = state.me || state.user;
  if (!u) return;
  const full = [u.first_name, u.last_name].filter(Boolean).join(" ").trim();
  const name = full || (u.email || "admin").split("@")[0];
  $("#un").textContent = name;

  const ini = $("#ini");
  if (u.avatar) {
    ini.innerHTML = `<img src="${esc(u.avatar)}" alt="">`;
  } else {
    const initials =
      name
        .trim()
        .split(/\s+/)
        .map((w) => w[0])
        .slice(0, 2)
        .join("")
        .toUpperCase() || "A";
    ini.textContent = initials;
  }
}

function applyBrand() {
  const s = state.settings || {};
  $("#brandName").textContent = s.company || "Nazar-e-Aalam";
  const img = $("#brandImg");
  if (img) img.src = s.logo || "assets/img/logo.png";
}

function menuIsOpen() {
  const mobile = matchMedia("(max-width: 900px)").matches;
  return document.body.classList.contains(mobile ? "open" : "rail");
}

function setMenu(on) {
  const mobile = matchMedia("(max-width: 900px)").matches;
  const cls = mobile ? "open" : "rail";
  document.body.classList.toggle(cls, on);

  // Remember the collapsed state on desktop only
  if (!mobile) {
    try {
      localStorage.setItem("nea:rail", on ? "1" : "0");
    } catch {}
  }

  const b = $('[data-act="menu"].chip');
  if (b) b.setAttribute("aria-expanded", String(on));
}

function pagePermission(page) {
  return (
    {
      Dashboard: null,
      Administrators: "administrators:read",
      Invitations: "invitations:read",
      "Prayer Times": "prayer-times:read",
      Reciters: "reciters:read",
      Duas: "duas:read",
      Dhikrs: "dhikrs:read",
      Wallpapers: "wallpapers:read",
      "Sifat Names": "sifat:read",
      "Haram Codes": "haram-codes:read",
      // Translators: "translators:read",
      Uploads: "uploads:read",
      Backup: "backup:read",
      Sync: "sync:read",
      "Dhikr Campaigns": "dhikr-campaigns:read",
      Devices: "devices:read",
      Settings: "settings:read",
    }[page] || null
  );
}

async function go(page) {
  if (!NAV.some(([n]) => n === page)) page = "Dashboard";
  state.page = page;
  if (state.tick) {
    clearInterval(state.tick);
    state.tick = null;
  }
  if (page !== "Reciters") {
    state.reciterSlug = null;
  }

  const readPerm = pagePermission(page);
  if (readPerm && !can(readPerm)) {
    $("#page").innerHTML = `<div class="card glass s12">
      <div class="empty" style="padding:40px 20px">
        ${ic("lock")}
        <b style="display:block;margin:12px 0 6px">You don't have permission to view this page.</b>
        <small style="color:var(--mut)">Ask an administrator to grant you the <code>${esc(readPerm)}</code> permission.</small>
      </div>
    </div>`;
    return;
  }

  stopAudio();

  $("#pt").textContent = page;
  document.title = `${page} · Nazar-e-Aalam Admin`;
  try {
    history.replaceState(null, "", "#" + encodeURIComponent(page));
  } catch {}
  renderNav();
  if (matchMedia("(max-width: 900px)").matches) setMenu(false);

  const container = $("#page");
  container.innerHTML = `<div class="card glass s12"><div class="empty">${ic("refresh")} Loading…</div></div>`;
  if (page === "Dashboard") startDashboard();
  if (page === "Uploads") initUploadsPage();
  if (page === "Sync") {
    _syncStartPolling();
  }
  try {
    const html = await PAGE_RENDERERS[page]();
    container.innerHTML = html;
    enhanceAllSelects(container); // ← ADD THIS LINE
    [...container.children].forEach((e, i) => e.style.setProperty("--i", i));
    if (page === "Dashboard") startDashboard();
  } catch (e) {
    container.innerHTML = `<div class="card glass s12">
            <div class="empty">${ic("x")} ${esc(e.message || "Failed to load")}<br>
            <button class="b3" data-act="reload" style="margin-top:14px">${ic("refresh")}Retry</button></div>
        </div>`;
    toast(e.message || "Failed to load", true);
  }
  container.scrollTop = 0;
  container.focus({ preventScroll: true });
}

// ============================================================================
// Dashboard
// ============================================================================
function startDashboard() {
  // Donut animations (runs once after first paint)
  requestAnimationFrame(() => {
    setTimeout(() => {
      $$(".dfg").forEach((el) => {
        el.style.strokeDashoffset = el.dataset.target ?? 0;
      });
    }, 200);
  });
  // Countdown tick
  if (!state.tick) {
    state.tick = setInterval(dashboardTick, 1000);
    dashboardTick();
  }
}

// ============================================================================
// Dashboard charts (mock data — replaced when you have analytics backend)
// ============================================================================
const DEMO_PLATFORM = { android: 180, ios: 60 };

function platformCard() {
  const total = DEMO_PLATFORM.android + DEMO_PLATFORM.ios;
  const aPct = Math.round((DEMO_PLATFORM.android / total) * 100);
  const iPct = 100 - aPct;
  const aOff = 100 - aPct;
  const iOff = 100 - iPct;
  const iRot = -90 + aPct * 3.6;

  return `<div class="card glass s4 plat">
        <div class="lbl">Platform breakdown <span class="tag">Demo data</span></div>
        <div class="dn">
            <div class="pdonut">
                <svg viewBox="0 0 42 42" role="img"
                     aria-label="Android ${DEMO_PLATFORM.android}, iOS ${DEMO_PLATFORM.ios}">
                    <circle cx="21" cy="21" r="15.9" fill="none"
                            stroke="rgba(130,60,10,.12)" stroke-width="4"/>
                    <circle class="dfg" cx="21" cy="21" r="15.9" fill="none"
                            stroke="url(#gr)" stroke-width="4" stroke-linecap="round"
                            pathLength="100" stroke-dasharray="100" stroke-dashoffset="100"
                            data-target="${aOff}" transform="rotate(-90 21 21)"/>
                    <circle class="dfg" cx="21" cy="21" r="15.9" fill="none"
                            stroke="#f6c9ab" stroke-width="4" stroke-linecap="round"
                            pathLength="100" stroke-dasharray="100" stroke-dashoffset="100"
                            data-target="${iOff}" transform="rotate(${iRot} 21 21)"/>
                    <g text-anchor="middle" font-family="Manrope,system-ui,sans-serif">
                        <text x="21" y="20" font-size="9" font-weight="800"
                              fill="#2b1608" dominant-baseline="middle">${total}</text>
                        <text x="21" y="26" font-size="2.2" font-weight="700"
                              fill="#7d5a42" letter-spacing=".35">TOTAL</text>
                    </g>
                </svg>
            </div>
            <div class="lg2">
                <span><i style="background:#e4530b"></i><b style="margin-left:0">Android</b><span style="margin-left:auto;font-weight:700">${DEMO_PLATFORM.android}</span></span>
                <span><i style="background:#f6c9ab"></i><b style="margin-left:0">iOS</b><span style="margin-left:auto;font-weight:700">${DEMO_PLATFORM.ios}</span></span>
            </div>
        </div>
    </div>`;
}

function dashboardSvgDefs() {
  return `<svg width="0" height="0" style="position:absolute" aria-hidden="true"><defs>
        <linearGradient id="gr" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0" stop-color="#ffa03f"/><stop offset="1" stop-color="#e4530b"/>
        </linearGradient>
    </defs></svg>`;
}

function dashboardTick() {
  if (state.page !== "Dashboard") {
    if (state.tick) {
      clearInterval(state.tick);
      state.tick = null;
    }
    return;
  }
  const times = state.prayerTimes;
  const cd = $("#cd");
  const rg = $("#rg");
  const npName = $("#np-name");
  if (!times || !cd) return;

  const np = nextPrayerNow(times);
  if (!np) return;
  cd.textContent = fmtDuration(np.secondsLeft);
  if (rg) rg.style.strokeDashoffset = String(100 * (1 - np.progress));
  if (npName) npName.textContent = np.name;
  $$("#np-list div").forEach((el) => {
    el.classList.toggle("nx", el.dataset.prayer === np.name.toLowerCase());
  });
}

function nextPrayerNow(times) {
  const order = [
    ["fajr", "Fajr"],
    ["sunrise", "Sunrise"],
    ["zuhr", "Dhuhr"],
    ["asr", "Asr"],
    ["maghrib", "Maghrib"],
    ["isha", "Isha"],
  ];
  const parsed = [];
  for (const [k, label] of order) {
    const t = times[k];
    if (!t) continue;
    const [h, m] = t.split(":").map(Number);
    if (!Number.isFinite(h) || !Number.isFinite(m)) continue;
    parsed.push({ key: k, label, min: h * 60 + m, display: t });
  }
  if (!parsed.length) return null;

  const now = new Date();
  const nowMin = now.getHours() * 60 + now.getMinutes() + now.getSeconds() / 60;

  let next = parsed.find((p) => p.min > nowMin);
  let prev;

  if (next) {
    prev = [...parsed].reverse().find((p) => p.min <= nowMin);
    if (!prev) {
      const last = parsed[parsed.length - 1];
      prev = { ...last, min: last.min - 24 * 60 };
    }
  } else {
    next = { ...parsed[0], min: parsed[0].min + 24 * 60 };
    prev = parsed[parsed.length - 1];
  }

  const diffSec = Math.max(0, Math.round((next.min - nowMin) * 60));
  const span = next.min - prev.min;
  const elapsed = nowMin - prev.min;
  const progress = span > 0 ? Math.min(1, Math.max(0, elapsed / span)) : 0;

  return {
    name: next.label,
    time: next.display,
    secondsLeft: diffSec,
    progress,
  };
}

async function dashboardPage() {
  const u = state.user;
  const name =
    (u && (u.first_name || (u.email || "").split("@")[0])) || "admin";
  const hour = new Date().getHours();
  const greet = 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ ٱللَّهِ وَبَرَكاتُهُ'
  const today = new Date().toLocaleDateString("en-IN", {
    weekday: "long",
    year: "numeric",
    month: "long",
    day: "numeric",
  });

  const canDuaWrite = can("duas:write");
  const canReciterWrite = can("reciters:write");
  const canWallWrite = can("wallpapers:write");
  const quickActions =
    canDuaWrite || canReciterWrite || canWallWrite
      ? `<div class="qa">
           ${canDuaWrite ? `<button type="button" data-act="go" data-p="Duas" data-then="add">${ic("plus")}Add dua</button>` : ""}
           ${canReciterWrite ? `<button type="button" data-act="go" data-p="Reciters" data-then="add">${ic("head")}Add reciter</button>` : ""}
           ${canWallWrite ? `<button type="button" class="g" data-act="go" data-p="Wallpapers" data-then="add">${ic("img")}Add wallpaper</button>` : ""}
         </div>`
      : "";

  // ── Make sure city catalogue is loaded before matching ──
  await ensurePrayerCities();

  // ── Resolve the city ──
  let resolvedCity = state.prayerCity;
  if (resolvedCity === "__detected__") resolvedCity = null; // never treat sentinel as a city

  if (!resolvedCity && state.detected && state.detected.city) {
    const match = _matchCuratedCity(
      state.detected.city,
      state.detected.state,
      state.detected.country_code,
    );
    if (match) resolvedCity = match.key;
  }

  // ── Three states ──
  const hasCoords =
    state.detected &&
    typeof state.detected.lat === "number" &&
    typeof state.detected.lon === "number";
  const stateKind = resolvedCity
    ? "curated"
    : hasCoords
      ? "detected"
      : "unresolved";

  // ── Fetch prayer times ──
  let todayTimes = null;
  if (stateKind === "curated") {
    state.prayerCity = resolvedCity;
    try {
      todayTimes = await loadTodayPrayerTimes();
    } catch {}
  } else if (stateKind === "detected") {
    try {
      const r = await api.get(
        `/prayer-times/for-location?lat=${state.detected.lat}&lon=${state.detected.lon}`,
      );
      const t = r.timings || {};
      todayTimes = {
        city: r.city_name || state.detected.city || "detected",
        times: {
          imsak: t.imsak,
          fajr: t.fajr,
          sunrise: t.sunrise,
          zuhr: t.dhuhr,
          asr: t.asr,
          maghrib: t.maghrib,
          isha: t.isha,
        },
        isFriday: !!r.is_friday,
      };
    } catch {}
  }

  // ── Hijri city — use detected city name when there's no curated match ──
  const hijriCity =
    resolvedCity ||
    (state.detected && state.detected.city
      ? state.detected.city.toLowerCase().trim()
      : "nadiad");

  const [hijriRes, citiesRes] = await Promise.allSettled([
    api.get("/hijri/now?city=" + encodeURIComponent(hijriCity)),
    ensurePrayerCities(),
  ]);

  const hijri = hijriRes.status === "fulfilled" ? hijriRes.value : null;
  const cities = citiesRes.status === "fulfilled" ? citiesRes.value : [];

  state.prayerTimes = todayTimes ? todayTimes.times : null;

  let hijriLine = "";
  if (hijri) {
    hijriLine = `${hijri.hijri_day} ${hijri.hijri_month_name} ${hijri.hijri_year} AH`;
    if (hijri.is_tentative) hijriLine += " · tentative";
  }

  // ── Stat cards ──
  const stats = [
    {
      key: "wallpapers",
      icon: "img",
      label: "Wallpapers",
      endpoint: "/wallpapers?limit=1",
    },
    { key: "duas", icon: "heart", label: "Duas", endpoint: "/duas?limit=1" },
    {
      key: "dhikrs",
      icon: "beads",
      label: "Dhikrs",
      endpoint: "/dhikrs?limit=1",
    },
    {
      key: "chapters",
      icon: "book",
      label: "Chapters",
      endpoint: "/chapters?limit=1",
    },
    {
      key: "admins",
      icon: "shield",
      label: "Administrators",
      endpoint: "/administrators?limit=1",
    },
  ];

  Promise.allSettled(stats.map((s) => api.get(s.endpoint))).then((results) => {
    if (state.page !== "Dashboard") return;
    results.forEach((r, i) => {
      const el = $(`[data-count="${stats[i].key}"]`);
      if (!el) return;
      if (r.status === "fulfilled" && r.value?.meta) {
        el.textContent = r.value.meta.total;
      } else {
        el.textContent = "—";
      }
    });
  });

  // ── Next prayer card ──
  let npCard;
  if (stateKind === "unresolved") {
    npCard = `
      <div class="card glass s4 np" style="justify-content:center;border-left:4px solid var(--bad)">
        <div style="display:flex;align-items:center;gap:8px;margin-bottom:8px">
          <div class="ic" style="background:rgba(143,35,8,.15);color:var(--bad)">${ic("globe")}</div>
          <b>Location not detected</b>
        </div>
        <p style="margin:0 0 12px;color:var(--mut);font-size:13px">
          We can't show prayer times without knowing your location. Allow browser location or set a city manually.
        </p>
        <div style="display:flex;flex-direction:column;gap:8px">
          <button type="button" class="btn" data-act="dash-detect-loc">
            ${ic("globe")}Detect my location
          </button>
          <button type="button" class="b3" data-act="go" data-p="Prayer Times">
            ${ic("clock")}Pick a city manually
          </button>
        </div>
      </div>`;
  } else if (stateKind === "detected" && !todayTimes) {
    npCard = `
      <div class="card glass s4 np" style="justify-content:center;border-left:4px solid var(--bad)">
        <div style="display:flex;align-items:center;gap:8px;margin-bottom:8px">
          <div class="ic" style="background:rgba(143,35,8,.15);color:var(--bad)">${ic("clock")}</div>
          <b>Couldn't load prayer times</b>
        </div>
        <p style="margin:0 0 12px;color:var(--mut);font-size:13px">
          We detected "${esc(state.detected?.city || "your location")}" but the prayer time service didn't respond.
        </p>
        <button type="button" class="btn" data-act="dash-refresh-loc">
          ${ic("refresh")}Retry
        </button>
      </div>`;
  } else {
    npCard = renderNextPrayer(
      todayTimes,
      cities,
      stateKind === "detected"
        ? [state.detected.city, state.detected.country]
            .filter(Boolean)
            .join(", ")
        : null,
    );
  }

  // Small toast so the user knows where the computed times come from
  if (stateKind === "detected" && !state._detectedToastShown) {
    state._detectedToastShown = true;
    const label =
      [state.detected.city, state.detected.country]
        .filter(Boolean)
        .join(", ") ||
      `${state.detected.lat.toFixed(3)}, ${state.detected.lon.toFixed(3)}`;
    setTimeout(() => toast(`📍 Using computed prayer times for ${label}`), 400);
  }

  return `
        ${dashboardSvgDefs()}
        <div class="card glass hero s8">
            <svg class="wv" viewBox="0 0 800 70" preserveAspectRatio="none" aria-hidden="true">
                <path d="M0 35C50 5 150 65 200 35S350 5 400 35 550 65 600 35 750 5 800 35V70H0Z"/>
            </svg>
            <h2>${esc(greet)}, ${esc(cap(name))} 👋</h2>
            <p>${hijriLine ? esc(hijriLine) + " · " : ""}</p>
            <div class="hrow"><span>${ic("clock")}${esc(today)}</span></div>
            <div class="qa">
                <button type="button" data-act="go" data-p="Duas" data-then="add">${ic("plus")}Add dua</button>
                <button type="button" data-act="go" data-p="Reciters" data-then="add">${ic("head")}Add reciter</button>
                <button type="button" class="g" data-act="go" data-p="Wallpapers" data-then="add">${ic("img")}Add wallpaper</button>
            </div>
        </div>
        ${npCard}
        ${stats
          .map(
            (s) => `
            <div class="card glass s4 stat">
                <div class="top"><div class="ic">${ic(s.icon)}</div></div>
                <div class="num" data-count="${s.key}">…</div>
                <div class="lbl">${esc(s.label)}</div>
            </div>
        `,
          )
          .join("")}
        ${platformCard()}
    `;
}

const LOCATION_CACHE_KEY = "nea:detected_v1";
const CITY_PREF_KEY = "nea:prayer_city_v1";

function _savePrayerCityPref(key) {
  try {
    if (key && key !== "__detected__") {
      localStorage.setItem(CITY_PREF_KEY, key);
    }
  } catch {}
}
function _loadPrayerCityPref() {
  try {
    return localStorage.getItem(CITY_PREF_KEY);
  } catch {
    return null;
  }
}
const LOCATION_MAX_AGE_MS = 24 * 60 * 60 * 1000; // 24 hours

function _persistDetected(detected) {
  try {
    if (!detected) {
      localStorage.removeItem(LOCATION_CACHE_KEY);
      return;
    }
    localStorage.setItem(
      LOCATION_CACHE_KEY,
      JSON.stringify({
        ...detected,
        _cachedAt: Date.now(),
      }),
    );
  } catch {}
}

function _loadPersistedDetected() {
  try {
    const raw = localStorage.getItem(LOCATION_CACHE_KEY);
    if (!raw) return null;
    const d = JSON.parse(raw);
    // Expire after LOCATION_MAX_AGE_MS
    if (!d._cachedAt || Date.now() - d._cachedAt > LOCATION_MAX_AGE_MS) {
      localStorage.removeItem(LOCATION_CACHE_KEY);
      return null;
    }
    return d;
  } catch {
    return null;
  }
}

function _browserGeolocation() {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      reject(new Error("Browser geolocation is not supported"));
      return;
    }
    navigator.geolocation.getCurrentPosition(
      (pos) => resolve({ lat: pos.coords.latitude, lon: pos.coords.longitude }),
      (err) => {
        const msg =
          err.code === err.PERMISSION_DENIED
            ? "Location permission denied. Enable it in your browser settings."
            : err.code === err.POSITION_UNAVAILABLE
              ? "Location unavailable. Check your network or GPS."
              : "Location request timed out.";
        reject(new Error(msg));
      },
      { enableHighAccuracy: false, timeout: 10000, maximumAge: 5 * 60_000 },
    );
  });
}

const LOCATION_ASKED_KEY = "nea:loc_asked";

async function autoPromptLocationIfNeeded() {
  // Only ask once per browser, unless previously denied
  if (localStorage.getItem(LOCATION_ASKED_KEY) === "1") return;
  if (!navigator.geolocation) return;

  // Check the current permission state without triggering a prompt
  let permState = null;
  try {
    if (navigator.permissions && navigator.permissions.query) {
      const p = await navigator.permissions.query({ name: "geolocation" });
      permState = p.state; // "granted" | "prompt" | "denied"
    }
  } catch {}

  if (permState === "denied") {
    localStorage.setItem(LOCATION_ASKED_KEY, "1");
    return;
  }

  // If permission was already granted, resolve silently
  if (permState === "granted") {
    try {
      await detectLocationFromBrowser();
      localStorage.setItem(LOCATION_ASKED_KEY, "1");
    } catch {}
    return;
  }

  // Permission is "prompt" — showing a modal first is nicer than the raw browser dialog
  // But if you want the raw dialog, just call detectLocationFromBrowser() directly.
  // Here we trigger it directly so the browser dialog appears:
  try {
    await detectLocationFromBrowser();
    localStorage.setItem(LOCATION_ASKED_KEY, "1");
  } catch {
    // User said "block" or timed out — don't ask again this session
    localStorage.setItem(LOCATION_ASKED_KEY, "1");
  }
}

async function detectLocationFromBrowser() {
  try {
    const coords = await _browserGeolocation();
    const d = await api.get(
      `/location/get?lat=${coords.lat}&lon=${coords.lon}`,
    );

    state.detected = {
      lat: coords.lat,
      lon: coords.lon,
      city: d.city,
      state: d.state,
      country: d.country,
      country_code: d.country_code,
      postcode: d.postcode,
      formatted_address: d.formatted_address,
      source: "browser",
      cached: d.cached,
    };
    _persistDetected(state.detected);

    const match = _matchCuratedCity(d.city, d.state, d.country_code);
    if (match) {
      state.prayerCity = match.key;
      state.prayerCityPage = match.key;
      toast(`Location detected: ${d.city}, ${d.country}`);
    } else {
      state.prayerCity = null;
      state.prayerCityPage = null;
      toast(
        `Detected ${d.city || "your area"} — no curated prayer times for this city. Use "Prayer times by coordinate" instead.`,
        true,
      );
    }

    // Auto re-render if we're on a location-dependent page
    if (state.page === "Dashboard" || state.page === "Prayer Times") {
      await go(state.page);
    }

    return { coords, data: d, match };
  } catch (e) {
    toast(e.message || "Could not detect location", true);
    throw e;
  }
}

async function loadTodayPrayerTimes() {
  const city = state.prayerCity;
  if (!city) {
    // No city resolved — return null so the caller shows "Location not detected"
    return null;
  }
  const today = new Date().toISOString().slice(0, 10);
  try {
    const r = await api.get(
      `/prayer-times?city=${encodeURIComponent(city)}&from=${today}&to=${today}&limit=5`,
    );
    const row = (r.items || [])[0];
    if (!row) return null;
    return {
      city,
      times: {
        imsak: row.imsak,
        fajr: row.fajr_start,
        sunrise: row.sunrise,
        zuhr: row.zuhr_start,
        asr: row.asr_start,
        maghrib: row.maghrib_start,
        isha: row.isha_start,
      },
      isFriday: !!row.is_friday,
    };
  } catch {
    return null;
  }
}

function renderNextPrayer(todayTimes, cities, overrideCity = null) {
  // Build dropdown list. If we're on a "detected" location, inject it at the top.
  let opts = cities.map(
    (c) =>
      `<option value="${esc(c.key)}"${
        c.key === state.prayerCity && !overrideCity ? " selected" : ""
      }>${esc(c.name)}</option>`,
  );
  if (overrideCity) {
    opts = [
      `<option value="__detected__" selected>${esc(overrideCity)} (detected)</option>`,
      ...opts,
    ];
  }
  const cityOpts = opts.join("");

  if (!todayTimes) {
    return `<div class="card glass s4 np" style="justify-content:center">
            <small>Next prayer</small>
            <p style="margin:20px 0;color:var(--mut);font-size:13px">No prayer times seeded for today.</p>
            <button type="button" class="b3" data-act="go" data-p="Prayer Times">${ic("clock")}Set up</button>
        </div>`;
  }

  const t = todayTimes.times;
  const list = [
    ["fajr", "Fajr", t.fajr],
    ["sunrise", "Sunrise", t.sunrise],
    ["zuhr", "Dhuhr", t.zuhr],
    ["asr", "Asr", t.asr],
    ["maghrib", "Maghrib", t.maghrib],
    ["isha", "Isha", t.isha],
  ].filter(([, , v]) => v);

  const fmtBtn = `<button type="button" data-act="toggle-time-fmt"
      title="Switch between 12-hour and 24-hour"
      aria-label="Switch time format"
      style="height:28px;min-width:44px;padding:0 10px;border-radius:8px;border:1px solid var(--line);background:rgba(255,255,255,0.5);cursor:pointer;display:inline-flex;align-items:center;justify-content:center;color:inherit;font-size:12px;font-weight:700;letter-spacing:.03em">
      ${_timeFmt === "12" ? "12h" : "24h"}
    </button>`;

  return `<div class="card glass s4 np">
        <div style="display:flex;align-items:center;justify-content:space-between;gap:8px;width:100%;margin-bottom:6px">
            <small>Next prayer</small>
            <div style="display:flex;gap:6px;align-items:center">
              ${fmtBtn}
              <button type="button" data-act="dash-refresh-loc" title="Refresh location"
                style="width:28px;height:28px;border-radius:8px;border:1px solid var(--line);background:rgba(255,255,255,0.5);cursor:pointer;display:inline-flex;align-items:center;justify-content:center;color:inherit;padding:0">
                ${ic("refresh")}
              </button>
              <select class="in" style="height:28px;font-size:12px;max-width:130px;padding:0 8px"
                  data-change="np-city">${cityOpts}</select>
            </div>
        </div>
        <div class="rg">
            <svg viewBox="0 0 36 36" aria-hidden="true">
                <circle class="bg" cx="18" cy="18" r="15.9"/>
                <circle id="rg" class="fg" cx="18" cy="18" r="15.9" pathLength="100"/>
            </svg>
            <div>
                <b id="np-name">—</b>
                <em id="cd">--:--:--</em>
            </div>
        </div>
        <div class="pr" id="np-list">
            ${list
              .map(
                ([key, label, time]) =>
                  `<div data-prayer="${key}"><span>${esc(label)}</span><b>${fmtTimeHtml(time)}</b></div>`,
              )
              .join("")}
        </div>
    </div>`;
}

// ============================================================================
// Generic CRUD
// ============================================================================
const CRUD = {
  Duas: {
    endpoint: "/duas",
    title: "Dua List",
    sub: "Supplications shown in the app",
    icon: "heart",
    label: (x) => x.en_short_name || `#${x.id}`,
    columns: [
      { label: "Position", get: (x) => x.position },
      { label: "Short (En)", get: (x) => x.en_short_name },
      { label: "Short (Ar)", get: (x) => x.ar_short_name, rtl: true },
      { label: "Full (En)", get: (x) => x.en_full_name, wrap: true },
      { label: "Full (Ar)", get: (x) => x.ar_full_name, rtl: true, wrap: true },
    ],
    fields: [
      { k: "position", l: "Position", t: "number" },
      { k: "en_short_name", l: "Short name (English)" },
      { k: "ar_short_name", l: "Short name (Arabic)", ar: 1 },
      {
        k: "en_full_name",
        l: "Full text (English)",
        t: "area",
        rows: 4,
        full: 1,
      },
      {
        k: "ar_full_name",
        l: "Full text (Arabic)",
        t: "area",
        rows: 4,
        ar: 1,
        full: 1,
      },
    ],
  },
  Dhikrs: {
    endpoint: "/dhikrs",
    title: "Dhikr List",
    sub: "Remembrances for the tasbih counter",
    icon: "beads",
    label: (x) => x.en_short_name || `#${x.id}`,
    columns: [
      { label: "Position", get: (x) => x.position },
      { label: "Short (En)", get: (x) => x.en_short_name },
      { label: "Short (Ar)", get: (x) => x.ar_short_name, rtl: true },
      { label: "Full (En)", get: (x) => x.en_full_name, wrap: true },
      { label: "Full (Ar)", get: (x) => x.ar_full_name, rtl: true, wrap: true },
    ],
    fields: [
      { k: "position", l: "Position", t: "number" },
      { k: "en_short_name", l: "Short name (English)" },
      { k: "ar_short_name", l: "Short name (Arabic)", ar: 1 },
      {
        k: "en_full_name",
        l: "Full text (English)",
        t: "area",
        rows: 4,
        full: 1,
      },
      {
        k: "ar_full_name",
        l: "Full text (Arabic)",
        t: "area",
        rows: 4,
        ar: 1,
        full: 1,
      },
    ],
  },
  "Sifat Names": {
    endpoint: "/sifat-names",
    title: "Names of Allah",
    sub: "Asma ul Husna",
    icon: "star",
    label: (x) => x.name || `#${x.id}`,
    columns: [
      { label: "Position", get: (x) => x.position },
      { label: "Name", get: (x) => x.name },
      { label: "Arabic", get: (x) => x.ar_name, rtl: true },
      { label: "Meaning", get: (x) => x.translated_name, wrap: true },
      { label: "Benefits", get: (x) => x.name_benefits, wrap: true },
    ],
    fields: [
      { k: "position", l: "Position", t: "number" },
      { k: "name", l: "Name (English)" },
      { k: "ar_name", l: "Name (Arabic)", ar: 1 },
      { k: "translated_name", l: "Translation", t: "area", full: 1 },
      { k: "meaning", l: "Meaning", t: "area", full: 1 },
      { k: "name_benefits", l: "Benefits", t: "area", full: 1 },
    ],
  },
  "Haram Codes": {
    endpoint: "/haram-codes",
    title: "Haram Codes",
    sub: "Prohibited items code reference",
    icon: "book",
    label: (x) => x.name || x.code || `#${x.id}`,
    columns: [
      { label: "Code", get: (x) => x.code },
      { label: "Name", get: (x) => x.name },
      { label: "Desc", get: (x) => x.description, wrap: true },
      { label: "Status", get: (x) => x.status_info, wrap: true },
    ],
    fields: [
      { k: "code", l: "Code" },
      { k: "name", l: "Name" },
      { k: "description", l: "Description", t: "area", full: 1 },
      { k: "status_info", l: "Status info", t: "area", full: 1 },
    ],
  },
  Administrators: {
    endpoint: "/administrators",
    title: "Administrators",
    sub: "People who can sign in — new admins come in via Invitations",
    icon: "shield",
    label: (x) =>
      `${x.first_name || ""} ${x.last_name || ""}`.trim() || x.email,
    primaryAction: {
      label: "Invite admin",
      icon: "key",
      act: "invite-open",
    },
    hideDelete: true, // ← never delete from this page
    reinvite: true, // ← expose re-invite action
    columns: [
      {
        label: "Name",
        get: (x) => `${x.first_name || ""} ${x.last_name || ""}`.trim() || "—",
      },
      { label: "Email", get: (x) => x.email },
      {
        label: "Roles",
        html: true,
        get: (x) => {
          const roles = x.roles || [];
          const pills = [];
          if (roles.length) {
            pills.push(
              roles
                .map(
                  (r) =>
                    `<span class="pill" style="margin-right:4px">${esc(r.name)}</span>`,
                )
                .join(""),
            );
          } else if (x.is_admin) {
            pills.push(`<span class="pill">Admin</span>`);
          } else {
            pills.push(`<span class="pill off">User</span>`);
          }
          if (x.has_pending_invite) {
            pills.push(
              `<span class="pill warn" title="Re-invite pending — waiting for acceptance">pending</span>`,
            );
          }
          return pills.join("");
        },
      },
    ],
    fields: [
      { k: "first_name", l: "First name" },
      { k: "last_name", l: "Last name" },
    ],
    async prepareForm(existing) {
      setTimeout(async () => {
        const form = $("#mform");
        if (!form) return;

        const roles = await ensureRoles();
        const currentIds = new Set((existing?.roles || []).map((r) => r.id));

        const block = document.createElement("div");
        block.className = "full";
        block.style.marginTop = "4px";
        block.innerHTML = `
          <label style="display:block;margin-bottom:8px;font-size:12px;font-weight:700;letter-spacing:.06em;text-transform:uppercase;color:var(--mut)">Roles</label>
          <div id="roles-box" style="display:flex;flex-wrap:wrap;gap:8px;padding:10px;background:rgba(255,255,255,0.55);border-radius:14px;border:1px solid var(--line);min-height:48px">
            ${
              roles.length
                ? roles
                    .map(
                      (r) => `
                  <label class="role-chip" style="display:inline-flex;align-items:center;gap:6px;padding:8px 12px;border-radius:10px;background:rgba(255,255,255,0.75);border:1px solid var(--line);cursor:pointer;font-size:13px">
                    <input type="checkbox" name="__role_${r.id}" value="${r.id}" ${currentIds.has(r.id) ? "checked" : ""} style="margin:0;cursor:pointer">
                    <span>${esc(r.name)}</span>
                  </label>
                `,
                    )
                    .join("")
                : `<small style="color:var(--mut);font-size:12px">No roles exist yet — click "+ New role" to create the first one.</small>`
            }
          </div>
          <div style="margin-top:10px;display:flex;gap:8px;flex-wrap:wrap">
            <button type="button" class="b3" data-act="role-create-open" style="font-size:13px">${ic("plus")}New role</button>
            <button type="button" class="b3" data-act="role-refresh" style="font-size:13px">${ic("refresh")}Reload roles</button>
          </div>
        `;
        form.querySelector(".mf").appendChild(block);
      }, 20);
    },
    collectExtraData() {
      const ids = [];
      $$('#mform input[type="checkbox"][name^="__role_"]:checked').forEach(
        (cb) => ids.push(parseInt(cb.value, 10)),
      );
      return { role_ids: ids };
    },
  },
};

function renderCell(c, x) {
  const v = c.get(x);
  const empty = v == null || v === "";
  const text = empty ? "—" : String(v);
  const cls = [c.rtl ? "rtl" : "", c.wrap ? "wrap" : ""]
    .filter(Boolean)
    .join(" ");
  const content = c.html ? text : esc(text);
  return cls ? `<td class="${cls}">${content}</td>` : `<td>${content}</td>`;
}

async function crudPage(key) {
  const cfg = CRUD[key];
  if (!cfg) return `<div class="empty">Unknown page: ${esc(key)}</div>`;
  const list = await apiCall(api.get(cfg.endpoint + "?limit=500"), {
    errorPrefix: `Load ${key}`,
  });
  const items = list.items || [];

  // Header action: default is "+ Add X"; a page can override via cfg.primaryAction
  const headAction = cfg.primaryAction
    ? can(permissionFor(key) + ":write")
      ? `<button type="button" class="b2" data-act="${esc(cfg.primaryAction.act)}">${ic(cfg.primaryAction.icon || "plus")}${esc(cfg.primaryAction.label)}</button>`
      : ""
    : can(permissionFor(key) + ":write")
      ? `<button type="button" class="b2" data-act="crud-add" data-key="${esc(key)}">${ic("plus")}Add ${esc(key.replace(/s$/, "").toLowerCase())}</button>`
      : "";

  const head = `
        <div class="eh">
            <div class="ic">${ic(cfg.icon)}</div>
            <div><h3>${esc(cfg.title)}</h3><p>${esc(cfg.sub)}</p></div>
            ${headAction}
        </div>`;

  // Empty state — same header, helpful hint
  if (!items.length) {
    const emptyHint = cfg.primaryAction
      ? `Nothing here yet. Use the <b>${esc(cfg.primaryAction.label)}</b> button above to send the first one.`
      : `Nothing here yet. Use the button above to add the first one.`;
    return `<div class="card glass s12">${head}
            <div class="empty">${emptyHint}</div>
        </div>`;
  }

  // Row-level actions — Edit + Delete for every page.
  // A page can hide edit or delete via cfg.hideEdit / cfg.hideDelete.
  const actionsFor = (x) => {
    const id = x.id;
    const out = [];
    if (!cfg.hideEdit && can(permissionFor(key) + ":write")) {
      out.push(
        `<button type="button" title="Edit" data-act="crud-edit" data-key="${esc(key)}" data-id="${id}">${ic("edit")}</button>`,
      );
    }
    // Re-invite action (Administrators page only)
    if (cfg.reinvite && can("invitations:write")) {
      const pending = x.has_pending_invite === true;
      out.push(
        `<button type="button" title="${pending ? "Resend invite" : "Re-invite admin"}"
          data-act="admin-reinvite"
          data-id="${id}"
          data-email="${esc(x.email)}"
          data-pending="${pending}"
          style="${pending ? "color:var(--warn)" : ""}">${ic("refresh")}</button>`,
      );
    }
    if (!cfg.hideDelete && can(permissionFor(key) + ":write")) {
      out.push(
        `<button type="button" class="d" title="Delete" data-act="crud-del" data-key="${esc(key)}" data-id="${id}" data-label="${esc(cfg.label(x))}">${ic("trash")}</button>`,
      );
    }
    return out.join("") || "—";
  };

  const header =
    cfg.columns.map((c) => `<th>${esc(c.label)}</th>`).join("") +
    `<th>Action</th>`;

  const rows = items
    .map((x) => {
      const cells = cfg.columns.map((c) => renderCell(c, x)).join("");
      return `<tr data-id="${x.id}">${cells}
            <td><span class="act-b">${actionsFor(x)}</span></td></tr>`;
    })
    .join("");

  return `<div class="card glass s12">${head}
        <div class="tb">
            <div class="fld">${ic("search")}<input type="search" placeholder="Search…" aria-label="Search" data-filter></div>
        </div>
        <div class="tw"><table>
            <thead><tr>${header}</tr></thead>
            <tbody>${rows}</tbody>
        </table></div>
        <div class="foot">${items.length} total</div>
    </div>`;
}

async function openCrudForm(key, id) {
  const cfg = CRUD[key];
  if (!cfg) return;
  let existing = null;
  if (id != null) {
    try {
      existing = await api.get(`${cfg.endpoint}/${id}`);
    } catch (e) {
      toast("Load failed: " + e.message, true);
      return;
    }
  }

  if (!can(permissionFor(key) + ":write")) {
    toast("You don't have permission to edit this resource", true);
    return;
  }

  let fields = cfg.fields.slice();
  if (key === "Administrators" && existing) {
    fields = fields.map((f) =>
      f.k === "password"
        ? { ...f, req: 0, h: "Leave blank to keep current password." }
        : f,
    );
  }

  formModal({
    title: `${id != null ? "Edit" : "Add"} ${key.replace(/s$/, "").toLowerCase()}`,
    fields,
    data: existing || {},
    onSubmit: async (vals) => {
      if (key === "Administrators" && existing && !vals.password)
        delete vals.password;
      // Merge any extras from the form (e.g., role checkboxes)
      if (typeof cfg.collectExtraData === "function") {
        Object.assign(vals, cfg.collectExtraData());
      }
      try {
        if (id != null) {
          await api.patch(`${cfg.endpoint}/${id}`, vals);
        } else {
          await api.post(cfg.endpoint, vals);
        }
        api.cache.invalidate("roles");
        api.cache.invalidate("administrators");
        toast(id != null ? "Saved" : "Created");
        await go(state.page);
        return null;
      } catch (e) {
        return e.message || "Save failed";
      }
    },
  });

  if (typeof cfg.prepareForm === "function") {
    await cfg.prepareForm(existing);
  }
}

// ============================================================================
// Invitations
// ============================================================================
async function invitationsPage() {
  let invites = [];
  try {
    invites = await api.get("/admin/invitations");
  } catch (e) {
    return `<div class="card glass s12">
      <div class="empty">${ic("x")} ${esc(e.message || "Failed to load invitations")}</div>
    </div>`;
  }

  const pending = invites.filter((x) => x.status === "pending").length;
  const accepted = invites.filter((x) => x.status === "accepted").length;
  const revoked = invites.filter((x) => x.status === "revoked").length;

  const head = `
    <div class="eh">
      <div class="ic">${ic("key")}</div>
      <div><h3>Invitations</h3><p>Pending, accepted, and revoked admin invitations</p></div>
      <button type="button" class="b2" data-act="invite-open">${ic("plus")}Invite admin</button>
    </div>`;

  const stats = `
    <div class="card glass s4 stat">
      <div class="top"><div class="ic">${ic("clock")}</div></div>
      <div class="num">${pending}</div><div class="lbl">Pending</div>
    </div>
    <div class="card glass s4 stat">
      <div class="top"><div class="ic">${ic("check")}</div></div>
      <div class="num">${accepted}</div><div class="lbl">Accepted</div>
    </div>
    <div class="card glass s4 stat">
      <div class="top"><div class="ic">${ic("x")}</div></div>
      <div class="num">${revoked}</div><div class="lbl">Revoked</div>
    </div>`;

  if (!invites.length) {
    return `<div class="card glass s12">${head}</div>${stats}
      <div class="card glass s12">
        <div class="empty">No invitations yet. Click <b>Invite admin</b> to send the first one.</div>
      </div>`;
  }

  const pill = (s) =>
    ({
      pending: `<span class="pill warn">pending</span>`,
      accepted: `<span class="pill ok">accepted</span>`,
      revoked: `<span class="pill off">revoked</span>`,
      expired: `<span class="pill off">expired</span>`,
    })[s] || `<span class="pill off">${esc(s)}</span>`;

  const rows = invites
    .map((inv) => {
      const actions = [];
      if (inv.status === "pending" || inv.status === "expired") {
        actions.push(
          `<button type="button" title="Resend" data-act="invite-resend" data-id="${inv.id}">${ic("refresh")}</button>`,
        );
      }
      if (inv.status === "pending") {
        actions.push(
          `<button type="button" class="d" title="Revoke" data-act="invite-revoke" data-id="${inv.id}" data-email="${esc(inv.email)}">${ic("trash")}</button>`,
        );
      }
      return `<tr>
        <td>#${inv.id}</td>
        <td>${esc(inv.email)}</td>
        <td>${esc(inv.role_name || "—")}</td>
        <td>${esc(inv.inviter_name || "—")}</td>
        <td>${pill(inv.status)}</td>
        <td>${esc((inv.expires_at || "").replace("T", " ").slice(0, 16))}</td>
        <td>${esc((inv.created_at || "").replace("T", " ").slice(0, 16))}</td>
        <td><span class="act-b">${actions.join("") || "—"}</span></td>
      </tr>`;
    })
    .join("");

  return `<div class="card glass s12">${head}</div>${stats}
    <div class="card glass s12">
      <div class="tb">
        <div class="fld">${ic("search")}<input type="search" placeholder="Search invitations…" data-filter></div>
      </div>
      <div class="tw"><table>
        <thead><tr>
          <th>ID</th><th>Email</th><th>Role</th><th>Invited by</th>
          <th>Status</th><th>Expires</th><th>Created</th><th>Actions</th>
        </tr></thead>
        <tbody>${rows}</tbody>
      </table></div>
      <div class="foot">${invites.length} total</div>
    </div>`;
}

async function openInviteForm() {
  if (!can("invitations:write")) {
    toast("You don't have permission to invite admins", true);
    return;
  }

  const roles = await ensureRoles();
  formModal({
    title: "Invite a new administrator",
    fields: [
      {
        k: "email",
        l: "Email",
        t: "email",
        req: 1,
        full: 1,
        h: "They'll receive an invite email with a link to set their password.",
      },
      {
        k: "role_id",
        l: "Role",
        t: "select",
        o: ["", ...roles.map((r) => r.name)],
        full: 1,
        h: "Optional. The role the new admin will get.",
      },
    ],
    onSubmit: async (vals) => {
      const selectedRole = vals.role_id
        ? roles.find((r) => r.name === vals.role_id)
        : null;
      try {
        await api.post("/admin/invitations", {
          email: vals.email,
          role_id: selectedRole ? selectedRole.id : null,
        });
        api.cache.invalidate("invitations");
        toast("Invitation sent");
        await go("Invitations");
        return null;
      } catch (e) {
        return e.message || "Invite failed";
      }
    },
  });
}

async function roleCreateModal() {
  if (!can("roles:write")) {
    toast("You don't have permission to create roles", true);
    return;
  }
  ({
    title: "Create role",
    fields: [
      {
        k: "name",
        l: "Role name",
        req: 1,
        full: 1,
        h: "e.g., Content Manager, Moderator",
      },
      {
        k: "alias",
        l: "Alias (slug)",
        full: 1,
        h: "Optional. Auto-lowercase like 'content-manager'.",
      },
    ],
    onSubmit: async (vals) => {
      try {
        const created = await api.post("/roles", {
          name: vals.name,
          alias: vals.alias || vals.name.toLowerCase().replace(/\s+/g, "-"),
          is_admin: true,
          is_default: false,
        });
        api.cache.invalidate("roles");
        state.roles = null;
        toast(`Role "${created.name}" created`);

        // If we're still inside the admin edit form, append the new role
        // as an already-checked checkbox (freshly created → auto-assign).
        const box = document.getElementById("roles-box");
        if (box) {
          const chip = document.createElement("label");
          chip.className = "role-chip";
          chip.style =
            "display:inline-flex;align-items:center;gap:6px;padding:8px 12px;border-radius:10px;background:rgba(255,255,255,0.75);border:1px solid var(--line);cursor:pointer;font-size:13px";
          chip.innerHTML = `
            <input type="checkbox" name="__role_${created.id}" value="${created.id}" checked style="margin:0;cursor:pointer">
            <span>${esc(created.name)}</span>
          `;
          // Remove the "no roles yet" hint if present
          const hint = box.querySelector("small");
          if (hint) hint.remove();
          box.appendChild(chip);
        }
        return null;
      } catch (e) {
        return e.message || "Create failed";
      }
    },
  });
}

function confirmDelete(key, id, label) {
  const cfg = CRUD[key];
  if (!cfg) return;
  confirmBox({
    title: `Delete ${key.replace(/s$/, "").toLowerCase()}?`,
    msg: `"${label}" will be permanently deleted.`,
    onOk: async () => {
      try {
        await api.del(`${cfg.endpoint}/${id}`);
        toast("Deleted");
        await go(state.page);
      } catch (e) {
        toast(e.message || "Delete failed", true);
      }
    },
  });
}

// ============================================================================
// Wallpapers
// ============================================================================
async function wallpapersPage() {
  const r = await apiCall(api.get("/wallpapers?limit=500"), {
    errorPrefix: "Load wallpapers",
  });
  const items = r.items || [];

  const head = `
        <div class="eh">
            <div class="ic">${ic("img")}</div>
            <div><h3>Wallpapers</h3><p>Backgrounds people can set from the app</p></div>
            <button type="button" class="b2" data-act="wall-add">${ic("plus")}Add wallpaper</button>
        </div>`;

  if (!items.length) {
    return `<div class="card glass s12">${head}
            <div class="empty">No wallpapers yet. Use the button above to add the first one.</div>
        </div>`;
  }

  const tiles = items
    .map(
      (w) => `
        <div class="wp" style="background:linear-gradient(160deg,#ffa03f,#7a2a05)"
             data-act="wall-preview" data-id="${w.id}" role="button" tabindex="0"
             title="Preview ${esc(w.name)}">
            ${w.image ? `<img src="${esc(w.image)}" alt="${esc(w.name)}" loading="lazy">` : ""}
            <span class="act-b">
                <button type="button" title="Edit" data-act="wall-edit" data-id="${w.id}">${ic("edit")}</button>
                <button type="button" class="d" title="Delete" data-act="wall-del" data-id="${w.id}" data-label="${esc(w.name)}">${ic("trash")}</button>
            </span>
            <span class="n">${esc(w.name)}</span>
        </div>`,
    )
    .join("");

  return `<div class="card glass s12">${head}
        <div class="wg">${tiles}</div>
        <div class="foot">${items.length} total</div>
    </div>`;
}

async function wallPreview(id) {
  if (!can("wallpapers:read")) {
    toast("You don't have permission to view wallpapers", true);
    return;
  }
  try {
    const w = await api.get(`/wallpapers/${id}`);
    openModal(
      `<div class="mh"><h3 id="mt">${esc(w.name)}</h3>
                <button type="button" class="x" data-act="close" aria-label="Close">${ic("x")}</button></div>
             <div style="text-align:center;padding:16px 0;background:#000;border-radius:16px;overflow:hidden">
                <img src="${esc(w.image)}" alt="${esc(w.name)}"
                     style="max-width:100%;max-height:60vh;display:block;margin:0 auto">
             </div>
             <div class="mfoot" style="justify-content:space-between">
                <small style="color:var(--mut);font-size:11px">${esc(w.image)}</small>
                <a href="${esc(w.image)}" target="_blank" rel="noopener" class="b3">${ic("down")}Open original</a>
             </div>`,
    );
  } catch (e) {
    toast("Preview failed: " + e.message, true);
  }
}

function openWallForm(existing) {
  if (!can("wallpapers:write")) {
    toast("You don't have permission to edit wallpapers", true);
    return;
  }

  const isEdit = !!existing;
  const initialName = existing?.name || "";
  const initialUrl = existing?.image || "";

  openModal(`
        <form id="wallform" novalidate>
            <div class="mh">
                <h3 id="mt">${isEdit ? "Edit" : "Add"} wallpaper</h3>
                <button type="button" class="x" data-act="close" aria-label="Close">${ic("x")}</button>
            </div>

            <div class="mf">
                <div class="full">
                    <label for="wf_name">Name <span class="rq">*</span></label>
                    <input class="in" id="wf_name" name="name" value="${esc(initialName)}" required autocomplete="off">
                </div>

                <div class="full">
                    <label>Image source</label>
                    <div style="display:flex;gap:8px;margin-bottom:10px" id="wf_mode_btns">
                        <button type="button" class="b3 on" data-mode="url"
                                style="flex:1;justify-content:center;background:var(--grad);color:#fff">
                            ${ic("globe")}Paste URL
                        </button>
                        <button type="button" class="b3" data-mode="file"
                                style="flex:1;justify-content:center">
                            ${ic("upload")}Upload file
                        </button>
                    </div>
                </div>

                <div class="full" id="wf_mode_url">
                    <label for="wf_url">Image URL <span class="rq">*</span></label>
                    <input class="in" id="wf_url" value="${esc(initialUrl)}" placeholder="https://…" autocomplete="off">
                    <div class="hint">${isEdit ? "Change to update the image, or leave as-is" : "Public image URL — from R2, imgbb, or any host"}</div>
                </div>

                <div class="full" id="wf_mode_file" style="display:none">
                    <label>Image file</label>
                    <input type="file" id="wf_file" accept="image/jpeg,image/png,image/webp" style="display:none">
                    <div id="wf_dropzone" style="
                        border: 2px dashed var(--or); border-radius: 14px; padding: 32px 20px;
                        text-align: center; cursor: pointer; transition: 0.2s;
                        background: rgba(255,255,255,0.4);
                    ">
                        <div class="ic" style="margin: 0 auto 10px; width: 44px; height: 44px">${ic("upload")}</div>
                        <b style="display: block; font-size: 14px; margin-bottom: 4px">Click to pick a file</b>
                        <small style="color: var(--mut); font-size: 12px">JPEG, PNG or WebP · max 10 MB</small>
                    </div>
                    <div id="wf_preview" style="margin-top:12px;display:none;text-align:center">
                        <img id="wf_preview_img" style="max-width:100%;max-height:200px;border-radius:12px">
                        <div style="margin-top:6px;font-size:11px;color:var(--mut)" id="wf_preview_meta"></div>
                    </div>
                </div>

                <div class="full" id="wf_status" style="font-size:12px;color:var(--mut);min-height:16px"></div>
            </div>

            <div class="err" id="wf_err" role="alert"></div>

            <div class="mfoot">
                <button type="button" class="b3" data-act="close">Cancel</button>
                <button class="btn" type="submit">
                    <span class="bt">${isEdit ? "Save" : "Create"}</span>
                    <span class="sp2"></span>
                </button>
            </div>
        </form>
    `);

  const errEl = $("#wf_err");
  const status = $("#wf_status");
  const fileInput = $("#wf_file");
  const dropzone = $("#wf_dropzone");
  const preview = $("#wf_preview");
  const previewImg = $("#wf_preview_img");
  const previewMeta = $("#wf_preview_meta");
  let previewObjectUrl = null;
  let mode = "url";

  // ---- Mode switcher ----
  $$("#wf_mode_btns .b3").forEach((b) => {
    b.addEventListener("click", () => {
      mode = b.dataset.mode;
      $$("#wf_mode_btns .b3").forEach((x) => {
        const on = x.dataset.mode === mode;
        x.classList.toggle("on", on);
        x.style.background = on ? "var(--grad)" : "";
        x.style.color = on ? "#fff" : "";
      });
      $("#wf_mode_url").style.display = mode === "url" ? "block" : "none";
      $("#wf_mode_file").style.display = mode === "file" ? "block" : "none";
    });
  });

  // ---- File picker ----
  dropzone.addEventListener("click", () => fileInput.click());
  dropzone.addEventListener("dragover", (e) => {
    e.preventDefault();
    dropzone.style.borderColor = "#16a34a";
    dropzone.style.background = "rgba(22,163,74,.08)";
  });
  dropzone.addEventListener("dragleave", () => {
    dropzone.style.borderColor = "var(--or)";
    dropzone.style.background = "rgba(255,255,255,0.4)";
  });
  dropzone.addEventListener("drop", (e) => {
    e.preventDefault();
    dropzone.style.borderColor = "var(--or)";
    dropzone.style.background = "rgba(255,255,255,0.4)";
    const f = e.dataTransfer?.files?.[0];
    if (f) {
      const dt = new DataTransfer();
      dt.items.add(f);
      fileInput.files = dt.files;
      showPreview(f);
    }
  });
  fileInput.addEventListener("change", () => {
    const f = fileInput.files?.[0];
    if (f) showPreview(f);
  });

  function showPreview(f) {
    if (previewObjectUrl) URL.revokeObjectURL(previewObjectUrl);
    if (!["image/jpeg", "image/png", "image/webp"].includes(f.type)) {
      errEl.textContent = "Only JPEG, PNG, or WebP allowed";
      preview.style.display = "none";
      return;
    }
    if (f.size > 10 * 1024 * 1024) {
      errEl.textContent = "Max file size is 10 MB";
      preview.style.display = "none";
      return;
    }
    errEl.textContent = "";
    previewObjectUrl = URL.createObjectURL(f);
    previewImg.src = previewObjectUrl;
    previewMeta.textContent = `${f.name} · ${(f.size / 1024).toFixed(0)} KB`;
    preview.style.display = "block";
  }

  // ---- Submit ----
  $("#wallform").onsubmit = async (e) => {
    e.preventDefault();
    const btn = $(".btn", e.target);
    errEl.textContent = "";
    status.textContent = "";

    const name = $("#wf_name").value.trim();
    if (!name) {
      errEl.textContent = "Name is required";
      $("#wf_name").focus();
      return;
    }

    btn.classList.add("load");
    btn.disabled = true;

    try {
      let imageUrl;

      if (mode === "url") {
        imageUrl = $("#wf_url").value.trim();
        if (!imageUrl) throw new Error("Image URL is required");
        if (!/^https?:\/\//i.test(imageUrl)) {
          throw new Error("Image URL must start with http:// or https://");
        }
      } else {
        // File mode → upload first, then use the returned URL
        const f = fileInput.files?.[0];
        if (!f) throw new Error("Choose a file to upload");

        status.textContent = "Uploading…";

        const form = new FormData();
        form.append("file", f);

        const res = await api.request("/wallpapers/upload-image", {
          method: "POST",
          body: form,
        });
        if (!res.ok) {
          let msg = `HTTP ${res.status}`;
          try {
            msg = (await res.json()).detail || msg;
          } catch {}
          throw new Error(msg);
        }

        const data = await res.json();
        imageUrl = data.url;
        status.textContent = "Uploaded — saving…";
      }

      // Create or update the row
      if (isEdit) {
        await api.patch(`/wallpapers/${existing.id}`, {
          name,
          image: imageUrl,
        });
      } else {
        await api.post("/wallpapers", { name, image: imageUrl });
      }

      if (previewObjectUrl) URL.revokeObjectURL(previewObjectUrl);
      closeModal();
      toast(isEdit ? "Saved" : "Created");
      await go("Wallpapers");
    } catch (err) {
      errEl.textContent = err.message || "Save failed";
      status.textContent = "";
    } finally {
      btn.classList.remove("load");
      btn.disabled = false;
    }
  };
}

// ============================================================================
// Reciters — proper page with audio preview
// ============================================================================
function stopAudio() {
  // Stop legacy preview audio (in case any reference remains)
  if (state.previewAudio) {
    try {
      state.previewAudio.pause();
    } catch {}
    state.previewAudio = null;
  }
  state.previewSlug = null;

  // Stop surah playback
  stopSurahAudio();
  resetSurahButtons();
}

function resetSurahButtons() {
  $$('[data-act="reciter-play-surah"]').forEach((b) => {
    b.innerHTML = ic("play");
    b.title = "Play";
  });
}

// ============================================================================
// Reciters — list + detail (surah playback)
// ============================================================================
async function recitersPage() {
  // If a reciter is selected, show the detail view
  if (state.reciterSlug) {
    return reciterDetailPage(state.reciterSlug);
  }

  const r = await apiCall(api.get("/reciters?limit=500"), {
    errorPrefix: "Load reciters",
  });
  const items = r.items || [];

  const head = `
        <div class="eh">
            <div class="ic">${ic("head")}</div>
            <div><h3>Reciters</h3><p>Quran audio &mdash; click a reciter to browse surahs</p></div>
            <button type="button" class="b2" data-act="crud-add" data-key="Reciters">${ic("plus")}Add reciter</button>
        </div>`;

  if (!items.length) {
    return `<div class="card glass s12">${head}
            <div class="empty">No reciters yet. Use the button above to add the first one.</div>
        </div>`;
  }

  const rows = items
    .map(
      (x) => `
        <tr data-slug="${esc(x.slug)}" data-id="${x.id}">
            <td>${esc(x.position ?? "—")}</td>
            <td>${esc(x.name)}</td>
            <td class="wrap">${esc(x.slug)}</td>
            <td>${esc(x.bitrate || "—")}</td>
            <td>${esc(x.total_ayahs ?? "—")}</td>
            <td>
                <span class="act-b">
                    <button type="button" title="View surahs"
                            data-act="reciter-view" data-slug="${esc(x.slug)}">${ic("book")}</button>
                    <button type="button" title="Edit"
                            data-act="crud-edit" data-key="Reciters" data-id="${x.id}">${ic("edit")}</button>
                    <button type="button" class="d" title="Delete"
                            data-act="crud-del" data-key="Reciters" data-id="${x.id}"
                            data-label="${esc(x.name)}">${ic("trash")}</button>
                </span>
            </td>
        </tr>`,
    )
    .join("");

  return `<div class="card glass s12">${head}
        <div class="tb">
            <div class="fld">${ic("search")}<input type="search" placeholder="Search reciters…" data-filter></div>
        </div>
        <div class="tw"><table>
            <thead><tr>
                <th>Position</th><th>Name</th><th>Slug</th><th>Bitrate</th><th>Ayahs</th><th>Action</th>
            </tr></thead>
            <tbody>${rows}</tbody>
        </table></div>
        <div class="foot">${items.length} total</div>
    </div>`;
}

async function reciterDetailPage(slug) {
  let data;
  try {
    data = await api.get(`/reciters/${encodeURIComponent(slug)}/surahs`);
  } catch (e) {
    return `<div class="card glass s12">
        <div class="empty">
            <p>Could not load surahs: ${esc(e.message || "request failed")}</p>
            <button type="button" class="b3" data-act="reciter-back" style="margin-top:14px">← Back to reciters</button>
        </div>
    </div>`;
  }

  const reciter = data.reciter || {};
  const surahs = data.surahs || [];

  const rows = surahs
    .map(
      (s) => `
        <tr>
            <td style="font-weight:700">${s.number}</td>
            <td class="rtl">${esc(s.arabic_name || `Surah ${s.number}`)}</td>
            <td>${s.verses_count}</td>
            <td>
                <span class="act-b">
                    <button type="button" title="Play surah"
                            data-act="reciter-play-surah"
                            data-slug="${esc(slug)}"
                            data-n="${s.number}">${ic("play")}</button>
                </span>
            </td>
        </tr>`,
    )
    .join("");

  const subtitle = [
    reciter.bitrate ? `${reciter.bitrate} kbps` : null,
    `${surahs.length} surahs`,
    reciter.total_ayahs
      ? `${reciter.total_ayahs.toLocaleString()} ayahs`
      : null,
  ]
    .filter(Boolean)
    .join(" · ");

  return `<div class="card glass s12">
        <div class="eh">
            <button type="button" class="b3" data-act="reciter-back" aria-label="Back to reciters">← Back</button>
            <div class="ic">${ic("head")}</div>
            <div style="flex:1">
                <h3>${esc(reciter.name || slug)}</h3>
                <p>${esc(subtitle)}</p>
            </div>
        </div>

        <div class="tb">
            <div class="fld">
                ${ic("search")}
                <input type="search" placeholder="Search surah…" data-filter>
            </div>
        </div>

        <div class="tw"><table>
            <thead><tr>
                <th>#</th><th>Surah</th><th>Verses</th><th>Play</th>
            </tr></thead>
            <tbody>${rows}</tbody>
        </table></div>

        <div class="foot">${surahs.length} surahs · click ▶ to play sequentially</div>
    </div>`;
}

// ============================================================================
// Gapless surah playback via Web Audio API
// ============================================================================

let _audioCtx = null;
function getAudioCtx() {
  if (!_audioCtx) {
    _audioCtx = new (window.AudioContext || window.webkitAudioContext)();
  }
  return _audioCtx;
}

function buildAyahUrl(sp, i) {
  return `${sp.host}/${sp.ayahList[i]}`;
}

async function fetchAyahBuffer(sp, i) {
  const url = buildAyahUrl(sp, i);
  const resp = await fetch(url, { mode: "cors" });
  if (!resp.ok) throw new Error(`HTTP ${resp.status} for ayah ${i + 1}`);
  const arr = await resp.arrayBuffer();
  return getAudioCtx().decodeAudioData(arr);
}

function resetPlayBtn(btn) {
  if (!btn) return;
  btn.innerHTML = ic("play");
  btn.title = "Play";
}

function stopSurahAudio() {
  const sp = state.surahPlayer;
  if (!sp) return;
  sp.cancelled = true;
  if (sp.sources) {
    for (const s of sp.sources) {
      try {
        s.stop();
      } catch {}
    }
  }
  state.surahPlayer = null;
}

async function playReciterSurah(slug, surahNum, btn) {
  // Same surah → pause / resume via AudioContext
  if (
    state.surahPlayer &&
    state.surahPlayer.slug === slug &&
    state.surahPlayer.surah === surahNum
  ) {
    const sp = state.surahPlayer;
    const ctx = sp.ctx;
    if (ctx.state === "running") {
      await ctx.suspend();
      btn.innerHTML = ic("play");
      btn.title = "Resume";
    } else {
      await ctx.resume();
      btn.innerHTML = ic("pause");
      btn.title = "Pause";
    }
    return;
  }

  // Different surah → stop old, start new
  stopSurahAudio();
  resetSurahButtons();

  btn.innerHTML = "…";
  btn.disabled = true;

  try {
    const r = await api.get(
      `/reciters/${encodeURIComponent(slug)}/surah/${surahNum}`,
    );
    if (!r.ayah_list || !r.ayah_list.length) {
      toast("No audio for this surah", true);
      btn.innerHTML = ic("play");
      btn.disabled = false;
      return;
    }

    const ctx = getAudioCtx();
    await ctx.resume(); // must be from user gesture

    state.surahPlayer = {
      slug,
      surah: surahNum,
      host: r.host.replace(/\/$/, ""),
      ayahList: r.ayah_list,
      index: 0,
      ctx,
      sources: [],
      nextStartTime: ctx.currentTime + 0.08,
      btn,
      cancelled: false,
    };
    btn.disabled = false;
    btn.innerHTML = ic("pause");
    btn.title = "Loading…";

    // Fire-and-forget: loads ayahs sequentially, schedules each one
    // to start exactly when the previous one ends.
    scheduleSurah(state.surahPlayer);
  } catch (e) {
    toast(e.message || "Play failed", true);
    btn.innerHTML = ic("play");
    btn.disabled = false;
  }
}

async function scheduleSurah(sp) {
  const ctx = sp.ctx;

  for (let i = 0; i < sp.ayahList.length; i++) {
    if (state.surahPlayer !== sp || sp.cancelled) return;

    let buffer;
    try {
      buffer = await fetchAyahBuffer(sp, i);
    } catch (e) {
      if (state.surahPlayer === sp) {
        toast(`Ayah ${i + 1} failed: ${e.message}`, true);
      }
      return;
    }
    if (state.surahPlayer !== sp || sp.cancelled) return;

    const source = ctx.createBufferSource();
    source.buffer = buffer;
    source.connect(ctx.destination);

    // Schedule at exactly `nextStartTime`. If we've fallen behind the
    // playback clock (slow network), snap forward so we don't stack up
    // ayahs that would all fire at once.
    const startAt = Math.max(sp.nextStartTime, ctx.currentTime + 0.02);
    source.start(startAt);
    sp.nextStartTime = startAt + buffer.duration;
    sp.sources.push(source);

    // UI: update button title when this ayah actually starts playing
    const startDelayMs = Math.max(0, (startAt - ctx.currentTime) * 1000);
    setTimeout(() => {
      if (state.surahPlayer !== sp) return;
      sp.index = i;
      if (sp.btn) {
        sp.btn.title = `Playing ayah ${i + 1} of ${sp.ayahList.length}`;
      }
    }, startDelayMs);

    // Last ayah → reset button when it finishes
    if (i === sp.ayahList.length - 1) {
      const endDelayMs = Math.max(
        0,
        (sp.nextStartTime - ctx.currentTime) * 1000,
      );
      setTimeout(() => {
        if (state.surahPlayer !== sp) return;
        state.surahPlayer = null;
        resetPlayBtn(sp.btn);
      }, endDelayMs);
    }
  }
}

async function playReciter(slug, btn) {
  // Toggle if same reciter playing
  if (state.previewAudio && state.previewSlug === slug) {
    stopAudio();
    return;
  }
  stopAudio();

  btn.innerHTML = "…";
  btn.disabled = true;

  try {
    const r = await api.get(`/reciters/${encodeURIComponent(slug)}/surah/1`);
    if (!r.ayah_list || !r.ayah_list.length) {
      toast("No audio for this reciter", true);
      btn.innerHTML = ic("play");
      btn.disabled = false;
      return;
    }
    const url = r.host.replace(/\/$/, "") + "/" + r.ayah_list[0];
    const audio = new Audio(url);
    state.previewAudio = audio;
    state.previewSlug = slug;

    const reset = () => {
      if (state.previewAudio === audio) {
        state.previewAudio = null;
        state.previewSlug = null;
        btn.innerHTML = ic("play");
        btn.title = "Play";
      }
    };
    audio.onended = reset;
    audio.onerror = () => {
      reset();
      toast("Could not play audio — check R2 sync", true);
    };

    await audio.play();
    btn.innerHTML = ic("pause");
    btn.title = "Pause";
    toast(
      `▶ ${r.reciter.name} — ${r.surah?.arabic_name || "Al-Fatihah"} (ayah 1)`,
    );
  } catch (e) {
    toast(e.message || "Preview failed", true);
    btn.innerHTML = ic("play");
  } finally {
    btn.disabled = false;
  }
}

// ============================================================================
// Prayer Times
// ============================================================================
const PRAYER_FIELDS = [
  "imsak",
  "fajr_start",
  "sunrise",
  "zuhr_start",
  "asr_start",
  "maghrib_start",
  "isha_start",
];
const PRAYER_LABELS = {
  imsak: "Imsak",
  fajr_start: "Fajr",
  sunrise: "Sunrise",
  zuhr_start: "Zuhr",
  asr_start: "Asr",
  maghrib_start: "Maghrib",
  isha_start: "Isha",
};

async function prayerTimesPage() {
  const cities = await ensureCities();

  // Resolve which city to use. Priority:
  //   1. Explicit user selection (state.prayerCityPage)
  //   2. Detected location matched to a curated city
  //   3. Previous dashboard selection
  //   4. FIRST city — but only as a "no location" placeholder, not silently
  let resolvedKey =
    state.prayerCityPage ||
    (state.detected && state.detected.city
      ? _matchCuratedCity(
          state.detected.city,
          state.detected.state,
          state.detected.country_code,
        )?.key
      : null) ||
    state.prayerCity ||
    null;

  // If nothing resolved and there are no cities, show an error
  if (!cities.length) {
    return `<div class="card glass s12">
      <div class="empty">
        ${ic("x")} No prayer time cities are configured on the server.<br>
        <small style="color:var(--mut);margin-top:8px;display:block">
          Ask an admin to seed cities or check <code>tools/cities.py</code>.
        </small>
      </div>
    </div>`;
  }

  // If nothing resolved, use first city but SHOW A BANNER warning
  const usedFallback = !resolvedKey;
  if (!resolvedKey) {
    resolvedKey = cities[0].key;
  }

  const defaultCity = resolvedKey;
  const year = state.prayerYear || new Date().getFullYear();
  const month = state.prayerMonth ?? new Date().getMonth();

  // Banner shown when we couldn't detect the user's location
  const noLocationBanner = usedFallback
    ? `<div class="card glass s12" style="margin-bottom:16px;border-left:4px solid var(--bad);background:rgba(255,240,235,0.5)">
      <div class="ch">
        <div class="ic" style="background:rgba(143,35,8,.15);color:var(--bad)">${ic("x")}</div>
        <div>
          <b style="color:var(--bad)">Showing "${esc(defaultCity)}" — that's not your detected location</b>
          <small>We couldn't match your location to a known city.</small>
        </div>
      </div>
      <div style="margin-top:10px;display:flex;gap:8px;flex-wrap:wrap">
        <button type="button" class="btn" data-act="dash-detect-loc">${ic("globe")}Detect my location</button>
        <button type="button" class="b3" data-act="go" data-p="Location">${ic("search")}Manual lookup</button>
      </div>
    </div>`
    : "";

  const head = `
    <div class="eh">
        <div class="ic">${ic("clock")}</div>
        <div><h3>Prayer Times</h3><p>${esc(defaultCity)} &middot; ${year}</p></div>
        <button type="button" class="b2" data-act="prayer-seed">${ic("plus")}Generate year</button>
    </div>
    <div class="tb" style="display:flex;flex-wrap:wrap;gap:14px;align-items:flex-end">
      <div style="display:flex;flex-direction:column;gap:6px;flex:1;min-width:180px;max-width:280px">
          <label for="pt-city" style="font-size:11px;font-weight:700;letter-spacing:.06em;text-transform:uppercase;color:var(--mut)">City</label>
          <select class="in sel" id="pt-city" data-change="prayer-city">
              ${cities.map((c) => `<option value="${esc(c.key)}"${c.key === defaultCity ? " selected" : ""}>${esc(c.name)}</option>`).join("")}
          </select>
      </div>
      <div style="display:flex;flex-direction:column;gap:6px;min-width:140px">
          <label for="pt-year" style="font-size:11px;font-weight:700;letter-spacing:.06em;text-transform:uppercase;color:var(--mut)">Year</label>
          <select class="in sel" id="pt-year" data-change="prayer-year">
              ${(() => {
                const ys = [];
                for (let y = 2000; y <= 2030; y++) ys.push(y);
                if (!ys.includes(year)) {
                  ys.push(year);
                  ys.sort((a, b) => a - b);
                }
                return ys
                  .map(
                    (y) =>
                      `<option value="${y}"${y === year ? " selected" : ""}>${y}</option>`,
                  )
                  .join("");
              })()}
          </select>
      </div>
    </div>
    <div class="months" role="tablist">
        ${Array.from(
          { length: 12 },
          (_, i) =>
            `<button type="button" role="tab" class="${i === month ? "on" : ""}" data-act="prayer-month" data-m="${i}">
                ${new Date(2000, i, 1).toLocaleDateString("en-IN", { month: "short" })}
            </button>`,
        ).join("")}
    </div>`;

  let items = [];
  try {
    const from = `${year}-01-01`;
    const to = `${year}-12-31`;
    const r = await api.get(
      `/prayer-times?city=${encodeURIComponent(defaultCity)}&from=${from}&to=${to}&limit=400`,
    );
    items = (r.items || []).filter((it) => {
      const m = parseInt((it.date || "").split("-")[1], 10) - 1;
      return m === month;
    });
  } catch (e) {
    toast("Load failed: " + e.message, true);
  }

  // Card: prayer times by coordinate — sits BELOW the table, always visible
  const coordCard = `
    <div class="card glass s12" style="margin-top:16px">
      <div class="ch">
        <div class="ic">${ic("globe")}</div>
        <div><b>Prayer times by coordinate</b><small>Any location — auto-computed &amp; cached</small></div>
      </div>
      <div class="fg2" style="margin-top:12px">
        <div><label for="ptc-lat">Latitude</label><input class="in" id="ptc-lat" type="number" step="any" placeholder="22.689772"></div>
        <div><label for="ptc-lon">Longitude</label><input class="in" id="ptc-lon" type="number" step="any" placeholder="72.855056"></div>
      </div>
      <div style="margin-top:10px;display:flex;gap:8px;flex-wrap:wrap">
        <button type="button" class="b3" data-act="pt-by-coord">${ic("clock")}Get times</button>
        <button type="button" class="b3" data-act="pt-use-my-loc">${ic("globe")}Use my location</button>
      </div>
      <div id="pt-coord-result" style="margin-top:12px"></div>
    </div>`;

  if (!items.length) {
    return `${noLocationBanner}<div class="card glass s12">${head}
            <div class="empty">
                No prayer times for this month.<br>
                <button class="b3" data-act="prayer-seed" style="margin-top:14px">${ic("plus")}Generate year ${year}</button>
            </div>
        </div>${coordCard}`;
  }

  const rows = items
    .map((it) => {
      const isFriday =
        it.is_friday === true || new Date(it.date + "T12:00:00").getDay() === 5;
      const zuhrCell = isFriday
        ? `<td><span class="pill warn">Jummah</span> ${esc(it.zuhr_start || "—")}</td>`
        : `<td>${esc(it.zuhr_start || "—")}</td>`;
      return `<tr${isFriday ? ' class="today"' : ""}>
            <td>${esc(it.date)}</td>
            <td>${esc(it.imsak || "—")}</td>
            <td>${esc(it.fajr_start || "—")}</td>
            <td>${esc(it.sunrise || "—")}</td>
            ${zuhrCell}
            <td>${esc(it.asr_start || "—")}</td>
            <td>${esc(it.maghrib_start || "—")}</td>
            <td>${esc(it.isha_start || "—")}</td>
            <td><span class="act-b">
                <button type="button" title="Edit" data-act="prayer-edit" data-id="${it.id}">${ic("edit")}</button>
            </span></td>
        </tr>`;
    })
    .join("");

  return `${noLocationBanner}<div class="card glass s12">${head}
        <div class="tw"><table>
            <thead><tr>
                <th>Date</th><th>Imsak</th><th>Fajr</th><th>Sunrise</th>
                <th>Zuhr / Jummah</th><th>Asr</th><th>Maghrib</th><th>Isha</th><th></th>
            </tr></thead>
            <tbody>${rows}</tbody>
        </table></div>
        <div class="foot">${items.length} days &middot; edit on Fridays to override jummah time</div>
    </div>${coordCard}`;
}

async function prayerEdit(id) {
  if (!can("prayer-times:write")) {
    toast("You don't have permission to edit prayer times", true);
    return;
  }
  const it = await apiCall(api.get(`/prayer-times/${id}`), {
    errorPrefix: "Load",
  });
  const fields = PRAYER_FIELDS.map((k) => ({
    k,
    l: PRAYER_LABELS[k],
    t: "text",
    h: "HH:MM (24-hour)",
  }));
  formModal({
    title: `Edit ${it.date}`,
    fields,
    data: it,
    onSubmit: async (vals) => {
      try {
        await api.patch(`/prayer-times/${id}`, vals);
        toast("Saved");
        await go("Prayer Times");
        return null;
      } catch (e) {
        return e.message || "Save failed";
      }
    },
  });
}

async function prayerSeed() {
  if (!can("prayer-times:write")) {
    toast("You don't have permission to generate prayer times", true);
    return;
  }
  const cities = await ensureCities();
  const city = state.prayerCityPage || state.prayerCity;
  const year = state.prayerYear || new Date().getFullYear();

  if (!city) {
    toast(
      "Pick a city first — we can't seed times for a location we don't know.",
      true,
    );
    return;
  }

  confirmBox({
    title: "Generate full year?",
    msg: `Generate 365 days of prayer times for ${city} in ${year}? Existing rows will be replaced.`,
    ok: "Generate",
    onOk: async () => {
      try {
        const r = await api.post("/prayer-times/seed", {
          city,
          year,
          replace: true,
        });
        toast(`Seeded ${r.inserted} days, skipped ${r.skipped}`);
        await go("Prayer Times");
      } catch (e) {
        toast(e.message || "Seed failed", true);
      }
    },
  });
}

// ============================================================================
// Profile helpers (avatar, password, autosave)
// ============================================================================
function settingsAvatarPick() {
  const input = $("#avatar-input");
  if (input) input.click();
}

async function settingsAvatarUpload(file) {
  if (!file) return;
  const form = new FormData();
  form.append("file", file);
  const ind = $("#autosave-ind");
  if (ind) ind.textContent = "Uploading…";
  try {
    const res = await api.request("/me/avatar", {
      method: "POST",
      body: form,
      headers: {}, // browser sets multipart boundary
    });
    if (!res.ok) {
      let msg = `HTTP ${res.status}`;
      try {
        msg = (await res.json()).detail || msg;
      } catch {}
      throw new Error(msg);
    }
    state.me = await res.json();
    applyUserHeader();
    if (ind) {
      ind.textContent = "Uploaded";
      ind.style.color = "var(--ok)";
    }
    toast("Avatar updated");
    await go("Settings");
  } catch (e) {
    toast(e.message || "Avatar upload failed", true);
    if (ind) {
      ind.textContent = "Upload failed";
      ind.style.color = "var(--bad)";
    }
  }
}

async function settingsAvatarClear() {
  confirmBox({
    title: "Remove avatar?",
    msg: "Your profile picture will be removed. You can upload a new one anytime.",
    onOk: async () => {
      try {
        state.me = await api.del("/me/avatar");
        applyUserHeader();
        toast("Avatar removed");
        await go("Settings");
      } catch (e) {
        toast(e.message, true);
      }
    },
  });
}

async function openPasswordModal() {
  formModal({
    title: "Change password",
    fields: [
      {
        k: "current_password",
        l: "Current password",
        t: "password",
        req: 1,
        full: 1,
      },
      {
        k: "new_password",
        l: "New password",
        t: "password",
        req: 1,
        full: 1,
        h: "Minimum 6 characters",
      },
      {
        k: "confirm",
        l: "Confirm new password",
        t: "password",
        req: 1,
        full: 1,
      },
    ],
    onSubmit: async (vals) => {
      if (vals.new_password !== vals.confirm) {
        return "Passwords do not match";
      }
      try {
        await api.post("/me/password", {
          current_password: vals.current_password,
          new_password: vals.new_password,
        });
        toast("Password changed — please log in again", false);
        setTimeout(() => api.logout(), 1200);
        return null;
      } catch (e) {
        return e.message || "Change failed";
      }
    },
  });
}

// Auto-save for profile name fields
let _profileSaveTimer = null;
function scheduleProfileSave() {
  clearTimeout(_profileSaveTimer);
  _profileSaveTimer = setTimeout(flushProfileSave, 800);
}

async function flushProfileSave() {
  const fn = $("#pn")?.value?.trim() ?? "";
  const ln = $("#pln")?.value?.trim() ?? "";
  const ind = $("#autosave-ind");
  if (ind) ind.textContent = "Saving…";
  try {
    state.me = await api.patch("/me", {
      first_name: fn || null,
      last_name: ln || null,
    });
    applyUserHeader();
    if (ind) {
      ind.textContent = "Saved";
      ind.style.color = "var(--ok)";
      setTimeout(() => {
        if (ind) ind.textContent = "";
      }, 1200);
    }
  } catch (e) {
    toast(e.message || "Save failed", true);
    if (ind) {
      ind.textContent = "Save failed";
      ind.style.color = "var(--bad)";
    }
  }
}

// Stub for the (now unused) settings autosave branch
function scheduleSettingsSave() {
  // No-op — settings page is profile-only now
}

async function refreshMe() {
  try {
    state.me = await api.get("/me");
  } catch {
    state.me = state.user;
  }
  return state.me;
}

// ============================================================================
// Settings
// ============================================================================
// ============================================================================
// Settings — admin profile only
// ============================================================================
async function settingsPage() {
  await refreshMe();
  const me = state.me || state.user || {};

  // Load security settings (2fa_enabled). Default to "on" if unset.
  let twoFa = "true";
  try {
    const r = await api.get("/settings/2fa_enabled");
    if (r && r.value != null) twoFa = String(r.value).toLowerCase();
  } catch (e) {
    // 404 = not set yet → default "true" matches backend default
    if (e && !String(e.message || "").includes("404")) {
      // Network error — leave default
    }
  }
  const twoFaOn = ["1", "true", "yes", "on"].includes(twoFa);
  const isProd = api.config && api.config.env === "production";
  // In production, show a locked state but still render (backend rejects the toggle)

  const head = `
        <div class="eh">
            <div class="ic">${ic("user")}</div>
            <div><h3>Profile</h3><p>Your account settings</p></div>
            <small id="autosave-ind" style="margin-left:auto;font-size:12px;font-weight:600;color:var(--mut)"></small>
        </div>`;

  const fullName = [me.first_name, me.last_name]
    .filter(Boolean)
    .join(" ")
    .trim();
  const initialsStr =
    (fullName || me.email || "A")
      .trim()
      .split(/\s+/)
      .map((w) => w[0])
      .slice(0, 2)
      .join("")
      .toUpperCase() || "A";
  const avatarHtml = me.avatar
    ? `<img src="${esc(me.avatar)}" alt="">`
    : esc(initialsStr);

  return `<div class="card glass s12">${head}
        <div class="pav" style="margin-bottom:16px">
            <div class="big" id="avBig">${avatarHtml}</div>
            <div>
                <b>Profile photo</b>
                <small>PNG, JPG or WebP · max 5 MB</small>
                <div class="row-btns" style="margin-top:10px">
                    <button type="button" class="b3" data-act="avatar-pick">${ic("upload")}Upload</button>
                    ${me.avatar ? `<button type="button" class="b3" data-act="avatar-clear">${ic("trash")}Remove</button>` : ""}
                    <input type="file" id="avatar-input" accept="image/jpeg,image/png,image/webp" hidden>
                </div>
            </div>
        </div>

        <div class="fg2">
            <div>
                <label for="pn">First name</label>
                <input class="in" id="pn" data-autosave value="${esc(me.first_name || "")}" autocomplete="given-name">
            </div>
            <div>
                <label for="pln">Last name</label>
                <input class="in" id="pln" data-autosave value="${esc(me.last_name || "")}" autocomplete="family-name">
            </div>
            <div class="full">
                <label for="pe">Email</label>
                <input class="in" id="pe" type="email" value="${esc(me.email || "")}" disabled>
                <div class="hint">Email cannot be changed from the panel</div>
            </div>
        </div>

        <div class="row-btns" style="justify-content:flex-end;margin-top:12px">
            <button type="button" class="b3" data-act="password-open">${ic("shield")}Change password</button>
        </div>

        <div class="err" id="serr" role="alert"></div>
    </div>

    <div class="card glass s12" style="margin-top:16px" id="security-card">
        <div class="eh">
            <div class="ic">${ic("lock")}</div>
            <div><h3>Security</h3><p>Controls for admin logins</p></div>
        </div>

        <div class="fg2" style="margin-top:4px">
            <div class="full">
                <label>Require 2FA for admin logins</label>
                <div style="display:flex;align-items:center;gap:14px;padding:14px 16px;background:rgba(255,255,255,0.55);border:1px solid var(--line);border-radius:14px">
                    <button type="button"
                        id="tf-toggle"
                        class="tf-switch ${twoFaOn ? "on" : "off"}"
                        data-act="toggle-2fa"
                        aria-pressed="${twoFaOn ? "true" : "false"}"
                        aria-label="Toggle 2FA"
                        ${isProd && twoFaOn ? 'title="This setting is locked in production"' : ""}>
                        <span class="tf-knob"></span>
                    </button>
                    <div style="flex:1">
                        <b style="display:block;font-size:14px">${twoFaOn ? "Enabled" : "Disabled"}</b>
                        <small style="color:var(--mut);font-size:12px">
                            ${
                              twoFaOn
                                ? "A 6-digit code will be emailed on every sign-in."
                                : "Admins sign in with just a password. Not recommended."
                            }
                            ${isProd ? "<br><b style='color:var(--or)'>Locked in production — this toggle will not disable 2FA.</b>" : ""}
                        </small>
                    </div>
                </div>
                <div class="hint">
                    Changing this takes effect on the <b>next login</b>. Existing sessions are not affected.
                </div>
            </div>
        </div>

        <div class="err" id="tf-err" role="alert"></div>
    </div>`;
}
// ============================================================================
// Stubs
// ============================================================================
async function uploadsPage() {
  // Fetch existing wallpapers so users see what's already there
  let existing = [];
  try {
    const r = await api.get("/wallpapers?limit=24");
    existing = r.items || [];
  } catch {}

  const head = `
        <div class="eh">
            <div class="ic">${ic("upload")}</div>
            <div><h3>Uploads</h3><p>Upload images directly to R2 &mdash; they appear immediately in the app</p></div>
        </div>`;

  return `<div class="card glass s12">${head}
        <div id="upload-zone" style="
            border: 2px dashed var(--or); border-radius: 16px; padding: 40px 20px;
            text-align: center; cursor: pointer; transition: 0.2s;
            background: rgba(255,255,255,0.4);
        ">
            <div class="ic" style="margin: 0 auto 14px; width: 56px; height: 56px">
                ${ic("upload")}
            </div>
            <b style="display: block; font-size: 16px; margin-bottom: 6px">Drop files here or click to browse</b>
            <small style="color: var(--mut); font-size: 13px">
                JPEG, PNG or WebP &middot; max 10 MB each &middot; multiple files allowed
            </small>
            <input type="file" id="upload-input" accept="image/jpeg,image/png,image/webp"
                   multiple style="display: none">
        </div>

        <div id="upload-queue" style="margin-top: 18px; display: none">
            <div class="ch" style="margin-bottom: 10px">
                <div class="ic">${ic("check")}</div>
                <div><b>Upload queue</b><small id="queue-summary"></small></div>
                <button type="button" class="b2" data-act="upload-start" id="upload-start">
                    ${ic("upload")}Upload all
                </button>
            </div>
            <div id="upload-list" style="display: flex; flex-direction: column; gap: 8px"></div>
        </div>

        <div class="ch" style="margin-top: 24px">
            <div class="ic">${ic("img")}</div>
            <div><b>Recent uploads</b><small>${existing.length} image${existing.length === 1 ? "" : "s"} in library</small></div>
            <button type="button" class="b3" data-act="go" data-p="Wallpapers">
                ${ic("img")}Manage wallpapers
            </button>
        </div>
        ${
          existing.length
            ? `<div class="wg" style="margin-top: 14px">
            ${existing
              .map(
                (w) => `
                <div class="wp" style="background:linear-gradient(160deg,#ffa03f,#7a2a05)">
                    ${w.image ? `<img src="${esc(w.image)}" alt="${esc(w.name)}" loading="lazy">` : ""}
                    <span class="n">${esc(w.name)}</span>
                </div>
            `,
              )
              .join("")}
        </div>`
            : `<div class="empty" style="margin-top: 14px">
            No wallpapers yet. Upload the first one above.
        </div>`
        }
    </div>`;
}

// Attach file handlers when the uploads page renders
const _uploadQueue = [];

function initUploadsPage() {
  const zone = $("#upload-zone");
  const input = $("#upload-input");
  if (!zone || !input) return;

  zone.onclick = () => input.click();
  zone.ondragover = (e) => {
    e.preventDefault();
    zone.style.borderColor = "#16a34a";
  };
  zone.ondragleave = () => {
    zone.style.borderColor = "var(--or)";
  };
  zone.ondrop = (e) => {
    e.preventDefault();
    zone.style.borderColor = "var(--or)";
    if (e.dataTransfer?.files?.length) enqueueFiles([...e.dataTransfer.files]);
  };
  input.onchange = () => {
    if (input.files?.length) enqueueFiles([...input.files]);
    input.value = "";
  };

  renderUploadQueue();
}

function enqueueFiles(files) {
  for (const f of files) {
    if (!["image/jpeg", "image/png", "image/webp"].includes(f.type)) {
      toast(`${f.name}: only JPEG, PNG, WebP allowed`, true);
      continue;
    }
    if (f.size > 10 * 1024 * 1024) {
      toast(`${f.name}: max 10 MB`, true);
      continue;
    }
    _uploadQueue.push({
      file: f,
      status: "pending",
      id: Math.random().toString(36).slice(2, 8),
    });
  }
  renderUploadQueue();
}

function renderUploadQueue() {
  const wrap = $("#upload-queue");
  const list = $("#upload-list");
  const summary = $("#queue-summary");
  const startBtn = $("#upload-start");
  if (!wrap || !list) return;

  wrap.style.display = _uploadQueue.length ? "block" : "none";
  if (summary) {
    const pending = _uploadQueue.filter((x) => x.status === "pending").length;
    const done = _uploadQueue.filter((x) => x.status === "done").length;
    const failed = _uploadQueue.filter((x) => x.status === "error").length;
    summary.textContent = `${_uploadQueue.length} file(s) · ${done} done · ${failed} failed · ${pending} pending`;
  }
  if (startBtn) {
    startBtn.style.display = _uploadQueue.some((x) => x.status === "pending")
      ? "flex"
      : "none";
  }

  list.innerHTML = _uploadQueue
    .map((item) => {
      const badge = {
        pending: `<span class="pill off">pending</span>`,
        uploading: `<span class="pill">uploading…</span>`,
        done: `<span class="pill ok">done</span>`,
        error: `<span class="pill" style="background:#8f2308">error</span>`,
      }[item.status];
      const err = item.error
        ? `<small style="color:var(--bad);display:block;margin-top:4px">${esc(item.error)}</small>`
        : "";
      return `<div style="display:flex;align-items:center;gap:12px;padding:10px 12px;
                             background:rgba(255,255,255,0.6);border-radius:12px;border:1px solid var(--line)">
            <div style="flex:1;min-width:0">
                <b style="font-size:13px;display:block;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${esc(item.file.name)}</b>
                <small style="color:var(--mut);font-size:11px">${(item.file.size / 1024).toFixed(0)} KB</small>
                ${err}
            </div>
            ${badge}
            ${
              item.status === "pending"
                ? `<button type="button" class="act-b d"
                    data-act="upload-remove" data-id="${item.id}" title="Remove"
                    style="width:32px;height:32px;border-radius:10px">${ic("x")}</button>`
                : ""
            }
        </div>`;
    })
    .join("");
}

async function uploadStart() {
  const pending = _uploadQueue.filter((x) => x.status === "pending");
  if (!pending.length) return toast("Nothing to upload", true);

  let ok = 0,
    fail = 0;

  for (const item of pending) {
    item.status = "uploading";
    renderUploadQueue();
    try {
      const form = new FormData();
      form.append("file", item.file);
      form.append("name", item.file.name.replace(/\.[^.]+$/, ""));

      const res = await api.request("/wallpapers/upload", {
        method: "POST",
        body: form,
        headers: {}, // do NOT set Content-Type — browser sets boundary
      });
      if (!res.ok) {
        let msg = `HTTP ${res.status}`;
        try {
          msg = (await res.json()).detail || msg;
        } catch {}
        throw new Error(msg);
      }
      item.status = "done";
      ok++;
    } catch (e) {
      item.status = "error";
      item.error = e.message || "Upload failed";
      fail++;
    }
    renderUploadQueue();
  }

  toast(`${ok} uploaded${fail ? `, ${fail} failed` : ""}`, fail > 0);
  if (ok > 0) {
    // Refresh page to show new thumbnails
    setTimeout(() => go("Uploads"), 600);
  }
}

// Build the permission-grid HTML for the modal
function _rolePermGridHtml(catalog, selectedCodes) {
  const selected = new Set(selectedCodes || []);
  const titleCase = (s) =>
    s.replace(/[-_]/g, " ").replace(/\b\w/g, (c) => c.toUpperCase());

  return Object.keys(catalog.groups || {})
    .sort()
    .map((group) => {
      const codes = catalog.groups[group];
      const groupChecked = codes.every((c) => selected.has(c));
      return `
        <div style="margin-bottom:14px" class="perm-group">
          <div style="display:flex;align-items:center;gap:8px;margin-bottom:8px">
            <input type="checkbox" id="pg_${esc(group)}"
              data-group="${esc(group)}" ${groupChecked ? "checked" : ""}
              style="cursor:pointer">
            <label for="pg_${esc(group)}"
              style="cursor:pointer;font-size:12px;font-weight:700;letter-spacing:.06em;text-transform:uppercase;color:var(--mut)">
              ${esc(titleCase(group))}
            </label>
          </div>
          <div style="display:flex;flex-wrap:wrap;gap:6px;padding-left:26px">
            ${codes
              .map(
                (code) => `
                  <label class="role-chip"
                    style="display:inline-flex;align-items:center;gap:6px;padding:6px 10px;border-radius:8px;background:rgba(255,255,255,0.7);border:1px solid var(--line);cursor:pointer;font-size:12px">
                    <input type="checkbox" name="__perm" value="${esc(code)}"
                      data-group="${esc(group)}"
                      ${selected.has(code) ? "checked" : ""}
                      style="margin:0;cursor:pointer">
                    <span>${esc(code.split(":")[1] || code)}</span>
                  </label>`,
              )
              .join("")}
          </div>
        </div>`;
    })
    .join("");
}

function _wireRolePermGrid() {
  const form = $("#mform");
  if (!form) return;
  $$('#mform input[data-group][id^="pg_"]').forEach((grpCb) => {
    grpCb.addEventListener("change", () => {
      const g = grpCb.dataset.group;
      $$(`#mform input[name="__perm"][data-group="${g}"]`).forEach(
        (cb) => (cb.checked = grpCb.checked),
      );
    });
  });
  // Child toggles → update group checkbox
  $$('#mform input[name="__perm"]').forEach((cb) => {
    cb.addEventListener("change", () => {
      const g = cb.dataset.group;
      const siblings = $$(`#mform input[name="__perm"][data-group="${g}"]`);
      const allOn = siblings.every((s) => s.checked);
      const grp = $(`#mform input[id="pg_${g}"]`);
      if (grp) grp.checked = allOn;
    });
  });
}

// Open the modal in create mode (or edit if `existing` is passed)
async function openRoleForm(existing) {
  if (!can("roles:write")) {
    toast("You don't have permission to manage roles", true);
    return;
  }

  let catalog;
  try {
    catalog = await api.get("/roles/permissions/catalog");
  } catch (e) {
    toast("Could not load permission catalogue: " + e.message, true);
    return;
  }

  const isEdit = !!existing;
  const initialCodes = (existing?.permissions || []).slice();

  formModal({
    title: isEdit ? `Edit role: ${existing.name}` : "Create role",
    fields: [
      {
        k: "name",
        l: "Role name",
        req: 1,
        full: 1,
        h: "e.g. Content Manager, Moderator",
      },
      {
        k: "description",
        l: "Description",
        full: 1,
        h: "Optional. Short summary shown in the Roles page.",
      },
    ],
    data: existing || {},
    okLabel: isEdit ? "Save changes" : "Create role",
    onSubmit: async (vals) => {
      const permissions = $$('#mform input[name="__perm"]:checked').map(
        (cb) => cb.value,
      );
      if (!permissions.length) {
        return "Pick at least one permission.";
      }
      try {
        if (isEdit) {
          await api.patch(`/roles/${existing.id}`, {
            name: vals.name,
            description: vals.description || null,
            permissions,
          });
          toast(
            `Role "${vals.name}" updated (${permissions.length} permissions)`,
          );
        } else {
          await api.post("/roles", {
            name: vals.name,
            description: vals.description || null,
            permissions,
            is_admin: true,
            is_default: false,
          });
          toast(
            `Role "${vals.name}" created (${permissions.length} permissions)`,
          );
        }
        api.cache.invalidate("roles");
        state.roles = null;
        await go("Roles");
        return null;
      } catch (e) {
        return e.message || "Save failed";
      }
    },
  });

  // Inject permission grid after form renders
  setTimeout(() => {
    const form = $("#mform");
    if (!form) return;
    const block = document.createElement("div");
    block.className = "full";
    block.style.marginTop = "4px";
    block.innerHTML = `
      <label style="display:block;margin-bottom:8px;font-size:12px;font-weight:700;letter-spacing:.06em;text-transform:uppercase;color:var(--mut)">
        Permissions <span style="color:var(--mut);font-weight:500;text-transform:none;letter-spacing:0">(${initialCodes.length} pre-selected)</span>
      </label>
      <div style="max-height:380px;overflow:auto;padding:10px;background:rgba(255,255,255,0.55);border-radius:14px;border:1px solid var(--line)">
        ${_rolePermGridHtml(catalog, initialCodes)}
      </div>
      <div style="margin-top:10px;display:flex;gap:8px;flex-wrap:wrap">
        <button type="button" class="b3" data-act="role-perms-all">${ic("check")}Select all</button>
        <button type="button" class="b3" data-act="role-perms-none">${ic("x")}Clear</button>
      </div>
    `;
    form.querySelector(".mf").appendChild(block);
    _wireRolePermGrid();
  }, 20);
}

// Delete a role with confirmation + safety check on user_count
function confirmDeleteRole(id, name, userCount) {
  if (!can("roles:write")) {
    toast("You don't have permission to delete roles", true);
    return;
  }
  confirmBox({
    title: `Delete role "${name}"?`,
    msg:
      userCount > 0
        ? `This role is assigned to ${userCount} admin${userCount === 1 ? "" : "s"}. They will lose these permissions on next request. This cannot be undone.`
        : `This role has no assigned users. Deletion is safe.`,
    ok: "Delete",
    onOk: async () => {
      try {
        await api.del(`/roles/${id}`);
        toast(`Role "${name}" deleted`);
        api.cache.invalidate("roles");
        state.roles = null;
        await go("Roles");
      } catch (e) {
        toast(e.message || "Delete failed", true);
      }
    },
  });
}

// ============================================================================
// Roles page
// ============================================================================
async function rolesPage() {
  // Load catalogue + roles in parallel
  let roles = [];
  let catalog = { groups: {}, all: [] };
  try {
    [roles, catalog] = await Promise.all([
      api.get("/roles"),
      api.get("/roles/permissions/catalog"),
    ]);
  } catch (e) {
    return `<div class="card glass s12">
      <div class="empty">${ic("x")} ${esc(e.message || "Failed to load roles")}</div>
    </div>`;
  }

  const canWrite = can("roles:write");

  const head = `
    <div class="eh">
      <div class="ic">${ic("roles")}</div>
      <div>
        <h3>Roles</h3>
        <p>${roles.length} role${roles.length === 1 ? "" : "s"} · permissions granted to admins</p>
      </div>
      ${
        canWrite
          ? `<button type="button" class="b2" data-act="role-create">${ic("plus")}New role</button>`
          : ""
      }
    </div>`;

  if (!roles.length) {
    return `<div class="card glass s12">${head}
      <div class="empty">
        No roles yet. ${canWrite ? `Click <b>New role</b> to create the first one.` : `Ask a Super Admin to create one.`}
      </div>
    </div>`;
  }

  // --- Table ---
  const rows = roles
    .map((r) => {
      const permCount = (r.permissions || []).length;
      const pill = r.is_default
        ? `<span class="pill ok">default</span>`
        : r.is_admin
          ? `<span class="pill">admin</span>`
          : `<span class="pill off">user</span>`;

      return `<tr data-id="${r.id}">
        <td>#${r.id}</td>
        <td><b>${esc(r.name)}</b></td>
        <td>${r.description ? esc(r.description) : `<span style="color:var(--mut)">—</span>`}</td>
        <td>${pill}</td>
        <td><b>${permCount}</b> / ${catalog.all.length}</td>
        <td>${r.user_count || 0}</td>
        <td>
          <span class="act-b">
            ${
              canWrite
                ? `<button type="button" title="Edit permissions"
                     data-act="role-edit-perms" data-id="${r.id}">
                     ${ic("edit")}
                   </button>`
                : ""
            }
            ${
              canWrite && !r.is_default
                ? `<button type="button" class="d" title="Delete"
                     data-act="role-delete" data-id="${r.id}"
                     data-name="${esc(r.name)}"
                     data-users="${r.user_count || 0}">
                     ${ic("trash")}
                   </button>`
                : ""
            }
          </span>
        </td>
      </tr>`;
    })
    .join("");

  return `<div class="card glass s12">${head}
    <div class="tb">
      <div class="fld">
        ${ic("search")}
        <input type="search" placeholder="Search roles…" data-filter>
      </div>
    </div>
    <div class="tw"><table>
      <thead><tr>
        <th>ID</th><th>Name</th><th>Description</th>
        <th>Type</th><th>Permissions</th><th>Users</th><th>Actions</th>
      </tr></thead>
      <tbody>${rows}</tbody>
    </table></div>
    <div class="foot">${roles.length} total</div>
  </div>`;
}

// ============================================================================
// Page registry
// ============================================================================
const PAGE_RENDERERS = {
  Dashboard: dashboardPage,
  Administrators: () => crudPage("Administrators"),
  Roles: rolesPage, // ← ADD
  "Prayer Times": prayerTimesPage,
  Reciters: recitersPage,
  Duas: () => crudPage("Duas"),
  Dhikrs: () => crudPage("Dhikrs"),
  Wallpapers: wallpapersPage,
  "Sifat Names": () => crudPage("Sifat Names"),
  "Haram Codes": () => crudPage("Haram Codes"),
  // Translators: () => crudPage("Translators"),
  Uploads: uploadsPage,
  Settings: settingsPage,
  Backup: backupPage,
  Sync: syncPage,
  "Dhikr Campaigns": dhikrCampaignsPage,
  Devices: devicesPage,
  Invitations: invitationsPage,
  // Location: locationPage,
};

// ============================================================================
// Location lookup
// ============================================================================
// async function locationPage() {
//   return `
//     <div class="card glass s12">
//       <div class="eh">
//         <div class="ic">${ic("globe")}</div>
//         <div><h3>Location Lookup</h3><p>Reverse-geocode any coordinate, get prayer times</p></div>
//       </div>

//       <div class="fg2" style="margin-top:16px">
//         <div>
//           <label for="loc-lat">Latitude</label>
//           <input class="in" id="loc-lat" type="number" step="any" placeholder="22.689772">
//         </div>
//         <div>
//           <label for="loc-lon">Longitude</label>
//           <input class="in" id="loc-lon" type="number" step="any" placeholder="72.855056">
//         </div>
//       </div>

//       <div style="margin-top:12px;display:flex;gap:10px;flex-wrap:wrap">
//         <button type="button" class="btn" data-act="loc-lookup">${ic("search")}Reverse-lookup</button>
//         <button type="button" class="b3" data-act="loc-prayer">${ic("clock")}Prayer times here</button>
//         <button type="button" class="b3" data-act="loc-my-ip">${ic("globe")}Use my IP</button>
//       </div>

//       <div id="loc-result" style="margin-top:18px"></div>
//       <div id="loc-prayer-result" style="margin-top:18px"></div>
//     </div>`;
// }

async function doLocLookup() {
  const latEl = $("#loc-lat");
  const lonEl = $("#loc-lon");
  const out = $("#loc-result");
  if (!latEl || !lonEl || !out) return;

  const lat = parseFloat(latEl.value);
  const lon = parseFloat(lonEl.value);
  if (Number.isNaN(lat) || Number.isNaN(lon)) {
    toast("Enter valid lat/lon", true);
    return;
  }

  out.innerHTML = `<div class="empty">${ic("refresh")}Looking up…</div>`;

  try {
    const d = await api.get(`/location/get?lat=${lat}&lon=${lon}`);

    // ── NEW: save detected location ──
    state.detected = {
      lat,
      lon,
      city: d.city,
      state: d.state,
      country: d.country,
      country_code: d.country_code,
      postcode: d.postcode,
      formatted_address: d.formatted_address,
      source: d.source,
      cached: d.cached,
    };

    // ── NEW: match to nearest curated city (for prayer times) ──
    const match = _matchCuratedCity(d.city, d.state, d.country_code);

    out.innerHTML = `
      <div class="card glass s12" style="background:rgba(255,255,255,0.4)">
        <div class="fg2">
          <div><label>City</label><b>${esc(d.city || "—")}</b></div>
          <div><label>State</label><b>${esc(d.state || "—")}</b></div>
          <div><label>Country</label><b>${esc(d.country || "—")}</b></div>
          <div><label>Postcode</label><b>${esc(d.postcode || "—")}</b></div>
          <div class="full"><label>Coordinates</label><b>${lat.toFixed(6)}, ${lon.toFixed(6)}</b></div>
          <div class="full"><label>Formatted</label><b>${esc(d.formatted_address || "—")}</b></div>
          <div class="full">
            <label>Cache</label>
            <b>${d.cached ? `<span class="pill ok">cached</span>` : `<span class="pill warn">fresh</span>`} · source: ${esc(d.source || "—")}</b>
          </div>
          ${
            match
              ? `<div class="full"><label>Auto-matched city</label><b>${esc(match.name)} <span class="pill ok">will use for prayer times</span></b></div>`
              : `<div class="full"><label>Auto-matched city</label><b style="color:var(--mut)">No curated city found — prayer times will be computed on the fly</b></div>`
          }
        </div>
        <div style="margin-top:12px;display:flex;gap:8px;flex-wrap:wrap">
          ${
            match
              ? `<button type="button" class="btn" data-act="apply-city" data-city="${esc(match.key)}">${ic("check")}Use ${esc(match.name)} for prayer times</button>`
              : `<button type="button" class="btn" data-act="apply-detected">${ic("clock")}Use this location for prayer times</button>`
          }
        </div>
      </div>`;
  } catch (e) {
    out.innerHTML = `<div class="empty">${ic("x")} ${esc(e.message || "Lookup failed")}</div>`;
  }
}

function _matchCuratedCity(city, stateName, countryCode) {
  if (!city || !state.prayerCityList) return null;
  const needle = city.toLowerCase().trim();
  return (
    state.prayerCityList.find((c) => {
      // Match against city key or name
      const key = c.key.toLowerCase();
      const name = c.name.toLowerCase();
      return (
        key === needle ||
        name === needle ||
        name.startsWith(needle) ||
        needle.startsWith(name)
      );
    }) || null
  );
}

async function doLocPrayer() {
  const latEl = $("#loc-lat");
  const lonEl = $("#loc-lon");
  const out = $("#loc-prayer-result");
  if (!latEl || !lonEl || !out) return;

  const lat = parseFloat(latEl.value);
  const lon = parseFloat(lonEl.value);
  if (Number.isNaN(lat) || Number.isNaN(lon)) {
    toast("Enter valid lat/lon", true);
    return;
  }

  out.innerHTML = `<div class="empty">${ic("refresh")}Computing prayer times…</div>`;

  try {
    const d = await api.get(`/prayer-times/for-location?lat=${lat}&lon=${lon}`);
    const t = d.timings || {};
    out.innerHTML = `
      <div class="card glass s12" style="background:rgba(255,255,255,0.4)">
        <div class="ch" style="margin-bottom:12px">
          <div class="ic">${ic("clock")}</div>
          <div>
            <b>${esc(d.city_name || "Computed location")}</b>
            <small>${esc(d.date)} · ${esc(d.source)}${d.cached ? " (cached)" : ""}</small>
          </div>
        </div>
        <div class="tw"><table>
          <thead><tr>
            <th>Imsak</th><th>Fajr</th><th>Sunrise</th><th>Dhuhr</th>
            <th>Asr</th><th>Sunset</th><th>Maghrib</th><th>Isha</th>
          </tr></thead>
          <tbody><tr>
            <td>${esc(t.imsak || "—")}</td>
            <td><b>${esc(t.fajr || "—")}</b></td>
            <td>${esc(t.sunrise || "—")}</td>
            <td><b>${esc(t.dhuhr || "—")}</b></td>
            <td>${esc(t.asr || "—")}</td>
            <td>${esc(t.sunset || "—")}</td>
            <td><b>${esc(t.maghrib || "—")}</b></td>
            <td><b>${esc(t.isha || "—")}</b></td>
          </tr></tbody>
        </table></div>
        ${d.is_friday ? `<div style="margin-top:10px"><span class="pill warn">Friday (Jummah)</span></div>` : ""}
      </div>`;
  } catch (e) {
    out.innerHTML = `<div class="empty">${ic("x")} ${esc(e.message || "Prayer times failed")}</div>`;
  }
}

async function doMyIp() {
  const out = $("#loc-result");
  if (out)
    out.innerHTML = `<div class="empty">${ic("refresh")}Resolving your IP…</div>`;
  try {
    const d = await api.get("/location/get");
    if (d.lat != null) {
      const latEl = $("#loc-lat");
      const lonEl = $("#loc-lon");
      if (latEl) latEl.value = d.lat;
      if (lonEl) lonEl.value = d.lon;
    }
    await doLocLookup();
    // Auto-apply the matched city
    if (state.detected && state.detected.city) {
      const match = _matchCuratedCity(
        state.detected.city,
        state.detected.state,
        state.detected.country_code,
      );
      if (match) {
        state.prayerCity = match.key;
        state.prayerCityPage = match.key;
      }
    }
  } catch (e) {
    if (out)
      out.innerHTML = `<div class="empty">${ic("x")} ${esc(e.message || "IP lookup failed")}</div>`;
  }
}

async function backupPage() {
  const head = `
        <div class="eh">
            <div class="ic">${ic("down")}</div>
            <div><h3>Backup</h3><p>Local JSON export and server-side database backups</p></div>
            <button type="button" class="b2" data-act="backup-run">${ic("refresh")}Run backup now</button>
        </div>`;

  let status = null;
  let backups = [];
  try {
    const [st, list] = await Promise.all([
      api.get("/admin/backup/status").catch(() => null),
      api.get("/admin/backup").catch(() => ({ count: 0, backups: [] })),
    ]);
    status = st;
    backups = list.backups || [];
  } catch {}

  // Hero card — status
  const statusCard = status
    ? `
        <div class="card glass s12" style="margin-top:16px">
            <div class="ch"><div class="ic">${ic("check")}</div>
                <div><b>Backup status</b><small>Server-side MySQL dump + logs to R2</small></div>
            </div>
            <div class="fg2" style="margin-top:12px">
                <div><label>Auto backup</label><b>${status.scheduler_enabled ? "Enabled · " + status.scheduled_time + " IST" : "Disabled"}</b></div>
                <div><label>Next run</label><b>${status.next_run_at || "—"}</b></div>
                <div><label>Last run</label><b>${status.last_run_at || "Never"}</b>${status.last_run_status ? `<span class="pill ${status.last_run_status === "success" ? "ok" : "off"}" style="margin-left:8px">${status.last_run_status}</span>` : ""}</div>
                <div><label>Total backups</label><b>${status.total_local_backups} local · ${status.total_r2_backups} on R2</b></div>
                ${status.newest_local_backup ? `<div class="full"><label>Newest</label><code style="font-size:12px">${esc(status.newest_local_backup)}</code></div>` : ""}
                ${status.oldest_local_backup ? `<div class="full"><label>Oldest</label><code style="font-size:12px">${esc(status.oldest_local_backup)}</code></div>` : ""}
            </div>
        </div>`
    : "";

  // Backup list
  const listCard = `
        <div class="card glass s12" style="margin-top:16px">
            <div class="ch"><div class="ic">${ic("book")}</div>
                <div><b>Backup history</b><small>${backups.length} file${backups.length === 1 ? "" : "s"}</small></div>
            </div>
            ${
              backups.length
                ? `
                <div class="tw"><table>
                    <thead><tr><th>Filename</th><th>Size</th><th>Created</th><th>Location</th><th>Actions</th></tr></thead>
                    <tbody>
                        ${backups
                          .map(
                            (b) => `
                            <tr>
                                <td><code style="font-size:12px">${esc(b.filename)}</code></td>
                                <td>${b.size_mb.toFixed(2)} MB</td>
                                <td>${esc(b.created_at || "")}</td>
                                <td><span class="pill ${b.source === "both" ? "" : b.source === "r2" ? "ok" : "off"}">${esc(b.source)}</span></td>
                                <td><span class="act-b">
                                    <button type="button" title="Restore" data-act="backup-restore" data-filename="${esc(b.filename)}">${ic("refresh")}</button>
                                </span></td>
                            </tr>
                        `,
                          )
                          .join("")}
                    </tbody>
                </table></div>
            `
                : `<div class="empty">No backups yet. Click "Run backup now" to create one.</div>`
            }
        </div>`;

  // Actions card
  const actionsCard = `
        <div class="card glass s12" style="margin-top:16px">
            <div class="ch"><div class="ic">${ic("down")}</div>
                <div><b>Export options</b><small>Download or trigger</small></div>
            </div>
            <div style="display:flex;gap:12px;flex-wrap:wrap;margin-top:12px">
                <button type="button" class="b3" data-act="backup-export">${ic("down")}Export JSON (content)</button>
                <button type="button" class="b3" data-act="backup-run">${ic("refresh")}Run DB backup (SQL + logs)</button>
            </div>
            <div class="hint" style="margin-top:10px">
                JSON export contains duas, dhikrs, wallpapers, reciters, translators and settings.<br>
                DB backup runs <code>scripts/backup.sh</code> server-side — dumps MySQL, uploads to R2, keeps 30 days.
            </div>
        </div>`;

  return `<div class="card glass s12">${head}${statusCard}${listCard}${actionsCard}</div>`;
}

// ============================================================================
// Sync — Quran audio → R2 (background job with live log tail)
// ============================================================================
const _syncState = {
  jobId: null,
  logOffset: 0,
  statusTimer: null,
  logTimer: null,
  attachedStatus: null,
};

function _syncStopTimers() {
  if (_syncState.statusTimer) {
    clearInterval(_syncState.statusTimer);
    _syncState.statusTimer = null;
  }
  if (_syncState.logTimer) {
    clearInterval(_syncState.logTimer);
    _syncState.logTimer = null;
  }
}

function _syncFmtBytes(n) {
  n = Number(n) || 0;
  if (n < 1024) return n + " B";
  if (n < 1024 ** 2) return (n / 1024).toFixed(0) + " KB";
  if (n < 1024 ** 3) return (n / 1024 ** 2).toFixed(1) + " MB";
  return (n / 1024 ** 3).toFixed(2) + " GB";
}

function _syncStatusBadge(status) {
  const map = {
    queued: `<span class="pill off">queued</span>`,
    running: `<span class="pill">running</span>`,
    stopping: `<span class="pill warn">stopping…</span>`,
    stopped: `<span class="pill off">stopped</span>`,
    done: `<span class="pill ok">done</span>`,
    failed: `<span class="pill" style="background:#8f2308;color:#fff">failed</span>`,
    interrupted: `<span class="pill warn">interrupted</span>`,
  };
  return map[status] || `<span class="pill off">${esc(status)}</span>`;
}

function _syncRenderStatus(job) {
  const el = $("#sync-status-body");
  if (!el) return;

  if (!job) {
    el.innerHTML = `<div class="empty">No job yet. Click <b>Start sync</b> to download and upload every ayah for all reciters.</div>`;
    return;
  }

  const total = job.total || 0;
  const done = job.processed || 0;
  const pct = total > 0 ? Math.min(100, Math.round((done / total) * 100)) : 0;
  const isLive = ["queued", "running", "stopping"].includes(job.status);

  const progressBar = isLive
    ? `<div style="height:10px;background:rgba(130,60,10,.12);border-radius:999px;overflow:hidden;margin:12px 0">
         <div style="height:100%;width:${pct}%;background:var(--grad);transition:width .35s ease"></div>
       </div>`
    : "";

  el.innerHTML = `
    <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap">
      <b>Job #${job.id}</b> ${_syncStatusBadge(job.status)}
      <small style="color:var(--mut);margin-left:auto">
        ${job.started_at ? "started " + esc(job.started_at) : ""}
        ${job.finished_at ? " · finished " + esc(job.finished_at) : ""}
      </small>
    </div>
    ${progressBar}
    <div class="sync-meta">
      <div><label>Progress</label><b>${done.toLocaleString()} / ${total.toLocaleString()} (${pct}%)</b></div>
      <div><label>Uploaded</label><b>${(job.uploaded || 0).toLocaleString()}</b></div>
      <div><label>Skipped</label><b>${(job.skipped || 0).toLocaleString()}</b></div>
      <div><label>Failed</label><b>${(job.failed || 0).toLocaleString()}</b></div>
      <div><label>Bytes</label><b>${_syncFmtBytes(job.bytes_done)}</b></div>
      <div><label>Current</label><b>${esc(job.current_file || "—")}</b></div>
      ${job.reciters ? `<div class="full"><label>Reciters</label><b>${esc((job.reciters || []).join(", ") || "(all)")}</b></div>` : ""}
      ${job.message ? `<div class="full"><label>Message</label><b>${esc(job.message)}</b></div>` : ""}
      ${job.error ? `<div class="full"><label>Error</label><b style="color:#8f2308">${esc(job.error)}</b></div>` : ""}
    </div>`;
}

function _syncSetButtons(running) {
  const s = $("#sync-btn-start");
  const t = $("#sync-btn-stop");
  if (s) s.disabled = !!running;
  if (t) t.style.display = running ? "inline-flex" : "none";
}

let _syncTerminalBuffer = "";

function _syncAppendLog(text) {
  if (!text) return;
  const pre = $("#sync-log");
  if (!pre) return;

  const atBottom = pre.scrollTop + pre.clientHeight >= pre.scrollHeight - 24;

  // Append the new chunk to our master buffer
  _syncTerminalBuffer += text;

  // Parse the buffer to apply terminal rules (\n = new line, \r = reset line)
  let lines = _syncTerminalBuffer.split("\n");
  let parsedLines = [];

  for (let i = 0; i < lines.length; i++) {
    let line = lines[i];
    // If the line contains \r, only keep the text AFTER the last \r
    if (line.includes("\r")) {
      const parts = line.split("\r");
      line = parts[parts.length - 1];
    }
    parsedLines.push(line);
  }

  // Don't render the very last empty line yet (it's waiting for text)
  const currentText = parsedLines.join("\n");

  // Only update DOM if text actually changed to save CPU
  if (pre.textContent !== currentText) {
    pre.textContent = currentText;
    if (atBottom) pre.scrollTop = pre.scrollHeight;
  }
}

async function _syncFetchStatus() {
  try {
    const r = await api.get("/admin/sync/ayah/status");
    const active = r.active || null;
    const job = active || r.last || null;
    _syncRenderStatus(job);

    if (active) {
      _syncState.jobId = active.id;
      _syncSetButtons(active.status !== "stopping");
      return active;
    }
    _syncState.jobId = null;
    _syncSetButtons(false);
    return null;
  } catch (e) {
    return null;
  }
}

async function _syncFetchLogs(jobId) {
  if (!jobId) return null;
  try {
    const r = await api.get(
      `/admin/sync/ayah/logs?job_id=${jobId}&offset=${_syncState.logOffset}`,
    );
    if (r.exists && r.chunk) {
      _syncAppendLog(r.chunk);
    }
    _syncState.logOffset = r.next_offset;
    return r;
  } catch {
    return null;
  }
}

async function _syncTick() {
  const active = await _syncFetchStatus();

  // If there is a job (active or last), tail its logs.
  let jobId = active?.id ?? _syncState.jobId;
  if (!jobId) {
    // Fall back to the last job's id so the log pane isn't empty on reload
    try {
      const r = await api.get("/admin/sync/ayah/status");
      if (r.last) jobId = r.last.id;
    } catch {}
  }
  if (jobId) await _syncFetchLogs(jobId);

  if (!active) {
    _syncStopTimers();
  }
}

function _syncStartPolling() {
  _syncStopTimers();
  // Immediate one-shot so the UI is populated before the first interval fires.
  _syncTick();
  _syncState.statusTimer = setInterval(_syncTick, 2000);
}

async function syncPage() {
  // Reset UI state — but DO NOT start a new job.
  _syncStopTimers();
  _syncState.jobId = null;
  _syncState.logOffset = 0;
  _syncTerminalBuffer = ""; // <-- ADD THIS

  // const pre = $("#sync-log");
  // if (pre) pre.textContent = "";

  return `
    <div class="card glass s12">
      <div class="eh">
        <div class="ic">${ic("refresh")}</div>
        <div style="flex:1">
          <h3>Sync Quran audio</h3>
          <p>Download every ayah from EveryAyah and upload to R2. Safe to stop — it resumes from where it left off.</p>
        </div>
        <div style="display:flex;gap:10px;flex-wrap:wrap;align-items:center">
          <button type="button" class="b2" id="sync-btn-start" data-act="sync-start">${ic("play")}Start sync</button>
          <button type="button" class="b3" id="sync-btn-stop" data-act="sync-stop" style="display:none;color:var(--bad)">${ic("pause")}Stop</button>
          <button type="button" class="b3" data-act="sync-refresh" title="Refresh status">${ic("refresh")}</button>
        </div>
      </div>

      <div class="ch" style="margin-top:18px;margin-bottom:10px">
        <div class="ic" style="background:rgba(130,60,10,.1)">${ic("clock")}</div>
        <div><b>Job status</b><small>Auto-refreshes while a job is running</small></div>
      </div>
      <div id="sync-status-body" style="background:rgba(255,255,255,0.4);border:1px solid var(--line);border-radius:14px;padding:16px;min-height:100px">
        <div class="empty">Loading…</div>
      </div>

      <div class="ch" style="margin-top:22px;margin-bottom:10px">
        <div class="ic" style="background:rgba(130,60,10,.1)">${ic("book")}</div>
        <div><b>Log</b><small>Live tail of the runner output</small></div>
        <button type="button" class="b3" data-act="sync-scroll-bottom" style="margin-left:auto">↓ Follow</button>
      </div>
      <pre id="sync-log" style="
        margin:0;padding:14px 16px;border-radius:14px;
        background:#1b130d;color:#fde4c2;
        font:12px/1.55 ui-monospace,Menlo,Consolas,monospace;
        max-height:440px;overflow:auto;white-space:pre-wrap;word-break:break-word;
        border:1px solid rgba(255,160,63,.2);
      "></pre>
    </div>`;
}

async function syncStartAction() {
  if (!can("sync:write")) {
    toast("You don't have permission to start sync jobs", true);
    return;
  }
  try {
    const r = await api.post("/admin/sync/ayah/start", {});
    toast(
      r.attached ? `Attached to job #${r.job_id}` : `Started job #${r.job_id}`,
    );
    _syncState.logOffset = 0;
    _syncTerminalBuffer = ""; // <-- ADD THIS
    const pre = $("#sync-log");
    if (pre) pre.textContent = "";
    _syncStartPolling();
  } catch (e) {
    toast(e.message || "Start failed", true);
  }
}

async function syncStopAction() {
  if (!can("sync:write")) {
    toast("You don't have permission to stop sync jobs", true);
    return;
  }
  try {
    await api.post("/admin/sync/ayah/stop", {});
    toast("Stop requested — job will halt after the current ayah");
    _syncStartPolling();
  } catch (e) {
    toast(e.message || "Stop failed", true);
  }
}

function backupRestoreConfirm(filename) {
  if (!can("backup:write")) {
    toast("You don't have permission to restore backups", true);
    return;
  }
  confirmBox({
    title: "Restore database backup?",
    msg: `"${filename}" will replace ALL current data. This cannot be undone. Type RESTORE in the prompt below.`,
    ok: "Continue",
    onOk: async () => {
      const typed = prompt("Type RESTORE to confirm:");
      if (typed !== "RESTORE") return toast("Cancelled", true);
      try {
        const r = await api.post("/admin/backup/restore", {
          filename,
          confirm: "RESTORE",
        });
        toast(`Restore started: ${r.status}`);
      } catch (e) {
        toast(e.message || "Restore failed", true);
      }
    },
  });
}

function backupRunNow() {
  if (!can("backup:write")) {
    toast("You don't have permission to run backups", true);
    return;
  }
  confirmBox({
    title: "Run database backup?",
    msg: "This runs scripts/backup.sh server-side and uploads the SQL dump to R2. Takes 5-15 seconds.",
    ok: "Run",
    onOk: async () => {
      try {
        const r = await api.post("/admin/backup");
        toast(
          `Backup created: ${r.filename} (${(r.size_bytes / 1024).toFixed(0)} KB)`,
        );
        await go("Backup");
      } catch (e) {
        toast(e.message || "Backup failed", true);
      }
    },
  });
}

// ============================================================================
// Event delegation
// ============================================================================
document.addEventListener("click", async (e) => {
  if (e.target.id === "modal") return closeModal();
  const el = e.target.closest("[data-act]");
  if (!el) return;
  if (el.disabled) return;
  const act = el.dataset.act;
  if (el.tagName === "A") e.preventDefault();

  try {
    switch (act) {
      case "role-create":
        await openRoleForm(null);
        break;
      case "toggle-time-fmt": {
        const next = _timeFmt === "12" ? "24" : "12";
        setTimeFmt(next);
        toast(`Time format: ${next}-hour`);
        // Re-render current page so all times update everywhere
        await go(state.page);
        break;
      }
      case "role-edit-perms": {
        const id = parseInt(el.dataset.id, 10);
        try {
          const roles = await api.get("/roles");
          const existing = roles.find((r) => r.id === id);
          if (!existing) {
            toast("Role not found", true);
            break;
          }
          await openRoleForm(existing);
        } catch (e) {
          toast(e.message || "Could not load role", true);
        }
        break;
      }

      case "role-delete": {
        const id = parseInt(el.dataset.id, 10);
        const name = el.dataset.name || "role";
        const userCount = parseInt(el.dataset.users || "0", 10);
        confirmDeleteRole(id, name, userCount);
        break;
      }

      case "role-perms-all":
        $$('#mform input[name="__perm"]').forEach((cb) => (cb.checked = true));
        $$('#mform input[id^="pg_"]').forEach((cb) => (cb.checked = true));
        break;

      case "role-perms-none":
        $$('#mform input[name="__perm"]').forEach((cb) => (cb.checked = false));
        $$('#mform input[id^="pg_"]').forEach((cb) => (cb.checked = false));
        break;
      case "dash-detect-loc": {
        try {
          await detectLocationFromBrowser();
          await go("Dashboard");
        } catch {}
        break;
      }
      case "admin-reinvite": {
        const id = parseInt(el.dataset.id, 10);
        const email = el.dataset.email || "this admin";
        const wasPending = el.dataset.pending === "true";
        confirmBox({
          title: wasPending ? "Resend invitation?" : "Re-invite this admin?",
          msg: wasPending
            ? `A fresh invitation will be sent to "${email}". Their current pending invite will be replaced.`
            : `A new invitation will be sent to "${email}". Their current sessions will be invalidated until they accept the invite and set a password again.`,
          ok: wasPending ? "Resend" : "Re-invite",
          onOk: async () => {
            try {
              await api.post(`/admin/invitations/reinvite/${id}`, {});
              toast(
                wasPending
                  ? "Invitation resent"
                  : "Re-invite sent — status set to pending",
              );
              await go("Administrators");
            } catch (e) {
              toast(e.message || "Re-invite failed", true);
            }
          },
        });
        break;
      }
      case "toggle-2fa": {
        const btn = el;
        const errEl = $("#tf-err");
        if (errEl) errEl.textContent = "";

        const currentlyOn = btn.classList.contains("on");
        const target = currentlyOn ? "false" : "true";
        if (!can("settings:write")) {
          api.toast("You don't have permission to change this setting", true);
          break;
        }

        btn.disabled = true;
        btn.style.opacity = "0.6";
        try {
          await api.put("/settings/2fa_enabled", { value: target });

          // Flip the visual state
          btn.classList.toggle("on", target === "true");
          btn.classList.toggle("off", target === "false");
          btn.setAttribute(
            "aria-pressed",
            target === "true" ? "true" : "false",
          );

          // Update the label + helper text without a full re-render
          const labelEl = btn.parentElement.querySelector("b");
          const hintEl = btn.parentElement.querySelector("small");
          if (labelEl)
            labelEl.textContent = target === "true" ? "Enabled" : "Disabled";
          if (hintEl) {
            const prodNote = hintEl.innerHTML.includes("Locked in production")
              ? "<br><b style='color:var(--or)'>Locked in production — this toggle will not disable 2FA.</b>"
              : "";
            hintEl.innerHTML =
              (target === "true"
                ? "A 6-digit code will be emailed on every sign-in."
                : "Admins sign in with just a password. Not recommended.") +
              prodNote;
          }

          api.cache.invalidate("settings");
          api.toast(target === "true" ? "2FA enabled" : "2FA disabled");
        } catch (e) {
          // Backend refused (likely production lock)
          const msg = e.message || "Could not update 2FA setting";
          if (errEl) errEl.textContent = msg;
          api.toast(msg, true);
        } finally {
          btn.disabled = false;
          btn.style.opacity = "";
        }
        break;
      }
      case "dash-refresh-loc": {
        // Force a fresh fix — bypass cache
        localStorage.removeItem(LOCATION_CACHE_KEY);
        state.detected = null;
        try {
          await detectLocationFromBrowser();
          await go(state.page);
        } catch {}
        break;
      }
      case "pt-use-my-loc": {
        try {
          const { coords } = await detectLocationFromBrowser();
          const latEl = $("#ptc-lat");
          const lonEl = $("#ptc-lon");
          if (latEl) latEl.value = coords.lat;
          if (lonEl) lonEl.value = coords.lon;
          // Trigger the coordinate lookup
          const btn = $('[data-act="pt-by-coord"]');
          if (btn) btn.click();
        } catch {}
        break;
      }
      case "pt-by-coord": {
        const latEl = $("#ptc-lat");
        const lonEl = $("#ptc-lon");
        const out = $("#pt-coord-result");
        if (!latEl || !lonEl || !out) break;
        const lat = parseFloat(latEl.value);
        const lon = parseFloat(lonEl.value);
        if (Number.isNaN(lat) || Number.isNaN(lon)) {
          toast("Enter valid coords", true);
          break;
        }
        out.innerHTML = `<div class="empty">${ic("refresh")}Fetching…</div>`;
        try {
          const d = await api.get(
            `/prayer-times/for-location?lat=${lat}&lon=${lon}`,
          );
          const t = d.timings || {};
          out.innerHTML = `
            <div class="tw"><table style="font-size:13px">
              <tr><td>Fajr</td><td><b>${esc(t.fajr || "—")}</b></td></tr>
              <tr><td>Sunrise</td><td>${esc(t.sunrise || "—")}</td></tr>
              <tr><td>Dhuhr</td><td><b>${esc(t.dhuhr || "—")}</b></td></tr>
              <tr><td>Asr</td><td>${esc(t.asr || "—")}</td></tr>
              <tr><td>Maghrib</td><td><b>${esc(t.maghrib || "—")}</b></td></tr>
              <tr><td>Isha</td><td><b>${esc(t.isha || "—")}</b></td></tr>
            </table>
            <small style="color:var(--mut);display:block;margin-top:6px">
              ${esc(d.city_name || "")} · ${esc(d.source)}${d.cached ? " (cached)" : ""}
            </small>`;
        } catch (e) {
          out.innerHTML = `<div class="empty">${ic("x")} ${esc(e.message)}</div>`;
        }
        break;
      }
      case "go": {
        const p = el.dataset.p;
        await go(p);
        if (el.dataset.then === "add" && CRUD[p]) {
          await openCrudForm(p, null);
        } else if (el.dataset.then === "add" && p === "Wallpapers") {
          openWallForm(null);
        } else if (el.dataset.then === "add" && p === "Reciters") {
          await openCrudForm("Reciters", null);
        }
        break;
      }
      case "menu":
        setMenu(!menuIsOpen());
        break;
      case "close":
        closeModal();
        break;
      case "loc-lookup":
        await doLocLookup();
        break;
      case "loc-prayer":
        await doLocPrayer();
        break;
      case "loc-my-ip":
        await doMyIp();
        break;
      case "confirm": {
        const cb = modalCtx?.onOk;
        closeModal();
        if (cb) await cb();
        break;
      }
      // Devices
      case "device-view":
        await showUserDevices(parseInt(el.dataset.uid, 10));
        break;
      case "device-revoke": {
        const uid = parseInt(el.dataset.uid, 10);
        const uuid = el.dataset.uuid;
        confirmBox({
          title: "Revoke this device?",
          msg: "Blocked from re-registering. Existing token stays valid until it expires.",
          ok: "Revoke",
          onOk: async () => {
            try {
              await api.post(`/administrators/${uid}/devices/${uuid}/revoke`);
              toast("Device revoked");
              await showUserDevices(uid);
            } catch (e) {
              toast(e.message || "Revoke failed", true);
            }
          },
        });
        break;
      }
      case "invite-open":
        await openInviteForm();
        break;

      case "invite-resend": {
        try {
          await api.post(`/admin/invitations/${el.dataset.id}/resend`, {});
          toast("Invitation resent");
          await go("Invitations");
        } catch (e) {
          toast(e.message || "Resend failed", true);
        }
        break;
      }

      case "invite-revoke": {
        const id = el.dataset.id;
        const email = el.dataset.email || "this email";
        confirmBox({
          title: "Revoke this invitation?",
          msg: `The invitation sent to "${email}" will be cancelled. They will get a cancellation email and won't be able to use the link.`,
          ok: "Revoke",
          onOk: async () => {
            try {
              await api.del(`/admin/invitations/${id}`);
              toast("Invitation revoked");
              await go("Invitations");
            } catch (e) {
              toast(e.message || "Revoke failed", true);
            }
          },
        });
        break;
      }
      case "role-refresh": {
        state.roles = null;
        api.cache.invalidate("roles");
        const roles = await ensureRoles();
        const box = $("#roles-box");
        if (!box) break;
        const checked = new Set(
          $$('#mform input[type="checkbox"][name^="__role_"]:checked').map(
            (cb) => parseInt(cb.value, 10),
          ),
        );
        box.innerHTML = roles.length
          ? roles
              .map(
                (r) => `
            <label class="role-chip" style="display:inline-flex;align-items:center;gap:6px;padding:8px 12px;border-radius:10px;background:rgba(255,255,255,0.75);border:1px solid var(--line);cursor:pointer;font-size:13px">
              <input type="checkbox" name="__role_${r.id}" value="${r.id}" ${checked.has(r.id) ? "checked" : ""} style="margin:0;cursor:pointer">
              <span>${esc(r.name)}</span>
            </label>`,
              )
              .join("")
          : `<small style="color:var(--mut);font-size:12px">No roles exist yet — click "+ New role" to create the first one.</small>`;
        toast(`Reloaded ${roles.length} role${roles.length === 1 ? "" : "s"}`);
        break;
      }
      case "apply-city": {
        const cityKey = el.dataset.city;
        state.prayerCity = cityKey;
        state.prayerCityPage = cityKey;
        toast(`Prayer times will use "${cityKey}"`);
        await doLocPrayer();
        break;
      }
      case "apply-detected": {
        // No curated match — use the coordinates directly
        await doLocPrayer();
        toast("Prayer times computed for this exact location");
        break;
      }

      // Dhikr
      case "dhikr-tab":
        _dhikrState.tab = el.dataset.tab;
        await go("Dhikr Campaigns");
        break;
      case "dhikr-add":
        await openCampaignForm(null);
        break;
      case "dhikr-edit": {
        const all = await api.get("/admin/dhikr/campaigns");
        const found = all.find((x) => x.id === parseInt(el.dataset.id, 10));
        if (found) await openCampaignForm(found);
        break;
      }
      case "dhikr-toggle":
        try {
          await api.post(`/admin/dhikr/campaigns/${el.dataset.id}/toggle`);
          toast("Campaign toggled");
          await go("Dhikr Campaigns");
        } catch (e) {
          toast(e.message, true);
        }
        break;
      case "dhikr-delete": {
        const campaignId = el.dataset.id;
        const title = el.dataset.title;
        confirmBox({
          title: `Delete "${title}"?`,
          msg: "This is permanent. If the campaign has submissions, it cannot be deleted — disable it instead.",
          onOk: async () => {
            try {
              await api.del(`/admin/dhikr/campaigns/${campaignId}`);
              toast("Campaign deleted");
              await go("Dhikr Campaigns");
            } catch (e) {
              // Detect the "cannot delete, has submissions" case
              let errDetail = null;
              try {
                // api.del throws Error with a string message; try to recover structure
                // from the raw response if the api helper preserved it
                errDetail = e.raw || null;
              } catch {}

              // Fallback: inspect the message text
              const msg = String(e.message || "");

              if (msg.includes("has") && msg.includes("submission")) {
                // Show a follow-up modal offering "Disable instead"
                openModal(
                  `<div class="mh">
                    <h3>Cannot delete this campaign</h3>
                    <button type="button" class="x" data-act="close">${ic("x")}</button>
                  </div>
                  <p class="msg" style="padding:16px 22px;margin:0">
                    ${esc(msg)}<br><br>
                    You can still <b>disable</b> it to stop new submissions while
                    keeping all existing records intact.
                  </p>
                  <div class="mfoot">
                    <button type="button" class="b3" data-act="close">Cancel</button>
                    <button type="button" class="btn"
                      data-act="dhikr-disable"
                      data-id="${campaignId}">
                      ${ic("pause")}Disable instead
                    </button>
                  </div>`,
                  true,
                );
              } else {
                toast(msg || "Delete failed", true);
              }
            }
          },
        });
        break;
      }

      case "dhikr-disable": {
        const campaignId = el.dataset.id;
        closeModal();
        try {
          // Toggle to inactive — only if currently active
          const all = await api.get("/admin/dhikr/campaigns");
          const found = all.find((c) => c.id === parseInt(campaignId, 10));
          if (found && found.is_active) {
            await api.post(`/admin/dhikr/campaigns/${campaignId}/toggle`);
          }
          toast("Campaign disabled — submissions preserved");
          await go("Dhikr Campaigns");
        } catch (e) {
          toast(e.message || "Disable failed", true);
        }
        break;
      }
      case "dhikr-handle":
      case "dhikr-reject": {
        const id = parseInt(el.dataset.id, 10);
        const targetStatus = act === "dhikr-handle" ? "handled" : "rejected";
        try {
          await api.patch(`/admin/dhikr/submissions/${id}`, {
            status: targetStatus,
          });
          toast(`Marked as ${targetStatus}`);
          await go("Dhikr Campaigns");
        } catch (e) {
          toast(e.message, true);
        }
        break;
      }
      case "logout":
        await api.logout();
        break;
      case "reload":
        await go(state.page);
        break;
      case "crud-add":
        await openCrudForm(el.dataset.key, null);
        break;
      case "crud-edit":
        await openCrudForm(el.dataset.key, parseInt(el.dataset.id, 10));
        break;
      case "crud-del":
        confirmDelete(
          el.dataset.key,
          parseInt(el.dataset.id, 10),
          el.dataset.label || "item",
        );
        break;
      case "wall-add":
        openWallForm(null);
        break;
      case "wall-preview":
        await wallPreview(parseInt(el.dataset.id, 10));
        break;
      case "wall-edit": {
        e.stopPropagation();
        const id = parseInt(el.dataset.id, 10);
        const w = await api.get(`/wallpapers/${id}`);
        openWallForm(w);
        break;
      }
      case "upload-start":
        await uploadStart();
        break;
      case "upload-remove": {
        const idx = _uploadQueue.findIndex((x) => x.id === el.dataset.id);
        if (idx >= 0) _uploadQueue.splice(idx, 1);
        renderUploadQueue();
        break;
      }
      case "wall-del": {
        e.stopPropagation();
        confirmBox({
          title: "Delete wallpaper?",
          msg: `"${el.dataset.label}" will be permanently deleted.`,
          onOk: async () => {
            try {
              await api.del(`/wallpapers/${el.dataset.id}`);
              toast("Deleted");
              await go("Wallpapers");
            } catch (err) {
              toast(err.message, true);
            }
          },
        });
        break;
      }
      case "avatar-pick":
        settingsAvatarPick();
        break;
      case "avatar-clear":
        await settingsAvatarClear();
        break;
      case "password-open":
        await openPasswordModal();
        break;
      case "backup-run":
        backupRunNow();
        break;
      case "backup-restore":
        backupRestoreConfirm(el.dataset.filename);
        break;
      case "sync-start":
        await syncStartAction();
        break;
      case "sync-stop":
        await syncStopAction();
        break;
      case "sync-refresh":
        _syncState.logOffset = 0;
        const pre = $("#sync-log");
        if (pre) pre.textContent = "";
        _syncStartPolling();
        break;
      case "sync-scroll-bottom": {
        const preEl = $("#sync-log");
        if (preEl) preEl.scrollTop = preEl.scrollHeight;
        break;
      }
      case "role-create-open":
        roleCreateModal();
        break;
      case "reciter-view":
        state.reciterSlug = el.dataset.slug;
        await go("Reciters");
        break;
      case "reciter-back":
        state.reciterSlug = null;
        stopSurahAudio();
        resetSurahButtons();
        await go("Reciters");
        break;
      case "reciter-play-surah":
        await playReciterSurah(el.dataset.slug, parseInt(el.dataset.n, 10), el);
        break;
      case "prayer-edit":
        await prayerEdit(parseInt(el.dataset.id, 10));
        break;
      case "prayer-seed":
        await prayerSeed();
        break;
      case "prayer-month":
        state.prayerMonth = parseInt(el.dataset.m, 10);
        await go("Prayer Times");
        break;
    }
  } catch (err) {
    toast(err.message || "Action failed", true);
  }
});

// Filter input
document.addEventListener("input", (e) => {
  const x = e.target;

  // Auto-save: settings
  if (x.matches("[data-setting][data-autosave]")) {
    scheduleSettingsSave();
    return;
  }
  // Auto-save: profile name fields
  if (x.id === "pn" || x.id === "pln") {
    scheduleProfileSave();
    return;
  }
  // Filter tables
  if (!x.matches("[data-filter]")) return;
  const card = x.closest(".card");
  const q = x.value.toLowerCase().trim();
  let shown = 0;
  $$("tbody tr", card).forEach((tr) => {
    const ok = tr.textContent.toLowerCase().includes(q);
    tr.hidden = !ok;
    if (ok) shown++;
  });
  const foot = $(".foot", card);
  const total = $$("tbody tr", card).length;
  if (foot)
    foot.textContent = q ? `${shown} of ${total} shown` : `${total} total`;
});

// Select changes
document.addEventListener("change", async (e) => {
  const x = e.target;
  const ch = x.dataset.change;
  if (!ch) return;

  if (ch === "np-city") {
    if (x.value === "__detected__") return;
    state.prayerCity = x.value;
    state.prayerCityPage = x.value;
    _savePrayerCityPref(x.value);
    const label = x.options[x.selectedIndex]?.text || x.value;
    toast(`📍 Prayer city set to ${label}`);
    await go("Dashboard");
    return;
  }
  if (ch === "prayer-city") {
    state.prayerCityPage = x.value;
    state.prayerCity = x.value;
    _savePrayerCityPref(x.value);
    const label = x.options[x.selectedIndex]?.text || x.value;
    toast(`📍 Prayer city set to ${label}`);
    await go("Prayer Times");
    return;
  }
  if (ch === "prayer-year") {
    state.prayerYear = parseInt(x.value, 10);
    await go("Prayer Times");
  }
  if (ch === "dhikr-campaign") {
    _dhikrState.activeCampaignId = parseInt(x.value, 10);
    await go("Dhikr Campaigns");
    return;
  }
  if (ch === "dhikr-status") {
    _dhikrState.statusFilter = x.value;
    await go("Dhikr Campaigns");
    return;
  }
});

// Keyboard
document.addEventListener("keydown", (e) => {
  if (e.key === "Escape") {
    if (modalOpen()) closeModal();
    else if (document.body.classList.contains("open")) setMenu(false);
  }
});

document.addEventListener("change", async (e) => {
  if (e.target.id === "avatar-input") {
    const file = e.target.files?.[0];
    e.target.value = "";
    if (file) await settingsAvatarUpload(file);
  }
});

// ---- Card glow effect (mouse-follow radial gradient) ----
let _glowQ = false;
document.addEventListener("mousemove", (e) => {
  if (_glowQ) return;
  _glowQ = true;
  requestAnimationFrame(() => {
    _glowQ = false;
    const card = e.target.closest && e.target.closest(".card");
    if (!card) return;
    const r = card.getBoundingClientRect();
    card.style.setProperty("--mx", e.clientX - r.left + "px");
    card.style.setProperty("--my", e.clientY - r.top + "px");
  });
});

// ============================================================================
// Command palette — ⌘K / Ctrl+K
// ============================================================================
let _paletteOpen = false;
let _paletteDebounce = null;
let _paletteIndex = 0;

function openPalette() {
  if (_paletteOpen) return;
  _paletteOpen = true;
  const overlay = document.createElement("div");
  overlay.id = "palette-overlay";
  overlay.innerHTML = `
        <div class="palette-box">
            <input id="palette-input" class="in" placeholder="Search… or type a command" autocomplete="off">
            <div id="palette-results" class="palette-results"></div>
            <div class="palette-foot">
                <span><kbd>↑</kbd><kbd>↓</kbd> navigate</span>
                <span><kbd>↵</kbd> select</span>
                <span><kbd>esc</kbd> close</span>
            </div>
        </div>`;
  document.body.appendChild(overlay);

  const input = $("#palette-input");
  input.focus();
  renderPaletteResults("");

  input.addEventListener("input", () => {
    clearTimeout(_paletteDebounce);
    _paletteDebounce = setTimeout(() => renderPaletteResults(input.value), 150);
  });

  input.addEventListener("keydown", (e) => {
    const items = $$("#palette-results .palette-item");
    if (!items.length) return;
    if (e.key === "ArrowDown") {
      e.preventDefault();
      _paletteIndex = (_paletteIndex + 1) % items.length;
      items.forEach((el, i) =>
        el.classList.toggle("active", i === _paletteIndex),
      );
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      _paletteIndex = (_paletteIndex - 1 + items.length) % items.length;
      items.forEach((el, i) =>
        el.classList.toggle("active", i === _paletteIndex),
      );
    } else if (e.key === "Enter") {
      e.preventDefault();
      items[_paletteIndex]?.click();
    }
  });

  overlay.addEventListener("click", (e) => {
    if (e.target.id === "palette-overlay") closePalette();
  });
}

function closePalette() {
  _paletteOpen = false;
  _paletteIndex = 0;
  $("#palette-overlay")?.remove();
}

async function renderPaletteResults(query) {
  const results = $("#palette-results");
  if (!results) return;
  _paletteIndex = 0;

  // Static commands
  const commands = [
    {
      type: "command",
      title: "Dashboard",
      action: () => go("Dashboard"),
      icon: "dash",
    },
    {
      type: "command",
      title: "Settings",
      action: () => go("Settings"),
      icon: "set",
    },
    {
      type: "command",
      title: "Backup",
      action: () => go("Backup"),
      icon: "down",
    },
    {
      type: "command",
      title: "Change password",
      action: openPasswordModal,
      icon: "shield",
    },
    {
      type: "command",
      title: "Run backup now",
      action: backupRunNow,
      icon: "refresh",
    },
    {
      type: "command",
      title: "New dua",
      action: async () => {
        await go("Duas");
        await openCrudForm("Duas", null);
      },
      icon: "plus",
    },
    {
      type: "command",
      title: "New dhikr",
      action: async () => {
        await go("Dhikrs");
        await openCrudForm("Dhikrs", null);
      },
      icon: "plus",
    },
    {
      type: "command",
      title: "Sync Quran audio",
      action: () => go("Sync"),
      icon: "refresh",
    },

    {
      type: "command",
      title: "New wallpaper",
      action: async () => {
        await go("Wallpapers");
        openWallForm(null);
      },
      icon: "plus",
    },
    {
      type: "command",
      title: "New reciter",
      action: async () => {
        await go("Reciters");
        await openCrudForm("Reciters", null);
      },
      icon: "plus",
    },
    {
      type: "command",
      title: "Create role",
      action: roleCreateModal,
      icon: "plus",
    },
  ];

  const q = query.trim().toLowerCase();
  const matchingCmds = q
    ? commands.filter((c) => c.title.toLowerCase().includes(q))
    : commands;

  // API search results (only when query length ≥ 2)
  let apiHits = [];
  if (q.length >= 2) {
    try {
      const r = await api.get(`/search?q=${encodeURIComponent(q)}`);
      apiHits = r.results || [];
    } catch {}
  }

  const html = [];
  if (matchingCmds.length) {
    html.push(`<div class="palette-group">Commands</div>`);
    matchingCmds.forEach((c, i) => {
      html.push(`
                <div class="palette-item${i === 0 ? " active" : ""}" data-kind="cmd" data-idx="${i}">
                    <span class="pi-ic">${ic(c.icon)}</span>
                    <span class="pi-title">${esc(c.title)}</span>
                </div>`);
    });
  }
  if (apiHits.length) {
    html.push(`<div class="palette-group">Results</div>`);
    apiHits.forEach((h, i) => {
      html.push(`
                <div class="palette-item" data-kind="hit" data-idx="${i}">
                    <span class="pi-ic">${ic({ dua: "heart", dhikr: "beads", wallpaper: "img", reciter: "head", translator: "globe", admin: "shield" }[h.type] || "search")}</span>
                    <span class="pi-title">${esc(h.title)}</span>
                    ${h.subtitle ? `<span class="pi-sub">${esc(h.subtitle)}</span>` : ""}
                    <span class="pi-tag">${esc(h.page)}</span>
                </div>`);
    });
  }
  if (!matchingCmds.length && !apiHits.length) {
    html.push(
      `<div class="palette-empty">No results for "${esc(query)}"</div>`,
    );
  }

  results.innerHTML = html.join("");

  results.querySelectorAll(".palette-item").forEach((el) => {
    el.addEventListener("click", async () => {
      closePalette();
      if (el.dataset.kind === "cmd") {
        const c = matchingCmds[parseInt(el.dataset.idx, 10)];
        if (c) await c.action();
      } else {
        const h = apiHits[parseInt(el.dataset.idx, 10)];
        if (h) await go(h.page);
      }
    });
  });
}

// Keyboard shortcut
document.addEventListener("keydown", (e) => {
  const isMac = navigator.platform.toUpperCase().includes("MAC");
  if ((isMac ? e.metaKey : e.ctrlKey) && e.key.toLowerCase() === "k") {
    e.preventDefault();
    if (_paletteOpen) closePalette();
    else openPalette();
  }
  if (e.key === "Escape" && _paletteOpen) {
    closePalette();
  }
});

// ============================================================================
// Custom select — replaces the native popup with a styled one
// ============================================================================
function enhanceSelect(sel) {
  if (sel.dataset.enhanced === "1") return;
  sel.dataset.enhanced = "1";

  const wrap = document.createElement("div");
  wrap.className = "csel";
  if (sel.style.maxWidth) wrap.style.maxWidth = sel.style.maxWidth;
  if (sel.style.minWidth) wrap.style.minWidth = sel.style.minWidth;

  sel.parentNode.insertBefore(wrap, sel);
  wrap.appendChild(sel);
  sel.style.display = "none";

  const trigger = document.createElement("button");
  trigger.type = "button";
  trigger.className = "csel-trigger";
  trigger.setAttribute("aria-haspopup", "listbox");
  trigger.setAttribute("aria-expanded", "false");
  if (sel.style.height) trigger.style.height = sel.style.height;
  if (sel.style.fontSize) trigger.style.fontSize = sel.style.fontSize;
  wrap.appendChild(trigger);

  const popup = document.createElement("div");
  popup.className = "csel-pop";
  popup.setAttribute("role", "listbox");
  wrap.appendChild(popup);

  const render = () => {
    const cur = sel.options[sel.selectedIndex];
    trigger.innerHTML = `
      <span class="csel-val">${esc(cur ? cur.text : "")}</span>
      <svg class="csel-chev" viewBox="0 0 24 24" aria-hidden="true">
        <polyline points="6 9 12 15 18 9"/>
      </svg>`;
    popup.innerHTML = [...sel.options]
      .map(
        (o) =>
          `<button type="button" class="csel-opt${o.selected ? " on" : ""}" data-v="${esc(o.value)}">${esc(o.text)}</button>`,
      )
      .join("");
  };

  const close = () => {
    wrap.classList.remove("open");
    trigger.setAttribute("aria-expanded", "false");
  };

  const open = () => {
    // Only one open at a time
    $$(".csel.open").forEach((w) => {
      if (w === wrap) return;
      w.classList.remove("open");
      w.querySelector(".csel-trigger")?.setAttribute("aria-expanded", "false");
    });
    wrap.classList.add("open");
    trigger.setAttribute("aria-expanded", "true");
    popup.querySelector(".csel-opt.on")?.scrollIntoView({ block: "nearest" });
  };

  trigger.addEventListener("click", (e) => {
    e.stopPropagation();
    wrap.classList.contains("open") ? close() : open();
  });

  popup.addEventListener("click", (e) => {
    const btn = e.target.closest(".csel-opt");
    if (!btn) return;
    if (sel.value !== btn.dataset.v) {
      sel.value = btn.dataset.v;
      // Fire the same change event the original <select> would have
      sel.dispatchEvent(new Event("change", { bubbles: true }));
    }
    render();
    close();
  });

  // <label for="id"> → focus the trigger instead of the hidden select
  const lbl = document.querySelector(`label[for="${sel.id}"]`);
  if (lbl) lbl.addEventListener("click", () => trigger.focus());

  render();
}

function enhanceAllSelects(root = document) {
  $$("select.in", root).forEach(enhanceSelect);
}

// Click anywhere outside → close all
document.addEventListener("click", () => {
  $$(".csel.open").forEach((w) => {
    w.classList.remove("open");
    w.querySelector(".csel-trigger")?.setAttribute("aria-expanded", "false");
  });
});

// ============================================================================
// Devices — admin view of all registered devices
// ============================================================================
async function devicesPage() {
  let users = [];
  try {
    const r = await api.get("/administrators?include_guests=true&limit=500");
    users = r.items || [];
  } catch (e) {
    return `<div class="card glass s12">
      <div class="empty">${esc(e.message || "Failed to load users")}</div>
    </div>`;
  }

  const head = `
    <div class="eh">
      <div class="ic">${ic("head")}</div>
      <div><h3>Devices</h3><p>${users.length} registered account${users.length === 1 ? "" : "s"} · admins + guests</p></div>
      <button type="button" class="b3" data-act="reload">${ic("refresh")}Reload</button>
    </div>`;

  if (!users.length) {
    return `<div class="card glass s12">${head}<div class="empty">No users registered yet.</div></div>`;
  }

  const rows = users
    .map(
      (u) => `
    <tr>
      <td>#${u.id}</td>
      <td>${esc(u.email || "—")}</td>
      <td>${u.is_admin ? `<span class="pill">admin</span>` : `<span class="pill off">guest</span>`}</td>
      <td>
        <button type="button" class="b3" data-act="device-view" data-uid="${u.id}">
          ${ic("head")}View devices
        </button>
      </td>
    </tr>
  `,
    )
    .join("");

  return `<div class="card glass s12">${head}
    <div class="tb">
      <div class="fld">${ic("search")}<input type="search" placeholder="Search…" data-filter></div>
    </div>
    <div class="tw"><table>
      <thead><tr><th>ID</th><th>Email</th><th>Type</th><th></th></tr></thead>
      <tbody>${rows}</tbody>
    </table></div>
    <div class="foot">${users.length} total</div>
  </div>`;
}

async function showUserDevices(userId) {
  try {
    const devices = await api.get(`/administrators/${userId}/devices`);
    const rows = devices
      .map(
        (d) => `
      <tr>
        <td><code style="font-size:11px">${esc((d.device_uuid || "").slice(0, 16))}…</code></td>
        <td>${esc(d.platform || "—")}</td>
        <td>${esc(d.device_model || "—")}</td>
        <td>${esc(d.os_version || "—")}</td>
        <td>${esc(d.app_version || "—")}</td>
        <td>${d.revoked ? `<span class="pill off">revoked</span>` : `<span class="pill ok">active</span>`}</td>
        <td>${esc(d.last_seen_at || "—")}</td>
        <td>
          ${
            !d.revoked
              ? `<button type="button" class="b3" style="color:var(--bad)"
              data-act="device-revoke"
              data-uid="${userId}"
              data-uuid="${esc(d.device_uuid)}">Revoke</button>`
              : "—"
          }
        </td>
      </tr>
    `,
      )
      .join("");

    openModal(`
      <div class="mh">
        <h3>Devices for user #${userId}</h3>
        <button type="button" class="x" data-act="close">${ic("x")}</button>
      </div>
      <div class="mf" style="padding:0">
        ${
          devices.length
            ? `
          <table style="width:100%;border-collapse:collapse;font-size:12px">
            <thead><tr style="text-align:left;border-bottom:1px solid var(--line)">
              <th style="padding:8px">UUID</th>
              <th style="padding:8px">Platform</th>
              <th style="padding:8px">Model</th>
              <th style="padding:8px">OS</th>
              <th style="padding:8px">App</th>
              <th style="padding:8px">Status</th>
              <th style="padding:8px">Last seen</th>
              <th style="padding:8px"></th>
            </tr></thead>
            <tbody>${rows}</tbody>
          </table>
        `
            : `<div class="empty">No devices for this user.</div>`
        }
      </div>
    `);
  } catch (e) {
    toast(e.message || "Failed to load devices", true);
  }
}
// ============================================================================
// Dhikr Campaigns
// ============================================================================
const _dhikrState = {
  tab: "campaigns",
  activeCampaignId: null,
  statusFilter: "pending",
};

async function dhikrCampaignsPage() {
  let campaigns = [];
  try {
    campaigns = await api.get("/admin/dhikr/campaigns");
  } catch (e) {
    return `<div class="card glass s12">
      <div class="empty">${esc(e.message || "Failed to load campaigns")}</div>
    </div>`;
  }

  // Fetch stats in parallel
  const statsMap = {};
  await Promise.all(
    campaigns.map(async (c) => {
      try {
        statsMap[c.id] = await api.get(`/admin/dhikr/campaigns/${c.id}/stats`);
      } catch {
        statsMap[c.id] = null;
      }
    }),
  );

  const totalSubmissions = Object.values(statsMap).reduce(
    (sum, s) => sum + (s?.total_submissions || 0),
    0,
  );
  const totalDhikrs = Object.values(statsMap).reduce(
    (sum, s) => sum + (s?.total_dhikrs || 0),
    0,
  );
  const totalPending = Object.values(statsMap).reduce(
    (sum, s) => sum + (s?.pending || 0),
    0,
  );

  const cards = `
    <div class="card glass s4 stat">
      <div class="top"><div class="ic">${ic("check")}</div></div>
      <div class="num">${totalDhikrs.toLocaleString()}</div>
      <div class="lbl">Total Dhikrs</div>
    </div>
    <div class="card glass s4 stat">
      <div class="top"><div class="ic">${ic("beads")}</div></div>
      <div class="num">${totalSubmissions.toLocaleString()}</div>
      <div class="lbl">Submissions</div>
    </div>
    <div class="card glass s4 stat">
      <div class="top"><div class="ic">${ic("clock")}</div></div>
      <div class="num"${totalPending > 0 ? ' style="color:var(--bad)"' : ""}>${totalPending.toLocaleString()}</div>
      <div class="lbl">Pending Review</div>
    </div>`;

  const tabs = `
    <div style="display:flex;gap:0;border-bottom:1px solid var(--line);margin-top:16px">
      <button type="button" data-act="dhikr-tab" data-tab="campaigns"
        style="flex:1;padding:14px;background:${_dhikrState.tab === "campaigns" ? "var(--grad)" : "transparent"};color:${_dhikrState.tab === "campaigns" ? "#fff" : "inherit"};border:none;cursor:pointer;font-weight:700">
        Campaigns (${campaigns.length})
      </button>
      <button type="button" data-act="dhikr-tab" data-tab="submissions"
        style="flex:1;padding:14px;background:${_dhikrState.tab === "submissions" ? "var(--grad)" : "transparent"};color:${_dhikrState.tab === "submissions" ? "#fff" : "inherit"};border:none;cursor:pointer;font-weight:700">
        Submissions (${totalSubmissions})
      </button>
    </div>`;

  const head = `
    <div class="eh">
      <div class="ic">${ic("beads")}</div>
      <div><h3>Dhikr Campaigns</h3><p>Manage submission windows and review user submissions</p></div>
      <button type="button" class="b2" data-act="dhikr-add">${ic("plus")}New Campaign</button>
    </div>`;

  const content =
    _dhikrState.tab === "campaigns"
      ? renderCampaignsList(campaigns, statsMap)
      : await renderSubmissionsTab(campaigns);

  return `<div class="card glass s12">${head}</div>${cards}<div class="card glass s12">${tabs}${content}</div>`;
}

function renderCampaignsList(campaigns, statsMap) {
  if (!campaigns.length) {
    return `<div class="empty" style="padding:32px">No campaigns yet. Click "New Campaign" to create one.</div>`;
  }

  const today = new Date().toISOString().slice(0, 10);

  const rows = campaigns
    .map((c) => {
      const stats = statsMap[c.id];
      const isToday = today >= c.starts_on && today <= c.ends_on;
      const state = !c.is_active
        ? `<span class="pill off">disabled</span>`
        : isToday
          ? `<span class="pill ok">active today</span>`
          : `<span class="pill warn">scheduled</span>`;

      return `
      <tr>
        <td>#${c.id}</td>
        <td><b>${esc(c.title)}</b></td>
        <td><code style="font-size:11px">${esc(c.slug)}</code></td>
        <td>${esc(c.starts_on)}</td>
        <td>${esc(c.ends_on)}</td>
        <td>${state}</td>
        <td>${(stats?.total_submissions || 0).toLocaleString()}</td>
        <td>${(stats?.total_dhikrs || 0).toLocaleString()}</td>
        <td>
          <span class="act-b">
            <button type="button" data-act="dhikr-toggle" data-id="${c.id}"
              title="${c.is_active ? "Deactivate" : "Activate"}">
              ${c.is_active ? ic("pause") : ic("play")}
            </button>
            <button type="button" data-act="dhikr-edit" data-id="${c.id}" title="Edit">
              ${ic("edit")}
            </button>
            <button type="button" class="d" data-act="dhikr-delete" data-id="${c.id}" data-title="${esc(c.title)}">
              ${ic("trash")}
            </button>
          </span>
        </td>
      </tr>
    `;
    })
    .join("");

  return `
    <div class="tw"><table>
      <thead><tr>
        <th>ID</th><th>Title</th><th>Slug</th><th>Starts</th><th>Ends</th>
        <th>Status</th><th>Submissions</th><th>Dhikrs</th><th>Actions</th>
      </tr></thead>
      <tbody>${rows}</tbody>
    </table></div>
  `;
}

async function renderSubmissionsTab(campaigns) {
  if (!campaigns.length) {
    return `<div class="empty" style="padding:32px">No campaigns yet.</div>`;
  }

  const cid = _dhikrState.activeCampaignId || campaigns[0].id;
  _dhikrState.activeCampaignId = cid;

  const cidOpts = campaigns
    .map(
      (c) =>
        `<option value="${c.id}"${c.id === cid ? " selected" : ""}>${esc(c.title)}</option>`,
    )
    .join("");

  const statusOpts = [
    ["pending", "Pending"],
    ["handled", "Handled"],
    ["rejected", "Rejected"],
    ["", "All statuses"],
  ]
    .map(
      ([v, l]) =>
        `<option value="${v}"${_dhikrState.statusFilter === v ? " selected" : ""}>${l}</option>`,
    )
    .join("");

  let data = { total: 0, items: [] };
  try {
    const q = _dhikrState.statusFilter
      ? `&status_filter=${_dhikrState.statusFilter}`
      : "";
    data = await api.get(
      `/admin/dhikr/campaigns/${cid}/submissions?limit=500${q}`,
    );
  } catch (e) {
    return `<div class="empty" style="padding:32px">${esc(e.message)}</div>`;
  }

  const rows = (data.items || [])
    .map((s) => {
      const pill =
        {
          pending: `<span class="pill warn">pending</span>`,
          handled: `<span class="pill ok">handled</span>`,
          rejected: `<span class="pill off">rejected</span>`,
        }[s.status] || esc(s.status);

      return `
      <tr>
        <td>#${s.id}</td>
        <td>${esc(s.full_name || "—")}</td>
        <td>${esc(s.phone || "—")}</td>
        <td><b>${s.count.toLocaleString()}</b></td>
        <td>${pill}</td>
        <td><code style="font-size:10px">${esc((s.device_uuid || "").slice(0, 10))}…</code></td>
        <td>${esc(s.created_at || "")}</td>
        <td>
          ${
            s.status === "pending"
              ? `
            <span class="act-b">
              <button type="button" data-act="dhikr-handle" data-id="${s.id}" title="Mark handled" style="color:var(--ok)">${ic("check")}</button>
              <button type="button" class="d" data-act="dhikr-reject" data-id="${s.id}" title="Reject">${ic("x")}</button>
            </span>`
              : "—"
          }
        </td>
      </tr>
    `;
    })
    .join("");

  return `
    <div class="tb" style="padding:14px 0;display:flex;gap:10px;flex-wrap:wrap;align-items:flex-end">
      <div style="display:flex;flex-direction:column;gap:6px;flex:1;min-width:180px;max-width:280px">
        <label style="font-size:11px;font-weight:700;text-transform:uppercase;color:var(--mut)">Campaign</label>
        <select class="in" data-change="dhikr-campaign">${cidOpts}</select>
      </div>
      <div style="display:flex;flex-direction:column;gap:6px;min-width:140px">
        <label style="font-size:11px;font-weight:700;text-transform:uppercase;color:var(--mut)">Filter</label>
        <select class="in" data-change="dhikr-status">${statusOpts}</select>
      </div>
      <div style="margin-left:auto;font-size:12px;color:var(--mut)">
        ${data.total.toLocaleString()} submission${data.total === 1 ? "" : "s"}
      </div>
    </div>
    ${
      data.items?.length
        ? `
      <div class="tw"><table>
        <thead><tr>
          <th>ID</th><th>Name</th><th>Phone</th><th>Count</th><th>Status</th>
          <th>Device</th><th>Submitted</th><th>Actions</th>
        </tr></thead>
        <tbody>${rows}</tbody>
      </table></div>
    `
        : `<div class="empty" style="padding:32px">No submissions${_dhikrState.statusFilter ? ` with status "${_dhikrState.statusFilter}"` : ""}.</div>`
    }
  `;
}
async function openCampaignForm(existing) {
  if (!can("dhikr-campaigns:write")) {
    toast("You don't have permission to edit dhikr campaigns", true);
    return;
  }

  const isEdit = !!existing;
  formModal({
    title: isEdit ? `Edit: ${existing.title}` : "New Dhikr Campaign",
    fields: [
      { k: "title", l: "Title", req: 1, full: 1, h: "e.g. 19th Chand Dhikr" },
      { k: "slug", l: "Slug", req: 1, full: 1, h: "lowercase, hyphens only" },
      { k: "description", l: "Description", t: "area", full: 1 },
      { k: "starts_on", l: "Starts on", req: 1, t: "date" },
      { k: "ends_on", l: "Ends on", req: 1, t: "date" },
    ],
    data: existing || {},
    onSubmit: async (vals) => {
      if (vals.ends_on < vals.starts_on)
        return "End date must be on/after start";
      try {
        if (isEdit) {
          await api.patch(`/admin/dhikr/campaigns/${existing.id}`, vals);
        } else {
          await api.post("/admin/dhikr/campaigns", vals);
        }
        toast(isEdit ? "Updated" : "Created");
        await go("Dhikr Campaigns");
        return null;
      } catch (e) {
        return e.message || "Save failed";
      }
    },
  });
}

// ============================================================================
// Init
// ============================================================================
async function init() {
  // ── Time format preference ──
  _timeFmt = _loadTimeFmt();

  // ── Boot overlay wiring ──
  const boot = document.getElementById("boot-overlay");
  const bootStatus = document.getElementById("boot-status");
  const bootLogo = document.getElementById("boot-logo");
  const setBoot = (msg) => {
    if (bootStatus) bootStatus.textContent = msg;
  };
  const finishBoot = () => {
    if (!boot) return;
    boot.classList.add("hide");
    setTimeout(() => {
      try {
        boot.remove();
      } catch {}
    }, 550);
  };
  const failBoot = (msg) => {
    if (!boot) return;
    boot.innerHTML = `<div class="boot-card glass" style="max-width:420px">
        <div class="boot-brand">
          <img src="assets/img/logo.png" alt="" style="width:44px;height:44px;border-radius:10px" />
          <b style="color:#8f2308">Cannot reach server</b>
        </div>
        <p style="font-size:13px;color:#7d5a42;margin:4px 0 16px;text-align:center;line-height:1.5">${esc(msg)}</p>
        <button type="button" class="btn" onclick="location.reload()"
          style="padding:10px 20px;border-radius:10px;border:none;background:linear-gradient(135deg,#ffa03f,#e4530b);color:#fff;font-weight:700;cursor:pointer">
          Retry
        </button>
      </div>`;
    if (bootStatus) bootStatus.style.display = "none";
  };

  try {
    setBoot("Connecting to server…");
    await api.ready();
  } catch (err) {
    failBoot(err.message || "Network error");
    return;
  }

  try {
    // Hide the language switcher (unused)
    $('[data-act="lang"]')?.remove();

    // ── Load city catalogue FIRST (needed for _matchCuratedCity) ──
    setBoot("Loading cities…");
    await ensurePrayerCities();

    // ── Restore cached location detection ──
    setBoot("Restoring preferences…");
    const cached = _loadPersistedDetected();
    if (cached) {
      state.detected = cached;
      const match = _matchCuratedCity(
        cached.city,
        cached.state,
        cached.country_code,
      );
      if (match) {
        state.prayerCity = match.key;
        state.prayerCityPage = match.key;
      }
    }

    // ── Restore saved prayer-city preference (overrides detection) ──
    const savedCity = _loadPrayerCityPref();
    if (savedCity) {
      const exists = (state.prayerCityList || []).some(
        (c) => c.key === savedCity,
      );
      if (exists) {
        state.prayerCity = savedCity;
        state.prayerCityPage = savedCity;
      }
    }

    // ── Settings + profile ──
    setBoot("Loading settings…");
    await ensureSettings();

    setBoot("Loading profile…");
    await refreshMe();
    applyBrand();
    applyUserHeader();
    renderNav();

    // ── First render ──
    setBoot("Rendering…");
    const hash = decodeURIComponent(location.hash.slice(1));
    await go(NAV.some(([n]) => n === hash) ? hash : "Dashboard");

    // ── Done ──
    finishBoot();

    // ── Auto-prompt for location (after first paint) ──
    setTimeout(async () => {
      if (state.detected) return;
      try {
        await autoPromptLocationIfNeeded();
        if (state.page === "Dashboard" && state.detected) {
          go("Dashboard");
        }
      } catch {}
    }, 500);
  } catch (err) {
    console.error("[init]", err);
    failBoot(err.message || "Initialization failed");
    toast(err.message || "Initialization failed", true);
    finishBoot();
  }
}

init();
