/* Nazar-e-Aalam Admin — dashboard.
   All data is saved in this browser (localStorage) so Add / Edit / Delete really work.
   When your API is ready, replace the LS / list() / commit() helpers with fetch() calls. */
"use strict";
const $ = (s, r = document) => r.querySelector(s);
const $$ = (s, r = document) => [...r.querySelectorAll(s)];
const LOGIN = "pages/login.html";
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
const AUTH = !!S.get("u");
if (!AUTH) location.replace(LOGIN);

/* ---------- storage (localStorage with in-memory fallback) ---------- */
const NS = "nea:",
  MEM = {},
  FAIL = {};
let lsOk = true;
try {
  localStorage.setItem(NS + "t", "1");
  localStorage.removeItem(NS + "t");
} catch (e) {
  lsOk = false;
}
const LS = {
  get(k, d) {
    let s = null;
    if (!FAIL[k]) {
      try {
        s = localStorage.getItem(NS + k);
      } catch (e) {}
    }
    if (s == null) s = MEM[k];
    if (s == null) return d;
    try {
      return JSON.parse(s);
    } catch (e) {
      return d;
    }
  },
  set(k, v) {
    const s = JSON.stringify(v);
    MEM[k] = s;
    try {
      localStorage.setItem(NS + k, s);
      FAIL[k] = false;
      return true;
    } catch (e) {
      FAIL[k] = true;
      return false;
    }
  },
  clear() {
    Object.keys(MEM).forEach((k) => delete MEM[k]);
    Object.keys(FAIL).forEach((k) => delete FAIL[k]);
    try {
      Object.keys(localStorage)
        .filter((k) => k.startsWith(NS))
        .forEach((k) => localStorage.removeItem(k));
    } catch (e) {}
  },
};
const uid = () =>
  Date.now().toString(36) + Math.random().toString(36).slice(2, 7);
const list = (k) => {
  const v = LS.get(k, []);
  return Array.isArray(v) ? v : [];
};
const commit = (k, arr) => {
  if (!LS.set(k, arr))
    toast(
      "Browser storage is full or blocked. Changes may be lost on reload.",
      1,
    );
};

/* ---------- icons + helpers ---------- */
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
  globe:
    '<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c3 3 3 15 0 18M12 3c-3 3-3 15 0 18"/>',
  set: '<path d="M4 6h9M17 6h3M4 12h3M11 12h9M4 18h11M19 18h1"/><circle cx="15" cy="6" r="2"/><circle cx="9" cy="12" r="2"/><circle cx="17" cy="18" r="2"/>',
  book: '<path d="M5 4h14v16H7a2 2 0 01-2-2z"/><path d="M9 8h6"/>',
  star: '<path d="M12 2l2.5 4.5 5-1.5-1.5 5 4.5 2-4.5 2 1.5 5-5-1.5L12 22l-2.5-4.5-5 1.5 1.5-5-4.5-2 4.5-2-1.5-5 5 1.5z"/>',
  user: '<circle cx="9" cy="8" r="3.5"/><path d="M2 20c0-4 3-6 7-6s7 2 7 6M17 5a3.5 3.5 0 010 7M22 20c0-3-2-5-4-5.5"/>',
  search: '<circle cx="11" cy="11" r="7"/><path d="M20 20l-4-4"/>',
  plus: '<path d="M12 5v14M5 12h14"/>',
  up: '<path d="M7 17L17 7M9 7h8v8"/>',
  check: '<path d="M5 12l5 5 9-10"/>',
  edit: '<path d="M4 20h4L19 9l-4-4L4 16z"/>',
  trash: '<path d="M4 7h16M10 11v6M14 11v6M6 7l1 13h10l1-13M9 7V4h6v3"/>',
  play: '<path d="M8 5l11 7-11 7z"/>',
  pause: '<path d="M8 5v14M16 5v14"/>',
  upload: '<path d="M12 16V4M7 9l5-5 5 5M4 20h16"/>',
  down: '<path d="M12 4v12M7 11l5 5 5-5M4 20h16"/>',
  x: '<path d="M6 6l12 12M18 6L6 18"/>',
};
const ic = (n) =>
  P[n]
    ? `<svg class="i" viewBox="0 0 24 24" aria-hidden="true">${P[n]}</svg>`
    : "";
