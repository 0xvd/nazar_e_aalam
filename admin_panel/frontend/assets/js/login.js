/* ---------- login / session (demo: any email + password of 6+ chars) ---------- */
const $ = (s) => document.querySelector(s);
const S = {
  get: (k) => { try { return sessionStorage.getItem(k); } catch (e) { return null; } },
  set: (k, v) => { try { sessionStorage.setItem(k, v); } catch (e) {} },
};

// Already signed in? Go straight to the panel.
if (S.get("u")) window.location.replace("../index.html");

$("#lf").onsubmit = (e) => {
  e.preventDefault();
  const email = $("#em").value.trim();
  if (!email) { $("#err").textContent = "Enter your email address."; return; }
  if ($("#pw").value.length < 6) {
    $("#err").textContent = "Password must be at least 6 characters.";
    return;
  }
  $("#err").textContent = "";
  $("#lf .btn").classList.add("load");

  // TODO (backend): replace with a real API call and store the token it returns.
  S.set("u", email.split("@")[0] || "admin");
  S.set("e", email);
  setTimeout(() => (window.location.href = "../index.html"), 700);
};

$("#eye").onclick = () => {
  const p = $("#pw");
  p.type = p.type === "password" ? "text" : "password";
};