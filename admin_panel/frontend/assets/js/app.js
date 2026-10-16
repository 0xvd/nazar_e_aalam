const $ = (s) => document.querySelector(s);
const P = {
  dash: '<rect x="3" y="3" width="7" height="9" rx="2"/><rect x="14" y="3" width="7" height="5" rx="2"/><rect x="14" y="12" width="7" height="9" rx="2"/><rect x="3" y="16" width="7" height="5" rx="2"/>',
  shield: '<path d="M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6z"/>',
  clock: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
  head: '<path d="M4 15v-3a8 8 0 0116 0v3"/><path d="M3 14h4v6H3zM17 14h4v6h-4z"/>',
  heart:
    '<path d="M12 21s-8-5-8-11a4.5 4.5 0 018-2.5A4.5 4.5 0 0120 10c0 6-8 11-8 11z"/>',
  beads:
    '<circle cx="6" cy="9" r="2"/><circle cx="12" cy="5" r="2"/><circle cx="18" cy="9" r="2"/><circle cx="18" cy="16" r="2"/><circle cx="12" cy="20" r="2"/><circle cx="6" cy="16" r="2"/>',
  img: '<rect x="3" y="4" width="18" height="16" rx="3"/><circle cx="9" cy="10" r="1.5"/><path d="M21 16l-5-5-9 9"/>',
  spark: '<path d="M12 3l2 6 6 2-6 2-2 6-2-6-6-2 6-2z"/>',
  ban: '<circle cx="12" cy="12" r="9"/><path d="M5.6 5.6l12.8 12.8"/>',
  coin: '<circle cx="12" cy="12" r="9"/><path d="M12 7v10M9.5 10c0-1.2 1-1.7 2.5-1.7s2.5.6 2.5 1.7-1 1.5-2.5 2-2.5.9-2.5 2 1 1.7 2.5 1.7 2.5-.5 2.5-1.7"/>',
  globe:
    '<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c3 3 3 15 0 18M12 3c-3 3-3 15 0 18"/>',
  pen: '<path d="M4 20h4L19 9l-4-4L4 16z"/>',
  set: '<path d="M4 6h9M17 6h3M4 12h3M11 12h9M4 18h11M19 18h1"/><circle cx="15" cy="6" r="2"/><circle cx="9" cy="12" r="2"/><circle cx="17" cy="18" r="2"/>',
  book: '<path d="M5 4h14v16H7a2 2 0 01-2-2z"/><path d="M9 8h6"/>',
  star: '<path d="M12 2l2.5 4.5 5-1.5-1.5 5 4.5 2-4.5 2 1.5 5-5-1.5L12 22l-2.5-4.5-5 1.5 1.5-5-4.5-2 4.5-2-1.5-5 5 1.5z"/>',
  user: '<circle cx="9" cy="8" r="3.5"/><path d="M2 20c0-4 3-6 7-6s7 2 7 6M17 5a3.5 3.5 0 010 7M22 20c0-3-2-5-4-5.5"/>',
  card: '<rect x="2" y="5" width="20" height="14" rx="3"/><path d="M2 10h20"/>',
  search: '<circle cx="11" cy="11" r="7"/><path d="M20 20l-4-4"/>',
  plus: '<path d="M12 5v14M5 12h14"/>',
  up: '<path d="M7 17L17 7M9 7h8v8"/>',
  check: '<path d="M5 12l5 5 9-10"/>',
};
const ic = (n) => `<svg class="i" viewBox="0 0 24 24">${P[n]}</svg>`;
const items = [
  ["Dashboard", "dash"],
  ["Administrator", "shield"],
  ["Prayer Times", "clock"],
  ["Audio Quran", "head"],
  ["Dua", "heart"],
  ["Dhikr", "beads"],
  ["Wallpaper", "img"],
  ["Sifat Name", "spark"],
  ["Haram Code", "ban"],
  ["Donation", "coin"],
  ["Landing Page", "globe"],
  ["Blog", "pen"],
  ["Settings", "set"],
];
let cur = "Dashboard",
  tick,
  kk = 0;