const esc = (s) =>
  String(s ?? "").replace(
    /[&<>"']/g,
    (c) =>
      ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[
        c
      ],
  );
const pad = (n) => String(n).padStart(2, "0");
const fmt = (s) =>
  `${pad((s / 3600) | 0)}:${pad(((s % 3600) / 60) | 0)}:${pad(s % 60)}`;
const cap = (s) => s.charAt(0).toUpperCase() + s.slice(1);
const isUrl = (s) => {
  try {
    const u = new URL(s);
    return u.protocol === "http:" || u.protocol === "https:";
  } catch (e) {
    return false;
  }
};
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
const ago = (t) => {
  const s = Math.max(0, (Date.now() - t) / 1000);
  if (s < 60) return "Just now";
  if (s < 3600) return `${(s / 60) | 0}m ago`;
  if (s < 86400) return `${(s / 3600) | 0}h ago`;
  return `${(s / 86400) | 0}d ago`;
};
function download(name, text, type) {
  const url = URL.createObjectURL(new Blob([text], { type }));
  const a = document.createElement("a");
  a.href = url;
  a.download = name;
  document.body.append(a);
  a.click();
  a.remove();
  setTimeout(() => URL.revokeObjectURL(url), 1500);
}
function fileToDataURL(file, max, keepPng) {
  return new Promise((res, rej) => {
    if (!/^image\/(png|jpe?g|webp)$/.test(file.type))
      return rej(new Error("Please choose a PNG, JPG or WebP image."));
    if (file.size > 10e6)
      return rej(new Error("That image is over 10 MB. Choose a smaller one."));
    const r = new FileReader();
    r.onerror = () => rej(new Error("Could not read that file."));
    r.onload = () => {
      const im = new Image();
      im.onerror = () => rej(new Error("That file is not a valid image."));
      im.onload = () => {
        const k = Math.min(1, max / Math.max(im.width, im.height));
        const c = document.createElement("canvas");
        c.width = Math.max(1, Math.round(im.width * k));
        c.height = Math.max(1, Math.round(im.height * k));
        c.getContext("2d").drawImage(im, 0, 0, c.width, c.height);
        res(
          keepPng && file.type === "image/png"
            ? c.toDataURL("image/png")
            : c.toDataURL("image/jpeg", 0.82),
        );
      };
      im.src = r.result;
    };
    r.readAsDataURL(file);
  });
}

/* ---------- language (English / Arabic) ---------- */
const AR = {
  Dashboard: "لوحة التحكم",
  Administrator: "المشرفون",
  "Prayer Times": "أوقات الصلاة",
  "Audio Quran": "القرآن الصوتي",
  Dua: "الأدعية",
  Dhikr: "الأذكار",
  Wallpaper: "الخلفيات",
  Settings: "الإعدادات",
  Administrators: "المشرفون",
  "Dua List": "قائمة الأدعية",
  "Dhikr List": "قائمة الأذكار",
  Wallpapers: "الخلفيات",
  "Add admin": "إضافة مشرف",
  "Add dua": "إضافة دعاء",
  "Add dhikr": "إضافة ذكر",
  "Upload audio": "إضافة تلاوة",
  "Add wallpaper": "إضافة خلفية",
  "Add prayer time": "إضافة وقت صلاة",
  Import: "استيراد",
  Export: "تصدير",
  Cancel: "إلغاء",
  Save: "حفظ",
  "Save changes": "حفظ التغييرات",
  Discard: "تجاهل",
  Delete: "حذف",
  Edit: "تعديل",
  Search: "بحث",
  Action: "الإجراء",
  Name: "الاسم",
  Email: "البريد",
  Role: "الدور",
  Status: "الحالة",
  Date: "التاريخ",
  Position: "الترتيب",
  Play: "تشغيل",
  "Good morning": "صباح الخير",
  "Good afternoon": "مساء الخير",
  "Good evening": "مساء الخير",
  "Next prayer": "الصلاة القادمة",
  Fajr: "الفجر",
  Dhuhr: "الظهر",
  Asr: "العصر",
  Maghrib: "المغرب",
  Isha: "العشاء",
  Imsak: "الإمساك",
  Sunrise: "الشروق",
  Zuhr: "الظهر",
  Iftar: "الإفطار",
  Sehri: "السحور",
  "Total Surah": "السور",
  "Total Dua": "الأدعية",
  "Total Dhikr": "الأذكار",
  "Audio recitations": "التلاوات",
  "Total Users": "المستخدمون",
  "Recent activity": "آخر النشاطات",
  "App activity": "نشاط التطبيق",
  "Users by country": "المستخدمون حسب الدولة",
  "Platform breakdown": "المنصات",
  Organization: "المؤسسة",
  "Media assets": "الوسائط",
  Appearance: "المظهر",
  Integrations: "التكاملات",
  Descriptions: "الأوصاف",
};
let lang = LS.get("lang", "en") === "ar" ? "ar" : "en";
const tr = (s) => (lang === "ar" && AR[s]) || s;

/* ---------- navigation ---------- */
const items = [
  ["Dashboard", "dash"],
  ["Administrator", "shield"],
  ["Prayer Times", "clock"],
  ["Audio Quran", "head"],
  ["Dua", "heart"],
  ["Dhikr", "beads"],
  ["Wallpaper", "img"],
  ["Settings", "set"],
];
const KEY = {
  Administrator: "admins",
  "Audio Quran": "audio",
  Dua: "dua",
  Dhikr: "dhikr",
  Wallpaper: "walls",
};
let cur = "Dashboard",
  tick = null,
  kk = 0;

/* ---------- starter data (saved to storage on first run) ---------- */
const DUA0 = [
  [
    "For a Happy Family",
    "للسعادة العائلية",
    "Our Lord, grant us from among our wives and offspring comfort to our eyes and make us an example for the righteous.",
    "رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا",
  ],
  [
    "After salam",
    "بعد السلام",
    "O Allah I ask for your forgiveness (three times). You are Peace and from You is all peace, blessed are You, O Possessor of majesty and honour.",
    "أَسْـتَغْفِرُ الله، أَسْـتَغْفِرُ الله، أَسْـتَغْفِرُ الله .اللّهُـمَّ أَنْـتَ السَّلامُ ، وَمِـنْكَ السَّلام ، تَبارَكْتَ يا ذا الجَـلالِ وَالإِكْـرام",
  ],
  [
    "After the last tashahhud, before salam",
    "بعد التشهد الأخير وقبل السلام",
    "O Allah, I take refuge in You from the punishment of the grave, from the torment of the Fire, from the trials of life and death and from the evil of Al-Maseeh Ad-Dajjal.",
    "اللّهُـمَّ إِنِّـي أَعـوذُ بِكَ مِـنْ عَذابِ القَـبْر، وَمِـنْ عَذابِ جَهَـنَّم، وَمِـنْ فِتْـنَةِ المَحْـيا وَالمَمـات، وَمِـنْ شَـرِّ فِتْـنَةِ المَسيحِ الدَّجّال",
  ],
  [
    "At the start of the prayer",
    "في بداية الصلاة بعد التكبير",
    "How perfect You are O Allah, and I praise You. Blessed be Your name, and lofty is Your position and none has the right to be worshipped except You.",
    "سُبْـحانَكَ اللّهُـمَّ وَبِحَمْـدِكَ وَتَبارَكَ اسْمُـكَ وَتَعـالى جَـدُّكَ وَلا إِلهَ غَيْرُك",
  ],
  [
    "Be among the Righteous",
    "لتكون من الأبرار",
    "Our Lord! Forgive us our sins, wipe out our bad deeds, and grant that we join the righteous when we die.",
    "رَبَّنَا فَاغْفِرْ لَنَا ذُنُوبَنَا وَكَفِّرْ عَنَّا سَيِّئَاتِنَا وَتَوَفَّنَا مَعَ الأبْرَارِ",
  ],
  [
    "Before eating",
    "قبل الأكل",
    "In the name of Allah and with the blessings of Allah I begin (eating).",
    "بِسْمِ اللَّهِ وَعَلَى بَرَكَةِ اللَّهِ",
  ],
  [
    "Before going to the bathroom",
    "قبل الذهاب إلى الحمام",
    "O Allah, I take refuge with you from all evil and evil-doers.",
    "اللَّهُـمَّ إِنِّي أَعُـوذُ بِـكَ مِـنَ الْخُـبْثِ وَالْخَبَائِثِ",
  ],
  [
    "Between takbir and Fatiha",
    "في بداية الصلاة",
    "O Allah, distance me from my sins just as You have distanced the East from the West, and cleanse me of my sins as a white robe is cleansed of filth.",
    "اللّهُـمَّ باعِـدْ بَيـني وَبَيْنَ خَطـايايَ كَما باعَدْتَ بَيْنَ المَشْرِقِ وَالمَغْرِبْ ، اللّهُـمَّ نَقِّنـي مِنْ خَطايايَ كَمـا يُـنَقَّى الثَّـوْبُ الأَبْيَضُ مِنَ الدَّنَسْ",
  ],
  [
    "Between the two prostrations",
    "بين السجدتين",
    "My Lord forgive me, My Lord forgive me.",
    "رَبِّ اغْفِـرْ لي ، رَبِّ اغْفِـرْ لي",
  ],
  [
    "After the athan",
    "بعد الآذان",
    "O Allah, Owner of this perfect call and of this prayer to be performed, bestow upon Muhammad al-waseelah and al-fadeelah and raise him to the praised station You promised him.",
    "اللّهُـمَّ رَبَّ هَذِهِ الدّعْـوَةِ التّـامَّة وَالصّلاةِ القَـائِمَة آتِ محَـمَّداً الوَسيـلةَ وَالْفَضـيلَة وَابْعَـثْه مَقـامـاً مَحـموداً الَّذي وَعَـدْتَه",
  ],
];
const DHIKR0 = [
  ["Subhan Allah", "سُبْحَانَ ٱللَّٰهِ", "Subhan Allah", "سُبْحَانَ ٱللَّٰهِ"],
  [
    "Al-hamdulillah",
    "ٱلْحَمْدُ لِلَّٰهِ",
    "Al-hamdulillah",
    "ٱلْحَمْدُ لِلَّٰهِ",
  ],
  ["Allāhu Akbar", "ٱللَّٰهُ أَكْبَرُ", "Allāhu Akbar", "ٱللَّٰهُ أَكْبَرُ"],
  [
    "La ilaha illallah",
    "لَا إِلَٰهَ إِلَّا ٱللَّٰهُ",
    "La ilaha illallah",
    "لَا إِلَٰهَ إِلَّا ٱللَّٰهُ",
  ],
  ["Astaghfirullah", "ٱسْتِغْفَار", "Astaghfirullah", "ٱسْتِغْفَار"],
  [
    "Darood Sharif",
    "دارود شريف",
    "Allaahumma salli alaa Muhammadinw wa alaa aali Muhammad, kamaa sallayta alaa Ibraaheema wa alaa aali Ibraaheem, innaka Hameedum Majeed.",
    "اَللّٰھُمَّ صَلِّ عَلٰی مُحَمَّدٍ وَّعَلٰٓی اٰلِ مُحَمَّدٍ کَمَا صَلَّیْتَ عَلٰٓی اِبْرَاھِیْمَ وَعَلٰٓی اٰلِ اِبْرَاھِیْمَ اِنَّکَ حَمِیْدٌ مَّجِیْدٌ",
  ],
];
const AUDIO0 = [
  [1, "Al-Fatihah", "الفاتحة", "Mishary Alafasy", "00:49", 1],
  [2, "Al-Baqarah", "البقرة", "Mishary Alafasy", "2:04:12", 1],
  [18, "Al-Kahf", "الكهف", "Abdul Basit", "1:02:30", 1],
  [36, "Ya-Sin", "يس", "Saad Al-Ghamdi", "31:05", 1],
  [55, "Ar-Rahman", "الرحمن", "Mishary Alafasy", "13:20", 1],
  [67, "Al-Mulk", "الملك", "Abdul Basit", "09:44", 0],
  [112, "Al-Ikhlas", "الإخلاص", "Mishary Alafasy", "00:18", 1],
];
const WALLS0 = [
  ["Kaaba at dusk", "#ffa03f", "#7a2a05"],
  ["Green dome", "#34d399", "#064e3b"],
  ["Night sky", "#6366f1", "#1e1b4b"],
  ["Desert dawn", "#fcd34d", "#b45309"],
  ["Calligraphy gold", "#fde68a", "#92400e"],
  ["Ocean mosque", "#38bdf8", "#0c4a6e"],
];
const PRESETS = {
  Emerald: [
    "light",
    "#1A6B4A",
    "#2D8A63",
    "#E8B84B",
    "#FFFFFF",
    "#F5F7FB",
    "#1A1F2E",
    "#5A6478",
    "#E05C5C",
  ],
  Midnight: [
    "dark",
    "#7C9CFF",
    "#5B7BE8",
    "#F5C26B",
    "#0F1424",
    "#1A2036",
    "#F2F4FA",
    "#A3ACC4",
    "#FF6B6B",
  ],
  "Ocean Blue": [
    "light",
    "#0B6BCB",
    "#1E88E5",
    "#FFB74D",
    "#FFFFFF",
    "#EEF5FC",
    "#10243A",
    "#516579",
    "#E05C5C",
  ],
  "Royal Gold": [
    "light",
    "#B8860B",
    "#D4A017",
    "#7B2D26",
    "#FFFDF6",
    "#F8F1DD",
    "#2A2108",
    "#6B5B2E",
    "#C0392B",
  ],
  Amethyst: [
    "dark",
    "#B794F6",
    "#9F7AEA",
    "#F6AD55",
    "#17102A",
    "#241A3F",
    "#F3EEFF",
    "#B5A8D6",
    "#FC8181",
  ],
};
const COLOR_LABELS = [
  "Primary",
  "Secondary",
  "Accent",
  "Background",
  "Surface",
  "Text (primary)",
  "Text (secondary)",
  "Error",
];
const DEF_ST = {
  company: "Nazar-e-Aalam",
  address: "Masjid al-Haram, Makkah",
  nisab: 0,
  currency: "$",
  ramadan: false,
  logo: "",
  icon: "",
  banner: "",
  preset: "Emerald",
  mode: "light",
  colors: PRESETS.Emerald.slice(1),
  ps: "",
  as: "",
  zd: "Our easy-to-use calculator tells you exactly how much zakat you need to give based on what you own. Work out what you own, take off what you owe, check the balance is above the nisab value, then take 2.5% of it. That is your zakat amount.",
};
const getST = () => ({ ...DEF_ST, ...LS.get("settings", {}) });

function seedIfNeeded() {
  if (LS.get("seeded", 0)) return;
  LS.set("admins", [
    {
      id: uid(),
      name: "Naiem Ahemad",
      email: "0xvd12@gmail.com",
      role: "Super Admin",
      status: "Active",
    },
  ]);
  LS.set(
    "dua",
    DUA0.map(([en, ar, fen, far]) => ({ id: uid(), en, ar, fen, far })),
  );
  LS.set(
    "dhikr",
    DHIKR0.map(([en, ar, fen, far]) => ({ id: uid(), en, ar, fen, far })),
  );
  LS.set(
    "audio",
    AUDIO0.map(([num, en, ar, reciter, duration, st]) => ({
      id: uid(),
      num,
      en,
      ar,
      reciter,
      duration,
      status: st ? "Published" : "Draft",
      url: "",
    })),
  );
  LS.set(
    "walls",
    WALLS0.map(([name, c1, c2]) => ({ id: uid(), name, c1, c2, img: "" })),
  );
  LS.set("prayer", {});
  LS.set("log", []);
  LS.set("seeded", 1);
}
function logAct(icon, text) {
  const a = LS.get("log", []);
  a.unshift({ t: Date.now(), i: icon, x: text });
  LS.set("log", a.slice(0, 30));
}

/* ---------- toast + modal ---------- */
function toast(m, bad) {
  const t = document.createElement("div");
  t.className = "toast" + (bad ? " err" : "");
  t.setAttribute("role", "status");
  t.innerHTML = ic(bad ? "x" : "check") + esc(m);
  $("#toasts").append(t);
  setTimeout(() => t.remove(), 3900);
}
let modalCtx = null,
  lastFocus = null;
const modalOpen = () => $("#modal").classList.contains("on");
function openModal(html, small) {
  lastFocus = document.activeElement;
  const m = $("#modal");
  m.innerHTML = `<div class="mb glass${small ? " sm" : ""}" role="dialog" aria-modal="true" aria-labelledby="mt">${html}</div>`;
  m.classList.add("on");
  m.setAttribute("aria-hidden", "false");
  document.body.classList.add("noscroll");
  setTimeout(() => {
    const f = m.querySelector("input:not([type=hidden]),textarea,select,.btn");
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
    `<div class="mh"><h3 id="mt">${esc(title)}</h3><button type="button" class="x" data-act="close" aria-label="Close">${ic("x")}</button></div>
<p class="msg">${esc(msg)}</p><div class="mfoot"><button type="button" class="b3" data-act="close">${esc(tr("Cancel"))}</button><button type="button" class="btn danger" data-act="confirm">${esc(tr(ok))}</button></div>`,
    true,
  );
  modalCtx = { onOk };
}
const fld = (f, v) => {
  const id = "f_" + f.k,
    val = v ?? f.def ?? "",
    rtl = f.ar ? ' dir="rtl"' : "",
    cls = "in" + (f.ar ? " ar" : "");
  let inp;
  if (f.t === "area")
    inp = `<textarea class="${cls}" id="${id}" name="${f.k}" rows="4"${rtl}>${esc(val)}</textarea>`;
  else if (f.t === "select")
    inp = `<select class="${cls}" id="${id}" name="${f.k}">${f.o.map((o) => `<option${o === val ? " selected" : ""}>${esc(o)}</option>`).join("")}</select>`;
  else if (f.t === "file")
    inp = `<input class="${cls}" id="${id}" name="${f.k}" type="file" accept="${f.accept || "image/png,image/jpeg,image/webp"}">`;
  else
    inp = `<input class="${cls}" id="${id}" name="${f.k}" type="${f.t || "text"}" value="${esc(val)}"${rtl}${f.min != null ? ` min="${f.min}"` : ""}${f.max != null ? ` max="${f.max}"` : ""}${f.t === "number" ? ' step="1"' : ""} autocomplete="off">`;
  return `<div class="${f.full ? "full" : ""}"><label for="${id}">${esc(f.l)}${f.req ? '<span class="rq" aria-hidden="true">*</span>' : ""}</label>${inp}${f.h ? `<div class="hint">${esc(f.h)}</div>` : ""}</div>`;
};
function formModal({ title, fields, data = {}, okLabel = "Save", onSubmit }) {
  openModal(`<form id="mform" novalidate><div class="mh"><h3 id="mt">${esc(title)}</h3><button type="button" class="x" data-act="close" aria-label="Close">${ic("x")}</button></div>
<div class="mf">${fields.map((f) => fld(f, data[f.k])).join("")}</div><div class="err" id="merr" role="alert"></div>
<div class="mfoot"><button type="button" class="b3" data-act="close">${esc(tr("Cancel"))}</button><button class="btn" type="submit"><span class="bt">${esc(tr(okLabel))}</span><span class="sp2"></span></button></div></form>`);
  $("#mform").onsubmit = async (e) => {
    e.preventDefault();
    const form = e.target,
      btn = $(".btn", form),
      vals = {};
    let bad = null;
    $$(".in", form).forEach((i) => i.removeAttribute("aria-invalid"));
    for (const f of fields) {
      const el = form.querySelector(`[name="${f.k}"]`);
      let v = f.t === "file" ? el.files[0] || null : String(el.value).trim();
      const fail = (msg) => {
        if (!bad) bad = { el, msg };
      };
      if (f.req && !v) {
        fail(`${f.l} is required.`);
        continue;
      }
      if (v && f.t === "email" && !/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(v))
        fail("Enter a valid email address.");
      if (v && f.t === "url" && !isUrl(v))
        fail(`${f.l} must start with http:// or https://`);
      if (v && f.t === "number") {
        const n = Number(v);
        if (
          !Number.isInteger(n) ||
          (f.min != null && n < f.min) ||
          (f.max != null && n > f.max)
        )
          fail(
            `${f.l} must be a whole number${f.min != null ? ` from ${f.min} to ${f.max}` : ""}.`,
          );
        else v = n;
      }
      if (v && f.pat && !f.pat.test(v))
        fail(f.pm || `${f.l} is not in the right format.`);
      vals[f.k] = v;
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
      const msg = await onSubmit(vals);
      if (msg) show(null, msg);
      else closeModal();
    } catch (err) {
      show(null, err.message || "Something went wrong.");
    } finally {
      btn.classList.remove("load");
      btn.disabled = false;
    }
  };
}

/* ---------- collections (Add / Edit / Delete) ---------- */
const c = (t) => `<td>${esc(t)}</td>`;
const cw = (t) => `<td class="wrap">${esc(t)}</td>`;
const ca = (t) => `<td class="rtl wrap">${esc(t)}</td>`;
const ch = (h) => `<td>${h}</td>`;
const acts = (key, id, what) =>
  `<span class="act-b"><button type="button" aria-label="Edit ${esc(what)}" title="Edit" data-act="edit" data-c="${key}" data-id="${id}">${ic("edit")}</button><button type="button" class="d" aria-label="Delete ${esc(what)}" title="Delete" data-act="del" data-c="${key}" data-id="${id}">${ic("trash")}</button></span>`;
const me = () => (S.get("e") || "").toLowerCase();
const supers = (arr) => arr.filter((a) => a.role === "Super Admin").length;
const TEXT2 = [
  { k: "en", l: "Short name (English)", req: 1 },
  { k: "ar", l: "Short name (Arabic)", req: 1, ar: 1 },
];
const COL = {
  admins: {
    icon: "shield",
    noun: "admin",
    title: "Administrators",
    sub: "People who can sign in to this panel",
    add: "Add admin",
    cols: ["Name", "Email", "Role", "Status", "Action"],
    defaults: { role: "Admin", status: "Active" },
    fields: [
      { k: "name", l: "Full name", req: 1 },
      { k: "email", l: "Email", t: "email", req: 1 },
      {
        k: "role",
        l: "Role",
        t: "select",
        o: ["Super Admin", "Admin", "Editor"],
      },
      { k: "status", l: "Status", t: "select", o: ["Active", "Disabled"] },
    ],
    label: (x) => x.name,
    row: (x) =>
      c(x.name) +
      c(x.email) +
      ch(`<span class="pill">${esc(x.role)}</span>`) +
      ch(
        `<span class="pill ${x.status === "Active" ? "ok" : "off"}">${esc(x.status)}</span>`,
      ) +
      ch(acts("admins", x.id, "this admin")),
    prep: (v) => {
      v.email = v.email.toLowerCase();
    },
    check: (v, id, arr) => {
      if (arr.some((a) => a.id !== id && a.email.toLowerCase() === v.email))
        return "An admin with this email already exists.";
      const old = arr.find((a) => a.id === id);
      if (old) {
        if (
          old.role === "Super Admin" &&
          v.role !== "Super Admin" &&
          supers(arr) < 2
        )
          return "At least one Super Admin is required.";
        if (old.email.toLowerCase() === me() && v.status === "Disabled")
          return "You can't disable the account you are signed in with.";
      }
    },
    canDelete: (x, arr) => {
      if (x.email.toLowerCase() === me())
        return "You can't delete the account you are signed in with.";
      if (x.role === "Super Admin" && supers(arr) < 2)
        return "At least one Super Admin is required.";
    },
  },
  audio: {
    icon: "head",
    noun: "recitation",
    title: "Audio Quran",
    sub: "Recitations available in the app",
    add: "Upload audio",
    cols: [
      "#",
      "Surah (En)",
      "Surah (Ar)",
      "Reciter",
      "Duration",
      "Status",
      "Play",
      "Action",
    ],
    defaults: { status: "Published" },
    fields: [
      { k: "num", l: "Surah number", t: "number", min: 1, max: 114, req: 1 },
      { k: "en", l: "Surah name (English)", req: 1 },
      { k: "ar", l: "Surah name (Arabic)", req: 1, ar: 1 },
      { k: "reciter", l: "Reciter", req: 1 },
      {
        k: "duration",
        l: "Duration",
        pat: /^(\d{1,2}:)?\d{1,2}:\d{2}$/,
        pm: "Duration must look like 12:30 or 1:02:30.",
        h: "Format mm:ss or h:mm:ss",
      },
      { k: "status", l: "Status", t: "select", o: ["Published", "Draft"] },
      {
        k: "url",
        l: "Audio file link",
        t: "url",
        full: 1,
        h: "Optional. A link to an MP3 file; the play button uses it.",
      },
    ],
    label: (x) => x.en,
    sort: (a, b) => a.num - b.num || String(a.reciter).localeCompare(b.reciter),
    row: (x) =>
      c(x.num) +
      c(x.en) +
      ca(x.ar) +
      c(x.reciter) +
      c(x.duration || "—") +
      ch(
        `<span class="pill ${x.status === "Published" ? "ok" : "off"}">${esc(x.status)}</span>`,
      ) +
      ch(
        `<span class="act-b"><button type="button" aria-label="Play ${esc(x.en)}" title="Play" data-act="play" data-id="${x.id}">${ic("play")}</button></span>`,
      ) +
      ch(acts("audio", x.id, "this audio")),
    check: (v, id, arr) =>
      arr.some(
        (a) =>
          a.id !== id &&
          a.num === v.num &&
          a.reciter.toLowerCase() === v.reciter.toLowerCase(),
      )
        ? "This surah already exists for that reciter."
        : "",
  },
  dua: {
    icon: "heart",
    noun: "dua",
    title: "Dua List",
    sub: "Supplications shown in the app",
    add: "Add dua",
    cols: [
      "Position",
      "Short name (En)",
      "Short name (Ar)",
      "Full dua (En)",
      "Full dua (Ar)",
      "Action",
    ],
    fields: [
      ...TEXT2,
      { k: "fen", l: "Full dua (English)", t: "area", full: 1, req: 1 },
      { k: "far", l: "Full dua (Arabic)", t: "area", ar: 1, full: 1, req: 1 },
    ],
    label: (x) => x.en,
    row: (x, i) =>
      c(i + 1) +
      c(x.en) +
      ca(x.ar) +
      cw(x.fen) +
      ca(x.far) +
      ch(acts("dua", x.id, "this dua")),
  },
  dhikr: {
    icon: "beads",
    noun: "dhikr",
    title: "Dhikr List",
    sub: "Remembrances for the tasbih counter",
    add: "Add dhikr",
    cols: [
      "Position",
      "Short name (En)",
      "Short name (Ar)",
      "Full name (En)",
      "Full name (Ar)",
      "Action",
    ],
    fields: [
      ...TEXT2,
      { k: "fen", l: "Full text (English)", t: "area", full: 1, req: 1 },
      { k: "far", l: "Full text (Arabic)", t: "area", ar: 1, full: 1, req: 1 },
    ],
    label: (x) => x.en,
    row: (x, i) =>
      c(i + 1) +
      c(x.en) +
      ca(x.ar) +
      cw(x.fen) +
      ca(x.far) +
      ch(acts("dhikr", x.id, "this dhikr")),
  },
  walls: {
    icon: "img",
    noun: "wallpaper",
    title: "Wallpapers",
    sub: "Backgrounds people can set from the app",
    add: "Add wallpaper",
    defaults: { c1: "#ffa03f", c2: "#7a2a05" },
    fields: [
      { k: "name", l: "Name", req: 1, full: 1 },
      { k: "c1", l: "Gradient start", t: "color" },
      { k: "c2", l: "Gradient end", t: "color" },
      {
        k: "img",
        l: "Image",
        t: "file",
        full: 1,
        h: "Optional. PNG, JPG or WebP. It is resized to fit browser storage. Without an image the gradient is used.",
      },
    ],
    label: (x) => x.name,
    prep: async (v, old) => {
      v.img = v.img
        ? await fileToDataURL(v.img, 720, false)
        : old
          ? old.img
          : "";
    },
  },
};
function openForm(key, id) {
  const g = COL[key],
    arr = list(key),
    old = id ? arr.find((x) => x.id === id) : null;
  if (id && !old) return toast("That item no longer exists.", 1);
  formModal({
    title: `${id ? "Edit" : "Add"} ${g.noun}`,
    fields: g.fields,
    data: old || g.defaults || {},
    onSubmit: async (v) => {
      if (g.prep) await g.prep(v, old);
      const e = g.check && g.check(v, id, arr);
      if (e) return e;
      const i = old ? arr.findIndex((x) => x.id === id) : -1;
      if (i >= 0) arr[i] = { ...arr[i], ...v };
      else arr.push({ id: uid(), ...v });
      if (g.sort) arr.sort(g.sort);
      commit(key, arr);
      logAct(g.icon, `${old ? "Updated" : "Added"} ${g.noun}: ${g.label(v)}`);
      toast(`${cap(g.noun)} ${old ? "updated" : "added"}.`);
      render();
    },
  });
}
function askDelete(key, id) {
  const g = COL[key],
    arr = list(key),
    x = arr.find((a) => a.id === id);
  if (!x) return;
  const why = g.canDelete && g.canDelete(x, arr);
  if (why) return toast(why, 1);
  confirmBox({
    title: `Delete ${g.noun}?`,
    msg: `"${g.label(x)}" will be removed. This can't be undone.`,
    onOk: () => {
      commit(
        key,
        list(key).filter((a) => a.id !== id),
      );
      logAct("trash", `Deleted ${g.noun}: ${g.label(x)}`);
      toast(`${cap(g.noun)} deleted.`);
      render();
    },
  });
}

/* ---------- audio playback ---------- */
const AUD = { a: null, id: null };
function stopAudio() {
  if (AUD.a) {
    AUD.a.pause();
    AUD.a = null;
    AUD.id = null;
  }
}
function playAudio(btn) {
  const x = list("audio").find((a) => a.id === btn.dataset.id);
  if (!x) return;
  if (!x.url)
    return toast(
      "No audio file linked. Edit this recitation and add a file link.",
      1,
    );
  const same = AUD.id === x.id;
  stopAudio();
  $$('[data-act="play"]').forEach((b) => {
    b.innerHTML = ic("play");
    b.title = "Play";
  });
  if (same) return;
  const a = new Audio(x.url);
  AUD.a = a;
  AUD.id = x.id;
  btn.innerHTML = ic("pause");
  btn.title = "Pause";
  const reset = () => {
    if (AUD.a === a) {
      AUD.a = null;
      AUD.id = null;
    }
    btn.innerHTML = ic("play");
    btn.title = "Play";
  };
  a.onended = reset;
  a.onerror = () => {
    reset();
    toast("Couldn't play that file. Check the link.", 1);
  };
  a.play().catch(() => {
    reset();
    toast("Couldn't play that file. Check the link.", 1);
  });
}

/* ---------- shared page builders ---------- */
const head = (icon, title, sub, btn, key) =>
  `<div class="eh"><div class="ic">${ic(icon)}</div><div><h3>${esc(tr(title))}</h3><p>${esc(sub)}</p></div>${btn ? `<button type="button" class="b2" data-act="add" data-c="${key}">${ic("plus")}${esc(tr(btn))}</button>` : ""}</div>`;
function listPage(key) {
  const g = COL[key],
    arr = list(key);
  return `<div class="card glass s12">${head(g.icon, g.title, g.sub, g.add, key)}
<div class="tb"><div class="fld">${ic("search")}<input type="search" placeholder="${esc(tr("Search"))}…" aria-label="Search" data-filter></div></div>
<div class="tw"><table><thead><tr>${g.cols.map((x) => `<th>${esc(tr(x))}</th>`).join("")}</tr></thead><tbody>${arr.map((x, i) => `<tr>${g.row(x, i)}</tr>`).join("")}</tbody></table></div>
<div class="empty"${arr.length ? " hidden" : ""}>${arr.length ? "" : "Nothing here yet. Use the button above to add the first one."}</div><div class="foot">${arr.length} total</div></div>`;
}
function filt(inp) {
  const card = inp.closest(".card"),
    q = inp.value.toLowerCase().trim(),
    rows = $$("tbody tr", card);
  let n = 0;
  rows.forEach((tr_) => {
    const ok = tr_.textContent.toLowerCase().includes(q);
    tr_.hidden = !ok;
    n += ok;
  });
  const e = $(".empty", card);
  e.hidden = n > 0;
  e.textContent = rows.length
    ? "No matches. Try a different word."
    : "Nothing here yet. Use the button above to add the first one.";
  $(".foot", card).textContent = q
    ? `${n} of ${rows.length} shown`
    : `${rows.length} total`;
}
function wallPage() {
  const g = COL.walls,
    arr = list("walls");
  const tile = (w) =>
    `<div class="wp" style="background:linear-gradient(160deg,${esc(w.c1)},${esc(w.c2)})">${w.img ? `<img src="${esc(w.img)}" alt="${esc(w.name)}" loading="lazy">` : ""}<span class="act-b">${`<button type="button" aria-label="Edit ${esc(w.name)}" title="Edit" data-act="edit" data-c="walls" data-id="${w.id}">${ic("edit")}</button><button type="button" class="d" aria-label="Delete ${esc(w.name)}" title="Delete" data-act="del" data-c="walls" data-id="${w.id}">${ic("trash")}</button>`}</span><span class="n">${esc(w.name)}</span></div>`;
  return `<div class="card glass s12">${head(g.icon, g.title, g.sub, g.add, "walls")}${arr.length ? `<div class="wg">${arr.map(tile).join("")}</div>` : `<div class="empty">No wallpapers yet. Use the button above to add one.</div>`}<div class="foot">${arr.length} total</div></div>`;
}

/* ---------- prayer times ---------- */
const MONTHS = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];
const PCITIES = ["Makkah", "Madinah"];
const PK = ["imsak", "fajr", "sunrise", "zuhr", "asr", "maghrib", "isha"];
const NOW0 = new Date();
let pm = NOW0.getMonth(),
  py = NOW0.getFullYear(),
  pcity = "Makkah";
const hm = (m) => {
  m = ((Math.round(m) % 1440) + 1440) % 1440;
  return `${pad((m / 60) | 0)}:${pad(m % 60)}`;
};
const toMin = (s) => {
  const [h, m] = s.split(":");
  return +h * 60 + +m;
};
const t12 = (m) => {
  m = ((Math.round(m) % 1440) + 1440) % 1440;
  const h = (m / 60) | 0;
  return `${h % 12 || 12}:${pad(m % 60)} ${h < 12 ? "AM" : "PM"}`;
};
const t12s = (s) => t12(toMin(s));
const ymd = (y, m, d) => `${y}-${pad(m + 1)}-${pad(d)}`;
function baseTimes(city, m, d) {
  const off = city === "Madinah" ? -4 : 0;
  const sh = Math.sin(((m * 30 + d - 80) / 365) * 2 * Math.PI) * 45;
  const fajr = 300 - sh * 0.9 + off,
    sunrise = fajr + 80 - sh * 0.1,
    zuhr = 740 + off,
    asr = zuhr + 205 + sh * 0.2,
    mag = zuhr + 380 + sh * 0.8 + off,
    isha = mag + 80;
  return { imsak: fajr - 10, fajr, sunrise, zuhr, asr, maghrib: mag, isha };
}
function timesFor(city, y, m, d) {
  const o = LS.get("prayer", {})[`${city}|${ymd(y, m, d)}`];
  if (o) return { ...o, edited: true };
  const b = baseTimes(city, m, d),
    r = {};
  PK.forEach((k) => (r[k] = hm(b[k])));
  return r;
}
function prayerPage() {
  const days = new Date(py, pm + 1, 0).getDate(),
    now = new Date();
  const years = [
    ...new Set([
      now.getFullYear() - 2,
      now.getFullYear() - 1,
      now.getFullYear(),
      now.getFullYear() + 1,
      now.getFullYear() + 2,
      py,
    ]),
  ].sort();
  const rows = Array.from({ length: days }, (_, k) => {
    const d = k + 1,
      t = timesFor(pcity, py, pm, d),
      iso = ymd(py, pm, d);
    const today =
      now.getFullYear() === py && now.getMonth() === pm && now.getDate() === d;
    return `<tr class="${today ? "today" : ""}"><td style="font-weight:700">${pad(d)}.${pad(pm + 1)}.${py}${t.edited ? '<span class="pill warn">Edited</span>' : ""}</td>
<td>${t12s(t.imsak)}</td><td>${t12s(t.fajr)}</td><td>${t12s(t.sunrise)}</td><td>${t12s(t.zuhr)}</td><td>${t12s(t.asr)}</td><td>${t12s(t.maghrib)}</td><td>${t12s(t.isha)}</td><td>${t12s(t.maghrib)}</td><td>${t12s(t.imsak)}</td>
<td><span class="act-b"><button type="button" aria-label="Edit ${iso}" title="Edit" data-act="pedit" data-d="${iso}">${ic("edit")}</button><button type="button" class="d" aria-label="Reset ${iso} to default" title="Reset to default" data-act="pdel" data-d="${iso}"${t.edited ? "" : " disabled"}>${ic("trash")}</button></span></td></tr>`;
  }).join("");
  const th = [
    "Date",
    "Imsak",
    "Fajr",
    "Sunrise",
    "Zuhr",
    "Asr",
    "Maghrib",
    "Isha",
    "Iftar",
    "Sehri",
    "Action",
  ];
  return `<div class="card glass s12"><div class="eh"><div class="ic">${ic("clock")}</div><div><h3>${esc(tr("Prayer Times"))}</h3><p>${MONTHS[pm]} ${py} · ${esc(pcity)}</p></div><button type="button" class="b2" data-act="padd">${ic("plus")}${esc(tr("Add prayer time"))}</button></div>
<div class="tb"><select class="in" aria-label="City" data-change="pcity">${PCITIES.map((x) => `<option${x === pcity ? " selected" : ""}>${x}</option>`).join("")}</select>
<select class="in" aria-label="Year" data-change="pyear">${years.map((y) => `<option${y === py ? " selected" : ""}>${y}</option>`).join("")}</select>
<button type="button" class="b3" data-act="pimport">${ic("upload")}${esc(tr("Import"))}</button><button type="button" class="b3" data-act="pexport">${ic("down")}${esc(tr("Export"))}</button>
<input type="file" accept=".csv,text/csv,text/plain" hidden data-change="pimp"></div>
<div class="months" role="tablist" aria-label="Month">${MONTHS.map((m, i) => `<button type="button" role="tab" aria-selected="${i === pm}" class="${i === pm ? "on" : ""}" data-act="pmonth" data-i="${i}">${m}</button>`).join("")}</div>
<div class="tw"><table><thead><tr>${th.map((x) => `<th>${esc(tr(x))}</th>`).join("")}</tr></thead><tbody>${rows}</tbody></table></div>
<div class="foot">${days} days · times are demo values until you edit or import them. CSV columns: date,imsak,fajr,sunrise,zuhr,asr,maghrib,isha (24-hour).</div></div>`;
}
const PFIELDS = [
  { k: "date", l: "Date", t: "date", req: 1 },
  { k: "city", l: "City", t: "select", o: PCITIES },
  ...PK.map((k) => ({ k, l: cap(k), t: "time", req: 1 })),
];
function checkTimes(v) {
  for (let i = 1; i < PK.length; i++)
    if (toMin(v[PK[i]]) <= toMin(v[PK[i - 1]]))
      return `${cap(PK[i])} must be later than ${cap(PK[i - 1])}.`;
}
function prayerForm(iso) {
  const now = new Date(),
    d0 = iso || ymd(now.getFullYear(), now.getMonth(), now.getDate());
  const [y, m, d] = d0.split("-").map(Number);
  formModal({
    title: iso ? "Edit prayer time" : "Add prayer time",
    fields: PFIELDS,
    data: { date: d0, city: pcity, ...timesFor(pcity, y, m - 1, d) },
    onSubmit: (v) => {
      const [yy, mm, dd] = v.date.split("-").map(Number);
      if (!yy || yy < 2000 || yy > 2100) return "Choose a valid date.";
      const e = checkTimes(v);
      if (e) return e;
      const all = LS.get("prayer", {}),
        t = {};
      PK.forEach((k) => (t[k] = v[k]));
      all[`${v.city}|${ymd(yy, mm - 1, dd)}`] = t;
      commit("prayer", all);
      pcity = v.city;
      py = yy;
      pm = mm - 1;
      logAct(
        "clock",
        `Saved prayer times for ${pad(dd)}.${pad(mm)}.${yy} (${v.city})`,
      );
      toast("Prayer time saved.");
      render();
    },
  });
}
const normTime = (s) => {
  const m = String(s)
    .trim()
    .match(/^(\d{1,2}):(\d{2})\s*(AM|PM)?$/i);
  if (!m) return null;
  let h = +m[1];
  const mi = +m[2],
    ap = m[3] && m[3].toUpperCase();
  if (ap) {
    if (h < 1 || h > 12) return null;
    h = (h % 12) + (ap === "PM" ? 12 : 0);
  }
  if (h > 23 || mi > 59) return null;
  return `${pad(h)}:${pad(mi)}`;
};
const normDate = (s) => {
  s = String(s).trim();
  let m = s.match(/^(\d{4})-(\d{1,2})-(\d{1,2})$/),
    y,
    mo,
    d;
  if (m) {
    y = +m[1];
    mo = +m[2];
    d = +m[3];
  } else if ((m = s.match(/^(\d{1,2})[./](\d{1,2})[./](\d{4})$/))) {
    d = +m[1];
    mo = +m[2];
    y = +m[3];
  } else return null;
  const dt = new Date(y, mo - 1, d);
  return dt.getFullYear() === y &&
    dt.getMonth() === mo - 1 &&
    dt.getDate() === d
    ? { y, m: mo - 1, d }
    : null;
};
function importPrayer(text) {
  const all = LS.get("prayer", {});
  let ok = 0,
    skip = 0,
    first = null;
  text.split(/\r?\n/).forEach((line) => {
    if (!line.trim()) return;
    const cells = line.split(/[,;\t]/).map((x) => x.trim());
    const dt = normDate(cells[0]);
    if (!dt) {
      if (!/date/i.test(cells[0])) skip++;
      return;
    }
    const t = {};
    for (let i = 0; i < PK.length; i++) {
      t[PK[i]] = normTime(cells[i + 1] || "");
      if (!t[PK[i]]) {
        skip++;
        return;
      }
    }
    if (checkTimes(t)) {
      skip++;
      return;
    }
    all[`${pcity}|${ymd(dt.y, dt.m, dt.d)}`] = t;
    if (!first) first = dt;
    ok++;
  });
  if (!ok)
    return toast(
      skip
        ? "No valid rows found. Check the CSV columns and time format."
        : "That file is empty.",
      1,
    );
  commit("prayer", all);
  py = first.y;
  pm = first.m;
  logAct("clock", `Imported ${ok} prayer-time rows (${pcity})`);
  toast(
    `Imported ${ok} day${ok > 1 ? "s" : ""}${skip ? `, skipped ${skip} bad row${skip > 1 ? "s" : ""}` : ""}.`,
  );
  render();
}
function exportPrayer() {
  const days = new Date(py, pm + 1, 0).getDate();
  const out = ["date," + PK.join(",")];
  for (let d = 1; d <= days; d++) {
    const t = timesFor(pcity, py, pm, d);
    out.push([ymd(py, pm, d), ...PK.map((k) => t[k])].join(","));
  }
  download(
    `prayer-times-${pcity.toLowerCase()}-${py}-${pad(pm + 1)}.csv`,
    out.join("\n"),
    "text/csv",
  );
  toast("Prayer times exported.");
}

/* ---------- dashboard ---------- */
let TM = [],
  PRN = [];
function np() {
  const n = new Date(),
    s = n.getHours() * 3600 + n.getMinutes() * 60 + n.getSeconds();
  let i = TM.findIndex((t) => t * 60 > s),
    a,
    b;
  if (i < 0) {
    i = 0;
    b = TM[0] * 60 + 86400;
    a = TM[4] * 60;
  } else {
    b = TM[i] * 60;
    a = i ? TM[i - 1] * 60 : TM[4] * 60 - 86400;
  }
  return { i, left: b - s, f: Math.min(1, Math.max(0, (s - a) / (b - a))) };
}
function t() {
  const e = $("#cd");
  if (!e) return clearInterval(tick);
  const r = np();
  e.textContent = fmt(r.left);
  $("#rg").style.strokeDashoffset = 100 * (1 - r.f);
  $("b", e.parentNode).textContent = tr(PRN[r.i][0]);
  $$(".pr div").forEach((d, k) => d.classList.toggle("nx", k === r.i));
}
const SP = [
  [3, 5, 4, 7, 6, 9, 8],
  [2, 4, 3, 5, 7, 6, 9],
  [5, 4, 6, 5, 8, 7, 10],
  [4, 6, 5, 8, 7, 9, 12],
];
/* Demo analytics used by the Total Users stat + Platform breakdown card */
const DEMO = { users: 240, android: 180, ios: 60 };
const stat = (i, n, l, x) => {
  const k = kk++,
    d = sm(n ? SP[k % 4] : [0, 0, 0, 0, 0, 0, 0], 200, 46);
  return `<div class="card glass s3 stat"><div class="top"><div class="ic">${ic(i)}</div></div><div class="num" data-n="${n}">0</div><div class="lbl">${esc(tr(l))}${x ? ` <em>/ ${x}</em>` : ""}</div><svg class="sk" viewBox="0 0 200 46" preserveAspectRatio="none" aria-hidden="true"><path class="fl" d="${d}L200 46L0 46Z"/><path class="ln" pathLength="1" d="${d}"/></svg></div>`;
};
function platformCard() {
  const total = Math.max(1, DEMO.users);
  const aPct = Math.round((DEMO.android / total) * 100);
  const iPct = Math.max(0, 100 - aPct);
  const aOff = 100 - aPct;
  const iOff = 100 - iPct;
  const iRot = -90 + aPct * 3.6;
  return `<div class="card glass s3 plat">
<div class="lbl">${esc(tr("Platform breakdown"))} <span class="tag">Demo data</span></div>
<div class="dn">
  <div class="pdonut">
    <svg viewBox="0 0 42 42" role="img" aria-label="Android ${DEMO.android} users, iOS ${DEMO.ios} users">
      <circle cx="21" cy="21" r="15.9" fill="none" stroke="rgba(130,60,10,.12)" stroke-width="4"/>
      <circle class="dfg" cx="21" cy="21" r="15.9" fill="none" stroke="url(#gr)" stroke-width="4" stroke-linecap="round" pathLength="100" stroke-dasharray="100" stroke-dashoffset="100" data-target="${aOff}" transform="rotate(-90 21 21)"/>
      <circle class="dfg" cx="21" cy="21" r="15.9" fill="none" stroke="#f6c9ab" stroke-width="4" stroke-linecap="round" pathLength="100" stroke-dasharray="100" stroke-dashoffset="100" data-target="${iOff}" transform="rotate(${iRot} 21 21)"/>
      <g font-family="Manrope, system-ui, sans-serif" text-anchor="middle">
        <text x="21" y="21" font-size="9" font-weight="800" fill="#2b1608" dominant-baseline="middle"><tspan data-n="${total}">0</tspan></text>
        <text x="21" y="27" font-size="2.4" font-weight="700" fill="#7d5a42" letter-spacing=".35">TOTAL</text>
      </g>
    </svg>
  </div>
  <div class="lg2">
    <span><i style="background:#e4530b"></i>Android<b>${DEMO.android}</b></span>
    <span><i style="background:#f6c9ab"></i>iOS<b>${DEMO.ios}</b></span>
  </div>
</div>
</div>`;
}
function dashboard(nm) {
  const now = new Date();
  const dt = now.toLocaleDateString(lang === "ar" ? "ar" : "en-US", {
    weekday: "long",
    month: "long",
    day: "numeric",
  });
  const h = now.getHours(),
    g = h < 12 ? "Good morning" : h < 18 ? "Good afternoon" : "Good evening";
  const today = timesFor(
    "Makkah",
    now.getFullYear(),
    now.getMonth(),
    now.getDate(),
  );
  PRN = [
    ["Fajr", today.fajr],
    ["Dhuhr", today.zuhr],
    ["Asr", today.asr],
    ["Maghrib", today.maghrib],
    ["Isha", today.isha],
  ];
  TM = PRN.map(([, x]) => toMin(x));
  const r = np(),
    cd = sm([12, 18, 14, 26, 22, 34, 30], 600, 160);
  tick = setInterval(t, 1000);
  const log = LS.get("log", []).slice(0, 5);
  const cnt = (k) => list(k).length;
  return `<svg width="0" height="0" style="position:absolute" aria-hidden="true"><defs><linearGradient id="sf" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#ff7a1a" stop-opacity=".32"/><stop offset="1" stop-color="#ff7a1a" stop-opacity="0"/></linearGradient><linearGradient id="gr" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#ffa03f"/><stop offset="1" stop-color="#e4530b"/></linearGradient></defs></svg>
<div class="card glass hero s8"><svg class="wv" viewBox="0 0 800 70" preserveAspectRatio="none" aria-hidden="true"><path d="M0 35C50 5 150 65 200 35S350 5 400 35 550 65 600 35 750 5 800 35V70H0Z"/></svg>
<div class="ar">بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ</div><h2>${esc(tr(g))}, ${esc(nm)} 👋</h2><p>Your panel is live. Everything you add is saved in this browser.</p>
<div class="hrow"><span>${ic("clock")}${esc(dt)}</span></div>
<div class="qa"><button type="button" data-act="go" data-p="Dua" data-then="add">${ic("plus")}${esc(tr("Add dua"))}</button><button type="button" data-act="go" data-p="Audio Quran" data-then="add">${ic("head")}${esc(tr("Upload audio"))}</button><button type="button" class="g" data-act="go" data-p="Wallpaper" data-then="add">${ic("img")}${esc(tr("Add wallpaper"))}</button></div></div>
<div class="card glass np s4"><small>${esc(tr("Next prayer"))} · Makkah</small><div class="rg"><svg viewBox="0 0 36 36" aria-hidden="true"><circle class="bg" cx="18" cy="18" r="15.9"/><circle id="rg" class="fg" cx="18" cy="18" r="15.9" pathLength="100"/></svg><div><b>${esc(tr(PRN[r.i][0]))}</b><em id="cd">${fmt(r.left)}</em></div></div>
<div class="pr">${PRN.map(([n, x], k) => `<div class="${k === r.i ? "nx" : ""}"><span>${esc(tr(n))}</span><b>${x}</b></div>`).join("")}</div></div>
${stat("head", cnt("audio"), "Audio recitations")}${stat("img", cnt("walls"), "Wallpapers")}${stat("user", DEMO.users, "Total Users")}${stat("shield", cnt("admins"), "Administrators")}
${stat("book", 114, "Total Surah", 114)}${stat("heart", cnt("dua"), "Total Dua")}${stat("beads", cnt("dhikr"), "Total Dhikr")}${platformCard()}`;
}
function animate() {
  $$("[data-n]").forEach((e) => {
    const tg = +e.dataset.n,
      s = performance.now();
    (function f(n) {
      if (!e.isConnected) return;
      const p = Math.min((n - s) / 1200, 1);
      e.textContent = Math.round(tg * (1 - Math.pow(1 - p, 4)));
      if (p < 1) requestAnimationFrame(f);
    })(s);
  });
  setTimeout(() => {
    $$("[data-w]").forEach((e) => (e.style.width = e.dataset.w + "%"));
    $$(".dfg").forEach(
      (e) => (e.style.strokeDashoffset = e.dataset.target ?? 0),
    );
    const r = $("#rg");
    if (r) r.style.strokeDashoffset = 100 * (1 - np().f);
  }, 150);
}

/* ---------- settings ---------- */
let draft = null;
const sw = (id, ti, d, on) =>
  `<label class="sw" for="${id}" style="margin-bottom:0"><div><b>${ti}</b><small>${d}</small></div><input type="checkbox" id="${id}"${on ? " checked" : ""}><span class="tg"></span></label>`;
const thumb = (v) => (v ? `<img src="${esc(v)}" alt="">` : ic("img"));
const upl = (k, ti, h, v) =>
  `<div><label>${ti}</label><div class="up"><div class="th" id="th_${k}">${thumb(v)}</div><div><b>${ti}</b><small>${h}</small></div><button type="button" class="b3" data-act="pick-img" data-k="${k}">${ic("upload")}Upload</button><button type="button" class="b3" data-act="clear-img" data-k="${k}" aria-label="Remove ${ti}" title="Remove">${ic("trash")}</button><input type="file" accept="image/png,image/jpeg,image/webp" hidden data-change="img" data-k="${k}"></div></div>`;
const sec = (icon, ti, s, body) =>
  `<div class="card glass s12"><div class="ch"><div class="ic">${ic(icon)}</div><div><b>${esc(tr(ti))}</b><small>${esc(s)}</small></div></div>${body}</div>`;
const presetBtns = () =>
  Object.entries(PRESETS)
    .map(
      ([n, p]) =>
        `<button type="button" class="pst${n === draft.preset ? " on" : ""}" aria-pressed="${n === draft.preset}" data-act="preset" data-n="${esc(n)}"><div class="sw3">${[1, 2, 3].map((i) => `<i style="background:${p[i]}"></i>`).join("")}</div><b>${esc(n)}</b><small>${p[0]}</small></button>`,
    )
    .join("");
const colorFields = (cols) =>
  COLOR_LABELS.map(
    (l, i) =>
      `<div><label for="h${i}">${l}</label><div class="cp"><input type="color" id="c${i}" data-sync data-i="${i}" value="${cols[i].toLowerCase()}" aria-label="${l} color picker"><input class="in" id="h${i}" data-sync data-i="${i}" value="${cols[i].toUpperCase()}" maxlength="7" autocomplete="off"></div></div>`,
  ).join("");
function getProfile() {
  const email = S.get("e") || "",
    a = adminOf(email);
  const first = (S.get("u") || "admin").split(/[._\-+]/)[0];
  const def = { name: a ? a.name : cap(first), email, phone: "", avatar: "" };
  return { ...def, ...(LS.get("profiles", {})[pkey()] || {}) };
}
function applyUser() {
  const p = getProfile();
  $("#un").textContent = p.name;
  $("#ini").innerHTML = avatarHTML(p);
}
function settingsPage() {
  const p = getProfile(),
    a = adminOf(p.email);
  draft = { avatar: p.avatar };
  return `${sec(
    "user",
    "Profile",
    "Your account details for this admin panel",
    `<div class="pav"><div class="big" id="avBig">${avatarHTML(p)}</div><div><b>Profile photo</b><small>PNG, JPG or WebP. Shown in the top bar.</small>
<div class="row-btns" style="margin-top:10px"><button type="button" class="b3" data-act="pick-img">${ic("upload")}Upload</button><button type="button" class="b3" data-act="clear-img">${ic("trash")}Remove</button><input type="file" accept="image/png,image/jpeg,image/webp" hidden data-change="img"></div></div></div>
<div class="fg2">
<div><label for="pn">Full name <span class="rq">*</span></label><input class="in" id="pn" value="${esc(p.name)}" maxlength="60" autocomplete="name"></div>
<div><label for="pe">Email <span class="rq">*</span></label><input class="in" id="pe" type="email" value="${esc(p.email)}" autocomplete="email"></div>
<div><label for="pph">Phone</label><input class="in" id="pph" type="tel" value="${esc(p.phone)}" placeholder="+91 98765 43210" autocomplete="tel"></div>
<div><label for="pr">Role</label><input class="in" id="pr" value="${esc(a ? a.role : "Admin")}" disabled><div class="hint">Only a Super Admin can change roles, from the Administrator page.</div></div></div>`,
  )}
${sec(
  "globe",
  "Preferences",
  "How the panel looks and reads for you",
  `<div class="fg2"><div><label for="pl">Language</label><select class="in" id="pl"><option value="en"${lang === "en" ? " selected" : ""}>English</option><option value="ar"${lang === "ar" ? " selected" : ""}>العربية</option></select></div></div>`,
)}
<div class="card glass s12 savebar"><button type="button" class="b3" data-act="discard">${esc(tr("Discard"))}</button><button type="button" class="btn" data-act="save-settings">${esc(tr("Save changes"))}</button></div>`;
}
function saveProfile() {
  const v = (id) => $("#" + id).value.trim();
  $$(".in").forEach((i) => i.removeAttribute("aria-invalid"));
  let bad = null;
  const fail = (id, msg) => {
    if (!bad) bad = { id, msg };
  };
  const em = v("pe").toLowerCase(),
    old = (S.get("e") || "").toLowerCase();
  if (!v("pn")) fail("pn", "Name is required.");
  else if (!/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(em))
    fail("pe", "Enter a valid email address.");
  else if (v("pph") && !/^\+?[\d\s\-()]{6,20}$/.test(v("pph")))
    fail("pph", "Enter a valid phone number.");
  else if (em !== old && adminOf(em))
    fail("pe", "Another admin already uses this email.");
  if (bad) {
    const el = $("#" + bad.id);
    el.setAttribute("aria-invalid", "true");
    el.focus();
    return toast(bad.msg, 1);
  }
  const all = LS.get("profiles", {});
  delete all[pkey()];
  all[em] = { name: v("pn"), email: em, phone: v("pph"), avatar: draft.avatar };
  commit("profiles", all);
  const admins = list("admins"),
    i = admins.findIndex((a) => a.email.toLowerCase() === old);
  if (i >= 0) {
    admins[i] = { ...admins[i], name: v("pn"), email: em };
    commit("admins", admins);
  }
  S.set("e", em);
  const nl = $("#pl").value === "ar" ? "ar" : "en";
  if (nl !== lang) {
    lang = nl;
    LS.set("lang", lang);
    applyLang();
    nav();
    $("#pt").textContent = tr(cur);
  }
  applyUser();
  toast("Profile saved.");
  render();
}

function applyBrand() {
  const st = getST();
  $("#brandName").textContent = st.company;
  $("#brandImg").src = st.logo || "assets/img/logo.png";
}

/* ---------- backup ---------- */
const BK = [
  "admins",
  "dua",
  "dhikr",
  "audio",
  "walls",
  "prayer",
  "settings",
  "log",
];
function exportBackup() {
  const data = {};
  BK.forEach(
    (k) => (data[k] = LS.get(k, k === "prayer" || k === "settings" ? {} : [])),
  );
  download(
    `nazar-e-aalam-backup-${new Date().toISOString().slice(0, 10)}.json`,
    JSON.stringify({ app: "nazar-e-aalam-admin", v: 1, data }, null, 2),
    "application/json",
  );
  toast("Backup downloaded.");
}
function importBackup(text) {
  let o;
  try {
    o = JSON.parse(text);
  } catch (e) {
    return toast("That file is not valid JSON.", 1);
  }
  const d = o && o.app === "nazar-e-aalam-admin" && o.data;
  if (!d) return toast("That is not a Nazar-e-Aalam backup file.", 1);
  const arrs = ["admins", "dua", "dhikr", "audio", "walls", "log"];
  if (
    arrs.some((k) => k in d && !Array.isArray(d[k])) ||
    ["prayer", "settings"].some(
      (k) =>
        k in d && (typeof d[k] !== "object" || Array.isArray(d[k]) || !d[k]),
    )
  )
    return toast("Backup file is damaged.", 1);
  confirmBox({
    title: "Restore backup?",
    msg: "This replaces the data currently saved in this browser.",
    ok: "Restore",
    onOk: () => {
      BK.forEach((k) => {
        if (k in d) LS.set(k, d[k]);
      });
      LS.set("seeded", 1);
      applyBrand();
      toast("Backup restored.");
      render();
    },
  });
}
const adminOf = (email) =>
  list("admins").find(
    (a) => a.email.toLowerCase() === String(email).toLowerCase(),
  );
const pkey = () => (S.get("e") || S.get("u") || "admin").toLowerCase();
const avatarHTML = (p) =>
  p.avatar ? `<img src="${esc(p.avatar)}" alt="">` : esc(initials(p.name));
const initials = (n) =>
  (
    String(n)
      .trim()
      .split(/\s+/)
      .map((w) => w[0])
      .slice(0, 2)
      .join("") || "A"
  ).toUpperCase();

/* ---------- routing + shell ---------- */
const PAGES = {
  Administrator: () => listPage("admins"),
  "Audio Quran": () => listPage("audio"),
  Dua: () => listPage("dua"),
  Dhikr: () => listPage("dhikr"),
  Wallpaper: wallPage,
  "Prayer Times": prayerPage,
  Settings: settingsPage,
};
function nav() {
  $("#nav").innerHTML = items
    .map(
      ([n, i], k) =>
        `<a href="#${encodeURIComponent(n)}" style="--i:${k}" class="${n === cur ? "act" : ""}"${n === cur ? ' aria-current="page"' : ""} data-act="go" data-p="${esc(n)}">${ic(i)}${esc(tr(n))}</a>`,
    )
    .join("");
}
function render() {
  const p = $("#page");
  kk = 0;
  clearInterval(tick);
  stopAudio();
  const nm0 = S.get("u") || "admin",
    first = nm0.split(/[._\-+]/)[0] || nm0,
    nm = cap(first);
  p.innerHTML =
    cur === "Dashboard" ? dashboard(nm) : (PAGES[cur] || (() => ""))();
  [...p.children].forEach((e, i) => e.style.setProperty("--i", i));
  animate();
}
function setMenu(on) {
  document.body.classList.toggle("open", on);
  const b = $('[data-act="menu"].chip');
  if (b) b.setAttribute("aria-expanded", String(on));
}
function go(n) {
  if (!items.some((x) => x[0] === n)) n = "Dashboard";
  cur = n;
  $("#pt").textContent = tr(n);
  document.title = `${tr(n)} · Nazar-e-Aalam Admin`;
  try {
    history.replaceState(null, "", "#" + encodeURIComponent(n));
  } catch (e) {}
  nav();
  if (matchMedia("(max-width: 900px)").matches) setMenu(false);
  render();
  const pg = $("#page");
  pg.scrollTop = 0;
  pg.focus({ preventScroll: true });
}
function applyLang() {
  document.documentElement.lang = lang;
  document.documentElement.dir = lang === "ar" ? "rtl" : "ltr";
  $("#lg").textContent = lang === "ar" ? "English" : "العربية";
}
function logout() {
  ["u", "e", "gk", "ak", "li"].forEach(S.del);
  clearInterval(tick);
  stopAudio();
  location.href = LOGIN;
}

/* command palette (Ctrl/Cmd + K) */
let palFocus = null;
function pal(o = true) {
  const p = $("#pal");
  p.classList.toggle("on", !!o);
  if (o) {
    palFocus = document.activeElement;
    const i = $("input", p);
    i.value = "";
    pf("");
    i.focus();
  } else if (palFocus && palFocus.focus) palFocus.focus();
}
function pf(q) {
  q = q.toLowerCase().trim();
  const res = items.filter(([n]) => `${n} ${tr(n)}`.toLowerCase().includes(q));
  $("#pal .pl").innerHTML =
    res
      .map(
        ([n, i], k) =>
          `<a href="#${encodeURIComponent(n)}" class="${k ? "" : "f"}" data-act="go" data-p="${esc(n)}" data-close="pal">${ic(i)}${esc(tr(n))}</a>`,
      )
      .join("") || '<p class="sub">No sections match.</p>';
}

/* ---------- events (delegated) ---------- */
const ACT = {
  menu: () => setMenu(!document.body.classList.contains("open")),
  lang: () => {
    lang = lang === "en" ? "ar" : "en";
    LS.set("lang", lang);
    applyLang();
    $("#pt").textContent = tr(cur);
    nav();
    render();
  },
  logout,
  close: closeModal,
  confirm: () => {
    const f = modalCtx && modalCtx.onOk;
    closeModal();
    if (f) f();
  },
  go: (el) => {
    if (el.dataset.close) pal(false);
    go(el.dataset.p);
    if (el.dataset.then === "add" && KEY[el.dataset.p])
      openForm(KEY[el.dataset.p]);
  },
  add: (el) => openForm(el.dataset.c),
  edit: (el) => openForm(el.dataset.c, el.dataset.id),
  del: (el) => askDelete(el.dataset.c, el.dataset.id),
  play: playAudio,
  padd: () => prayerForm(),
  pedit: (el) => prayerForm(el.dataset.d),
  pdel: (el) => {
    const iso = el.dataset.d,
      [y, m, d] = iso.split("-").map(Number);
    confirmBox({
      title: "Reset this day?",
      msg: `${pad(d)}.${pad(m)}.${y} will go back to the default demo times.`,
      ok: "Reset",
      onOk: () => {
        const all = LS.get("prayer", {});
        delete all[`${pcity}|${iso}`];
        commit("prayer", all);
        logAct("clock", `Reset prayer times for ${pad(d)}.${pad(m)}.${y}`);
        toast("Day reset.");
        render();
      },
    });
  },
  pmonth: (el) => {
    pm = +el.dataset.i;
    render();
  },
  pimport: () => $('[data-change="pimp"]').click(),
  pexport: exportPrayer,
  "pick-img": (el) =>
    $(`[data-change="img"][data-k="${el.dataset.k}"]`).click(),
  "clear-img": (el) => {
    draft[el.dataset.k] = "";
    $("#th_" + el.dataset.k).innerHTML = thumb("");
  },
  preset: (el) => {
    const n = el.dataset.n;
    draft.preset = n;
    draft.colors = PRESETS[n].slice(1);
    draft.mode = PRESETS[n][0];
    refreshAppearance();
  },
  discard: () => {
    toast("Changes discarded.");
    render();
  },
  menu: () => {
    const mobile = matchMedia("(max-width: 900px)").matches;
    const cur = mobile
      ? document.body.classList.contains("open")
      : document.body.classList.contains("rail");
    setMenu(!cur);
  },
  "bk-export": exportBackup,
  "bk-import": () => $('[data-change="bkimp"]').click(),
  "reset-all": () =>
    confirmBox({
      title: "Reset all data?",
      msg: "This deletes everything saved in this browser and restores the starter data.",
      ok: "Reset",
      onOk: () => {
        LS.clear();
        LS.set("lang", lang);
        seedIfNeeded();
        applyBrand();
        toast("All data reset.");
        render();
      },
    }),
};
document.addEventListener("click", (e) => {
  if (e.target.id === "modal") return closeModal();
  if (e.target.id === "pal") return pal(false);
  const el = e.target.closest("[data-act]");
  if (!el || el.disabled || !ACT[el.dataset.act]) return;
  if (el.tagName === "A") e.preventDefault();
  ACT[el.dataset.act](el, e);
});
document.addEventListener("input", (e) => {
  const x = e.target;
  if (x.matches("[data-filter]")) filt(x);
  else if (x.matches("[data-sync]")) {
    const i = x.dataset.i;
    if (x.type === "color") $("#h" + i).value = x.value.toUpperCase();
    else if (/^#[0-9a-f]{6}$/i.test(x.value))
      $("#c" + i).value = x.value.toLowerCase();
  } else if (x.closest("#pal")) pf(x.value);
});
document.addEventListener("change", async (e) => {
  const x = e.target,
    k = x.dataset.change;
  if (!k) return;
  if (k === "pcity") {
    pcity = x.value;
    render();
  } else if (k === "pyear") {
    py = +x.value;
    render();
  } else if (k === "pimp" || k === "bkimp") {
    const f = x.files[0];
    x.value = "";
    if (!f) return;
    if (f.size > 5e6) return toast("That file is too large.", 1);
    const text = await f.text();
    k === "pimp" ? importPrayer(text) : importBackup(text);
  } else if (k === "img") {
    const f = x.files[0],
      key = x.dataset.k;
    x.value = "";
    if (!f) return;
    try {
      draft[key] = await fileToDataURL(
        f,
        key === "banner" ? 1200 : key === "icon" ? 192 : 512,
        true,
      );
      $("#th_" + key).innerHTML = thumb(draft[key]);
      toast("Image ready. Press Save changes to keep it.");
    } catch (err) {
      toast(err.message, 1);
    }
  }
});
document.addEventListener("keydown", (e) => {
  if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === "k") {
    e.preventDefault();
    pal();
    return;
  }
  if (e.key === "Escape") {
    if (modalOpen()) closeModal();
    else if ($("#pal").classList.contains("on")) pal(false);
    else if (document.body.classList.contains("open")) setMenu(false);
    return;
  }
  if (modalOpen() && e.key === "Tab") {
    const f = $$(
      "#modal button:not([disabled]),#modal input:not([hidden]):not([disabled]),#modal select,#modal textarea",
    );
    if (!f.length) return;
    const a = f[0],
      z = f[f.length - 1];
    if (e.shiftKey && document.activeElement === a) {
      e.preventDefault();
      z.focus();
    } else if (!e.shiftKey && document.activeElement === z) {
      e.preventDefault();
      a.focus();
    }
    return;
  }
  if ($("#pal").classList.contains("on")) {
    const links = $$("#pal .pl a");
    const i = links.findIndex((a) => a.classList.contains("f"));
    if (e.key === "ArrowDown" || e.key === "ArrowUp") {
      e.preventDefault();
      if (!links.length) return;
      const n =
        (i + (e.key === "ArrowDown" ? 1 : -1) + links.length) % links.length;
      links.forEach((a, k) => a.classList.toggle("f", k === n));
      links[n].scrollIntoView({ block: "nearest" });
    } else if (e.key === "Enter" && links[Math.max(i, 0)]) {
      e.preventDefault();
      links[Math.max(i, 0)].click();
    }
  }
});
let glowQ = false;
document.addEventListener("mousemove", (e) => {
  if (glowQ) return;
  glowQ = true;
  requestAnimationFrame(() => {
    glowQ = false;
    const cd = e.target.closest && e.target.closest(".card");
    if (!cd) return;
    const r = cd.getBoundingClientRect();
    cd.style.setProperty("--mx", e.clientX - r.left + "px");
    cd.style.setProperty("--my", e.clientY - r.top + "px");
  });
});
window.addEventListener("storage", (e) => {
  if (e.key && e.key.startsWith(NS) && !modalOpen() && cur !== "Settings") {
    applyBrand();
    render();
  }
});
window.addEventListener("hashchange", () => {
  const h = decodeURIComponent(location.hash.slice(1));
  if (h !== cur && items.some((x) => x[0] === h)) go(h);
});
window.addEventListener("resize", () => {
  if (matchMedia("(max-width: 900px)").matches) {
    document.body.classList.remove("rail");
  } else {
    document.body.classList.remove("open");
    if (LS.get("rail", 0)) document.body.classList.add("rail");
  }
});

/* ---------- start ---------- */
function init() {
  seedIfNeeded();
  $("header .sp").insertAdjacentHTML(
    "afterend",
    `<button type="button" class="chip glass srch" data-act="pal" aria-label="Search or jump to a section">${ic("search")}<span>Search or jump to…</span><kbd>Ctrl K</kbd></button>`,
  );
  ACT.pal = () => pal();
  $("aside").insertAdjacentHTML(
    "beforeend",
    `<div class="sys"><span class="pulse" style="${lsOk ? "" : "background:#f59e0b"}"></span><div><b>${lsOk ? "Saving to this browser" : "Storage unavailable"}</b><small>${lsOk ? "Demo mode · no server yet" : "Changes last until you close the tab"}</small></div></div>`,
  );
  document.body.insertAdjacentHTML(
    "beforeend",
    `<div id="pal"><div class="pb glass" role="dialog" aria-modal="true" aria-label="Jump to a section"><input class="in" placeholder="Jump to a section…" aria-label="Jump to a section" autocomplete="off"><div class="pl"></div></div></div>`,
  );
  const u = S.get("u") || "admin";
  $("#ini").textContent = u[0].toUpperCase();
  $("#un").textContent = u;
  applyLang();
  applyBrand();
  if (!S.get("li")) {
    S.set("li", "1");
    logAct("check", `${u} signed in`);
  }
  const h = decodeURIComponent(location.hash.slice(1));
  if (LS.get("rail", 0) && !matchMedia("(max-width: 900px)").matches) {
    document.body.classList.add("rail");
    const b = $('[data-act="menu"].chip');
    if (b) b.setAttribute("aria-expanded", "true");
  }
  go(items.some((x) => x[0] === h) ? h : "Dashboard");
}
if (AUTH) init();

function setMenu(on) {
  const mobile = matchMedia("(max-width: 900px)").matches;
  if (mobile) {
    document.body.classList.toggle("open", on);
  } else {
    document.body.classList.toggle("rail", on);
    LS.set("rail", on ? 1 : 0);
  }
  const b = $('[data-act="menu"].chip');
  if (b) b.setAttribute("aria-expanded", String(on));
}
