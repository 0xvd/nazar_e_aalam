/* Nazar-e-Aalam — API client.
 *
 * Load BEFORE any page logic:
 *   <script src="assets/js/api.js"></script>
 *
 * Usage:
 *   await api.ready();               // bootstrap CONFIG from /panel_config
 *   await api.login(email, password);// store tokens, return user
 *   const page = await api.get('/duas');
 *   await api.post('/duas', body);
 *   await api.patch('/duas/1', body);
 *   await api.del('/duas/1');
 *   api.user;                        // {id, email, ...} | null
 *   api.isAuthenticated();
 *   await api.logout();
 */
"use strict";

window.api = (() => {
  let CONFIG = null;
  let readyPromise = null;

  const S = {
    get(k) {
      try {
        return localStorage.getItem(k);
      } catch {
        return null;
      }
    },
    set(k, v) {
      try {
        localStorage.setItem(k, v);
      } catch {}
    },
    del(k) {
      try {
        localStorage.removeItem(k);
      } catch {}
    },
  };

  // ---- bootstrap ---------------------------------------------------------
  async function bootstrap() {
    if (CONFIG) return CONFIG;
    let lastErr;
    try {
      const res = await fetch("/panel_config", {
        headers: { Accept: "application/json" },
      });
      if (res.ok) {
        CONFIG = await res.json();
        return CONFIG;
      }
    } catch (e) {
      lastErr = e;
    }
    throw new Error("panel_config unreachable");
  }
  function ready() {
    if (!readyPromise) readyPromise = bootstrap();
    return readyPromise;
  }

  // ---- tokens ------------------------------------------------------------
  function keys() {
    const d = CONFIG?.defaults || {};
    return {
      access: d.token_key || "nea_access_token",
      refresh: d.refresh_key || "nea_refresh_token",
      user: d.user_key || "nea_user",
    };
  }
  function getAccess() {
    return S.get(keys().access);
  }
  function getRefresh() {
    return S.get(keys().refresh);
  }
  function clearTokens() {
    const k = keys();
    S.del(k.access);
    S.del(k.refresh);
    S.del(k.user);
  }
  function storeTokens(data) {
    const k = keys();
    S.set(k.access, data.access_token);
    S.set(k.refresh, data.refresh_token);
    if (data.user) S.set(k.user, JSON.stringify(data.user));
  }
  function getUser() {
    const raw = S.get(keys().user);
    if (!raw) return null;
    try {
      return JSON.parse(raw);
    } catch {
      return null;
    }
  }

  // ---- refresh (single-flight) -------------------------------------------
  let refreshing = null;
  async function refreshTokens() {
    if (refreshing) return refreshing;
    refreshing = (async () => {
      const rt = getRefresh();
      if (!rt || !CONFIG) return false;
      try {
        const res = await fetch(CONFIG.api_base + CONFIG.auth.refresh, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ refresh_token: rt }),
        });
        if (!res.ok) return false;
        storeTokens(await res.json());
        return true;
      } catch {
        return false;
      } finally {
        refreshing = null;
      }
    })();
    return refreshing;
  }

  // ---- request -----------------------------------------------------------
  async function request(path, options = {}) {
    await ready();
    const url = CONFIG.api_base + path;

    // Detect FormData BEFORE building headers/body
    const isFormData =
      typeof FormData !== "undefined" && options.body instanceof FormData;

    const headers = {
      Accept: "application/json",
      ...(options.body && !isFormData
        ? { "Content-Type": "application/json" }
        : {}),
      ...(options.headers || {}),
    };
    // Explicit headers:{} from caller shouldn't reintroduce Content-Type
    if (isFormData) {
      delete headers["Content-Type"];
    }

    const tok = getAccess();
    if (tok) headers.Authorization = `Bearer ${tok}`;

    // Serialize body correctly:
    //  - FormData      → pass as-is (browser sets multipart boundary)
    //  - string        → pass as-is
    //  - plain object  → JSON.stringify
    let body;
    if (options.body === undefined || options.body === null) {
      body = undefined;
    } else if (isFormData) {
      body = options.body;
    } else if (typeof options.body === "string") {
      body = options.body;
    } else {
      body = JSON.stringify(options.body);
    }

    const send = () => fetch(url, { ...options, headers, body });

    let res = await send();
    if (res.status === 401 && getRefresh()) {
      const ok = await refreshTokens();
      if (ok) {
        headers.Authorization = `Bearer ${getAccess()}`;
        res = await send();
      } else {
        redirectLogin();
        throw new Error("session expired");
      }
    }
    if (res.status === 401) {
      redirectLogin();
      throw new Error("unauthorized");
    }
    return res;
  }

  // ---- json helpers ------------------------------------------------------
  async function asJson(res) {
    if (!res.ok) {
      let raw = null;
      try {
        const d = await res.json();
        raw = d.detail || d.message || d;
      } catch {}

      let msg = `HTTP ${res.status}`;
      if (raw != null) {
        if (typeof raw === "string") {
          msg = raw;
        } else if (Array.isArray(raw)) {
          msg = raw
            .map((e) => {
              if (e && typeof e === "object" && e.msg) {
                const field = Array.isArray(e.loc)
                  ? e.loc[e.loc.length - 1]
                  : "";
                return field ? `${field}: ${e.msg}` : e.msg;
              }
              return typeof e === "string" ? e : JSON.stringify(e);
            })
            .join(" · ");
        } else if (typeof raw === "object") {
          msg = raw.message || raw.error || JSON.stringify(raw);
        }
      }

      console.error("[api]", res.status, res.url, "→", raw);
      throw new Error(String(msg));
    }
    if (res.status === 204) return null;
    const t = await res.text();
    return t ? JSON.parse(t) : null;
  }

  const get = (p, o) => request(p, o).then(asJson);
  const post = (p, b, o) =>
    request(p, { ...o, method: "POST", body: b }).then(asJson);
  const patch = (p, b, o) =>
    request(p, { ...o, method: "PATCH", body: b }).then(asJson);
  const put = (p, b, o) =>
    request(p, { ...o, method: "PUT", body: b }).then(asJson);
  const del = (p, o) => request(p, { ...o, method: "DELETE" }).then(asJson);

  // ---- login / logout ----------------------------------------------------
  async function login(email, password) {
    await ready();
    const res = await fetch(CONFIG.api_base + CONFIG.auth.login, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, password }),
    });

    if (!res.ok) {
      let msg = "Invalid email or password";
      let rawDetail = null;
      try {
        const data = await res.json();
        rawDetail = data.detail || data.message || data;
      } catch {}

      if (rawDetail != null) {
        if (typeof rawDetail === "string") {
          msg = rawDetail;
        } else if (Array.isArray(rawDetail)) {
          msg = rawDetail
            .map((e) => {
              if (e && typeof e === "object" && e.msg) {
                const field = Array.isArray(e.loc)
                  ? e.loc[e.loc.length - 1]
                  : "";
                return field ? `${field}: ${e.msg}` : e.msg;
              }
              return typeof e === "string" ? e : JSON.stringify(e);
            })
            .join(" · ");
        } else if (typeof rawDetail === "object") {
          msg =
            rawDetail.message || rawDetail.error || JSON.stringify(rawDetail);
        }
      }

      console.error("[login] HTTP", res.status, "detail:", rawDetail);
      throw new Error(String(msg));
    }

    const data = await res.json();

    // 2FA challenge — do NOT store tokens. Caller will call verifyOtp().
    if (data && data.challenge_token) {
      return data;
    }

    // 2FA off (dev) — store tokens and return user
    storeTokens(data);
    return data.user;
  }
  async function verifyOtp(challengeToken, otp) {
    await ready();
    const res = await fetch(CONFIG.api_base + "/auth/verify-otp", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ challenge_token: challengeToken, otp }),
    });
    if (!res.ok) {
      let msg = "Verification failed";
      try {
        const d = await res.json();
        msg = (d && (d.detail || d.message)) || msg;
      } catch {}
      throw new Error(String(msg));
    }
    const data = await res.json();
    storeTokens(data);
    return data;
  }

  async function resendOtp(challengeToken) {
    await ready();
    const res = await fetch(CONFIG.api_base + "/auth/resend-otp", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ challenge_token: challengeToken }),
    });
    if (!res.ok) {
      let msg = "Resend failed";
      try {
        const d = await res.json();
        msg = (d && (d.detail || d.message)) || msg;
      } catch {}
      throw new Error(String(msg));
    }
    return res.json();
  }

  async function logout() {
    await ready().catch(() => {});
    const rt = getRefresh();
    if (rt && CONFIG) {
      try {
        await fetch(CONFIG.api_base + CONFIG.auth.logout, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ refresh_token: rt }),
        });
      } catch {}
    }
    clearTokens();
    redirectLogin();
  }

  function redirectLogin() {
    const path = location.pathname;
    if (path.endsWith("/login.html")) return;

    // Compute path to login.html relative to where we are
    let loginUrl;
    if (path.includes("/pages/")) {
      // We're inside /panel/pages/*.html → login.html is a sibling
      loginUrl = "login.html";
    } else {
      // We're at /panel/index.html → login.html is in pages/
      loginUrl = "pages/login.html";
    }

    const next = encodeURIComponent(path + location.search);
    location.replace(loginUrl + "?next=" + next);
  }

  // ---- toast ------------------------------------------------------------
  function toast(msg, bad = false) {
    // Create the container if it doesn't exist (login page has no #toasts)
    let host = document.getElementById("toasts");
    if (!host) {
      host = document.createElement("div");
      host.id = "toasts";
      host.setAttribute("aria-live", "polite");
      document.body.appendChild(host);
    }
    const escHtml = (s) =>
      String(s ?? "").replace(
        /[&<>"']/g,
        (c) =>
          ({
            "&": "&amp;",
            "<": "&lt;",
            ">": "&gt;",
            '"': "&quot;",
            "'": "&#39;",
          })[c],
      );
    const icon = bad
      ? '<svg class="i" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 6l12 12M18 6L6 18"/></svg>'
      : '<svg class="i" viewBox="0 0 24 24" aria-hidden="true"><path d="M5 12l5 5 9-10"/></svg>';
    const t = document.createElement("div");
    t.className = "toast" + (bad ? " err" : "");
    t.setAttribute("role", "status");
    t.innerHTML = icon + " " + escHtml(msg);
    host.appendChild(t);
    setTimeout(() => t.remove(), 4200);
  }

  // ---- cache (localStorage with TTL) -------------------------------------
  const CACHE_PREFIX = "nea:cache:";
  const cache = {
    get(key, maxAgeMs = 60_000) {
      try {
        const raw = localStorage.getItem(CACHE_PREFIX + key);
        if (!raw) return null;
        const { ts, v } = JSON.parse(raw);
        if (Date.now() - ts > maxAgeMs) {
          localStorage.removeItem(CACHE_PREFIX + key);
          return null;
        }
        return v;
      } catch {
        return null;
      }
    },
    set(key, value) {
      try {
        localStorage.setItem(
          CACHE_PREFIX + key,
          JSON.stringify({ ts: Date.now(), v: value }),
        );
      } catch {}
    },
    del(key) {
      try {
        localStorage.removeItem(CACHE_PREFIX + key);
      } catch {}
    },
    invalidate(prefix) {
      try {
        Object.keys(localStorage)
          .filter((k) => k.startsWith(CACHE_PREFIX + prefix))
          .forEach((k) => localStorage.removeItem(k));
      } catch {}
    },
    async wrap(key, factory, maxAgeMs = 60_000) {
      const hit = cache.get(key, maxAgeMs);
      if (hit !== null) return hit;
      const v = await factory();
      cache.set(key, v);
      return v;
    },
  };

  // ---- public surface ----------------------------------------------------
  return {
    ready,
    get config() {
      return CONFIG;
    },
    get user() {
      return getUser();
    },
    isAuthenticated: () => !!getAccess(),
    request,
    get,
    post,
    patch,
    put,
    del,
    verifyOtp, // ← new
    resendOtp, // ← new
    login,
    logout,
    toast,
    redirectLogin,
    cache,
  };
})();