const S = {
  get: (k) => {
    try {
      return sessionStorage.getItem(k);
    } catch (e) {
      return null;
    }
  },
  set: (k, v) => {
    try {
      sessionStorage.setItem(k, v);
    } catch (e) {}
  },
  del: (k) => {
    try {
      sessionStorage.removeItem(k);
    } catch (e) {}
  },
};

/* ---------- helpers ---------- */
const pad = (n) => String(n).padStart(2, "0");
const fmt = (s) =>
  `${pad((s / 3600) | 0)}:${pad(((s % 3600) / 60) | 0)}:${pad(s % 60)}`;
// smooth curve through points
const sm = (a, w, h) => {
  const mx = Math.max(...a),
    mn = Math.min(...a),
    dx = w / (a.length - 1);
  const p = a.map((v, i) => [
    i * dx,
    h - ((v - mn) / (mx - mn || 1)) * h * 0.75 - h * 0.1,
  ]);
  let d = `M${p[0]}`;
  for (let i = 1; i < p.length; i++) {
    const c = (p[i - 1][0] + p[i][0]) / 2;
    d += `C${c},${p[i - 1][1]} ${c},${p[i][1]} ${p[i]}`;
  }
  return d;
};
const PR = [
  ["Fajr", "05:12"],
  ["Dhuhr", "12:28"],
  ["Asr", "15:49"],
  ["Maghrib", "18:21"],
  ["Isha", "19:42"],
];
const tm = PR.map(([, t]) => {
  const [h, m] = t.split(":");
  return +h * 60 + +m;
});
function np() {
  const n = new Date(),
    s = n.getHours() * 3600 + n.getMinutes() * 60 + n.getSeconds();
  let i = tm.findIndex((t) => t * 60 > s),
    a,
    b;
  if (i < 0) {
    i = 0;
    b = tm[0] * 60 + 86400;
    a = tm[4] * 60;
  } else {
    b = tm[i] * 60;
    a = i ? tm[i - 1] * 60 : tm[4] * 60 - 86400;
  }
  return { i, left: b - s, f: (s - a) / (b - a) };
}
const SP = [
  [3, 5, 4, 7, 6, 9, 8],
  [2, 4, 3, 5, 7, 6, 9],
  [5, 4, 6, 5, 8, 7, 10],
  [4, 6, 5, 8, 7, 9, 12],
];
const stat = (i, n, l, x) => {
  const k = kk++,
    d = sm(n ? SP[k % 4] : [0, 0, 0, 0, 0, 0, 0], 200, 46);
  return `<div class="card glass s3 stat"><div class="top"><div class="ic">${ic(i)}</div></div><div class="num" data-n="${n}">0</div><div class="lbl">${l}${x ? ` <em>/ ${x}</em>` : ""}</div><svg class="sk" viewBox="0 0 200 46" preserveAspectRatio="none"><path class="fl" d="${d}L200 46L0 46Z"/><path class="ln" pathLength="1" d="${d}"/></svg></div>`;
};

/* ---------- nav / routing ---------- */
function nav() {
  $("#nav").innerHTML = items
    .map(
      ([n, i], k) =>
        `<a tabindex="0" style="--i:${k}" onkeydown="if(event.key=='Enter')this.click()" class="${n == cur ? "act" : ""}" onclick="go('${n}')">${ic(i)}${n}</a>`,
    )
    .join("");
}
function go(n) {
  cur = n;
  $("#pt").textContent = n;
  nav();
  document.body.classList.remove("open");
  render();
  $("#page").scrollTop = 0;
}
function animate() {
  document.querySelectorAll("[data-n]").forEach((e) => {
    const t = +e.dataset.n,
      s = performance.now();
    (function f(n) {
      const p = Math.min((n - s) / 1800, 1);
      e.textContent = Math.round(t * (1 - Math.pow(1 - p, 4)));
      if (p < 1) requestAnimationFrame(f);
    })(s);
  });
  setTimeout(() => {
    document
      .querySelectorAll("[data-w]")
      .forEach((e) => (e.style.width = e.dataset.w + "%"));
    document
      .querySelectorAll(".dfg")
      .forEach((c) => (c.style.strokeDashoffset = 0));
    const r = $("#rg");
    if (r) r.style.strokeDashoffset = 100 * (1 - np().f);
  }, 150);
}
function t() {
  const e = $("#cd");
  if (!e) return;
  const r = np();
  e.textContent = fmt(r.left);
  $("#rg").style.strokeDashoffset = 100 * (1 - r.f);
  tick = setTimeout(t, 1000);
}

/* ---------- pages ---------- */
function render() {
  const p = $("#page");
  kk = 0;
  clearTimeout(tick);
  const nm0 = S.get("u") || "0xvd",
    nm = nm0[0].toUpperCase() + nm0.slice(1);
  if (cur == "Dashboard") {
    const dt = new Date().toLocaleDateString("en-US", {
      weekday: "long",
      month: "long",
      day: "numeric",
    });
    const h = new Date().getHours(),
      g = h < 12 ? "Good morning" : h < 18 ? "Good afternoon" : "Good evening";
    const r = np(),
      A = [12, 18, 14, 26, 22, 34, 30],
      cd = sm(A, 600, 160);
    p.innerHTML = `<svg width="0" height="0" style="position:absolute"><defs><linearGradient id="sf" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#ff7a1a" stop-opacity=".32"/><stop offset="1" stop-color="#ff7a1a" stop-opacity="0"/></linearGradient><linearGradient id="gr" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#ffa03f"/><stop offset="1" stop-color="#e4530b"/></linearGradient></defs></svg>
<div class="card glass hero s8"><svg class="wv" viewBox="0 0 800 70" preserveAspectRatio="none"><path d="M0 35C50 5 150 65 200 35S350 5 400 35 550 65 600 35 750 5 800 35V70H0Z"/></svg>
<div class="ar">بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ</div><h2>${g}, ${nm} 👋</h2><p>Your panel is live. Here is how the app is doing today.</p>
<div class="hrow"><span>${ic("clock")}${dt}</span><span><i class="dot"></i>Panel active</span></div>
<div class="qa"><button onclick="go('Dua')">${ic("plus")}Add dua</button><button onclick="go('Audio Quran')">${ic("head")}Upload audio</button><button class="g" onclick="go('Blog')">${ic("pen")}Write blog post</button></div></div>
<div class="card glass np s4"><small>Next prayer</small><div class="rg"><svg viewBox="0 0 36 36"><circle class="bg" cx="18" cy="18" r="15.9"/><circle id="rg" class="fg" cx="18" cy="18" r="15.9" pathLength="100"/></svg><div><b>${PR[r.i][0]}</b><em id="cd">${fmt(r.left)}</em></div></div>
<div class="pr">${PR.map(([n, t], k) => `<div class="${k == r.i ? "nx" : ""}"><span>${n}</span><b>${t}</b></div>`).join("")}</div></div>
${stat("book", 114, "Total Surah", 114)}${stat("heart", 21, "Total Dua")}${stat("beads", 6, "Total Dhikr")}${stat("star", 99, "Allah's Names", 99)}
${stat("ban", 73, "Haram Codes")}${stat("user", 1, "Total Users")}${stat("coin", 0, "Donations")}${stat("card", 0, "Payment Methods")}
<div class="card glass s8"><div class="ch"><div class="ic">${ic("spark")}</div><div><b>App activity</b><small>Daily active users, last 7 days</small></div><span class="tr">${ic("up")}+24%</span></div>
<svg class="cv" viewBox="0 0 600 160" preserveAspectRatio="none">${[20, 60, 100, 140].map((y) => `<line class="gl" x1="0" x2="600" y1="${y}" y2="${y}"/>`).join("")}<path class="fl" d="${cd}L600 160L0 160Z"/><path class="ln" pathLength="1" d="${cd}"/></svg>
<div class="xl">${["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map((d) => `<span>${d}</span>`).join("")}</div></div>
<div class="card glass s4"><div class="ch"><div class="ic">${ic("img")}</div><div><b>Platform breakdown</b><small>iOS vs Android users</small></div></div>
<div class="dn"><svg viewBox="0 0 42 42"><circle cx="21" cy="21" r="15.9" fill="none" stroke="rgba(130,60,10,.12)" stroke-width="4"/><circle class="dfg" cx="21" cy="21" r="15.9" fill="none" stroke="url(#gr)" stroke-width="4" stroke-linecap="round" pathLength="100" stroke-dasharray="100" stroke-dashoffset="100" transform="rotate(-90 21 21)"/><text x="21" y="24" text-anchor="middle" font-size="9" font-weight="800" fill="#2b1608">1</text></svg>
<div class="lg"><div><i style="background:#e4530b"></i>Android: 1</div><div><i style="background:#f6c9ab"></i>iOS: 0</div></div></div></div>
<div class="card glass s6"><div class="ch"><div class="ic">${ic("globe")}</div><div><b>Users by country</b><small>Where your app users are located</small></div></div>
${[
  ["🇮🇳 India", 100, 1],
  ["🇵🇰 Pakistan", 0, 0],
  ["🇧🇩 Bangladesh", 0, 0],
  ["🇦🇪 UAE", 0, 0],
]
  .map(
    (c) =>
      `<div class="cr"><span class="n">${c[0]}</span><div class="bar"><i data-w="${c[1]}"></i></div><span class="v">${c[2]}</span></div>`,
  )
  .join("")}</div>
<div class="card glass s6"><div class="ch"><div class="ic">${ic("clock")}</div><div><b>Recent activity</b><small>Latest changes in your panel</small></div></div>
${[
  ["check", "You signed in", "Just now"],
  ["clock", "Prayer times refreshed", "2h ago"],
  ["heart", "21 duas synced to the app", "Yesterday"],
  ["user", "New Android user registered", "2 days ago"],
]
  .map(
    (a) =>
      `<div class="ev"><div class="ic">${ic(a[0])}</div>${a[1]}<small>${a[2]}</small></div>`,
  )
  .join("")}</div>`;
    tick = setTimeout(t, 1000);
  } else if (cur == "Administrator") {
    p.innerHTML = `<div class="card glass s12"><div class="eh"><div class="ic">${ic("shield")}</div><div><h3>Administrators</h3><p>People who can sign in to this panel</p></div><button class="b2">${ic("plus")}Invite admin</button></div><table><thead><tr><th>Name</th><th>Email</th><th>Role</th><th>Status</th></tr></thead><tbody><tr><td><b>${nm}</b></td><td>${S.get("e") || ""}</td><td><span class="pill">Super Admin</span></td><td><span class="pill ok">Active</span></td></tr></tbody></table></div>`;
  } else {
    const icn = items.find((i) => i[0] == cur)[1];
    p.innerHTML = `<div class="card glass s12"><div class="eh"><div class="ic">${ic(icn)}</div><div><h3>${cur}</h3><p>Manage ${cur.toLowerCase()} content for the app</p></div><button class="b2">${ic("plus")}Add new</button></div>${'<div class="sk2"><i style="width:42px;height:42px;border-radius:12px"></i><i style="width:30%"></i><i style="flex:1"></i><i style="width:70px"></i></div>'.repeat(5)}<p class="sub" style="margin:14px 0 0;text-align:center">Connect this section to your API to see live data.</p></div>`;
  }
  [...p.children].forEach((e, i) => e.style.setProperty("--i", i));
  animate();
}


function enter() {
  document.body.classList.add("on");
  const u = S.get("u") || "0xvd";
  // $("#un").textContent = u;
  $("#ini").textContent = u[0].toUpperCase();
  cur = "Dashboard";
  $("#pt").textContent = cur;
  nav();
  render();
}
function logout() {
  S.del("u");
  S.del("e");
  clearTimeout(tick);
  document.body.classList.remove("on");
}
function lang() {
  const b = $("#lg");
  b.textContent = b.textContent == "English" ? "العربية" : "English";
}
function toast(m) {
  const t = document.createElement("div");
  t.className = "toast";
  t.innerHTML = ic("check") + m;
  document.body.append(t);
  setTimeout(() => t.remove(), 3300);
}

/* ---------- command palette (Ctrl/Cmd + K) ---------- */
function pal(o = true) {
  const p = $("#pal");
  p.classList.toggle("on", !!o);
  if (o) {
    const i = p.querySelector("input");
    i.value = "";
    pf("");
    i.focus();
  }
}
function pf(q) {
  $("#pal .pl").innerHTML =
    items
      .filter(([n]) => n.toLowerCase().includes(q.toLowerCase()))
      .map(
        ([n, i], k) =>
          `<a class="${k ? "" : "f"}" onclick="go('${n}');pal(0)">${ic(i)}${n}</a>`,
      )
      .join("") || '<p class="sub">No sections match.</p>';
}

/* ---------- one-time UI injection ---------- */
$("header .sp").insertAdjacentHTML(
  "afterend",
  `<button class="chip glass srch" onclick="pal()">${ic("search")}<span>Search or jump to…</span><kbd>Ctrl K</kbd></button>`,
);
$("aside").insertAdjacentHTML(
  "beforeend",
  `<div class="sys"><span class="pulse"></span><div><b>All systems normal</b><small>API, database and CDN</small></div></div>`,
);
document.body.insertAdjacentHTML(
  "beforeend",
  `<div id="pal" onclick="if(event.target==this)pal(0)"><div class="pb glass"><input placeholder="Jump to a section…" oninput="pf(this.value)" onkeydown="if(event.key=='Enter'){const f=$('#pal .f');f&&f.click()}"><div class="pl"></div></div></div>`,
);
document.addEventListener("keydown", (e) => {
  if (
    (e.ctrlKey || e.metaKey) &&
    e.key == "k" &&
    document.body.classList.contains("on")
  ) {
    e.preventDefault();
    pal();
  }
  if (e.key == "Escape") pal(0);
});

/* ---------- card spotlight + 3D tilt ---------- */
document.addEventListener("mousemove", (e) => {
  const c = e.target.closest && e.target.closest(".card");
  if (!c) return;
  const r = c.getBoundingClientRect(),
    x = e.clientX - r.left,
    y = e.clientY - r.top;
  c.style.setProperty("--mx", x + "px");
  c.style.setProperty("--my", y + "px");
  // c.style.transform = `perspective(900px) rotateX(${(0.5 - y / r.height) * 5}deg) rotateY(${(x / r.width - 0.5) * 6}deg) translateY(-3px)`;
});
document.addEventListener("mouseout", (e) => {
  const c = e.target.closest && e.target.closest(".card");
  if (c && !c.contains(e.relatedTarget)) c.style.transform = "";
});
if (S.get("u")) enter();

/* ---------- login / session ---------- */
$("#lf").onsubmit = (e) => {
  e.preventDefault();
  if ($("#pw").value.length < 6) {
    $("#err").textContent = "Password must be at least 6 characters.";
    return;
  }
  $("#err").textContent = "";
  const b = $("#lf .btn");
  // window.location.href = '../index.html'
  b.classList.add("load");
  document.body.classList.add('on');
  S.set('u', '0xvd');
  S.set('e', '0xvd');
};