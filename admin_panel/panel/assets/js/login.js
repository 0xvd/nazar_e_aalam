/* Nazar-e-Aalam — real login. */
"use strict";
const $ = (s) => document.querySelector(s);

// If already signed in, jump to the panel (or `next=` if provided)
if (api.isAuthenticated()) {
  const p = new URLSearchParams(location.search);
  location.replace(p.get("next") || "../index.html");
}

$("#eye").onclick = () => {
  const p = $("#pw");
  p.type = p.type === "password" ? "text" : "password";
};

$("#lf").onsubmit = async (e) => {
  e.preventDefault();
  const email = $("#em").value.trim();
  const password = $("#pw").value;
  const errEl = $("#err");

  errEl.textContent = "";

  // ---- Validation (inline + toast) ----
  if (!email) {
    errEl.textContent = "Enter your email address.";
    api.toast("Enter your email address", true);
    $("#em").focus();
    return;
  }
  if (password.length < 6) {
    errEl.textContent = "Password must be at least 6 characters.";
    api.toast("Password too short (min 6 chars)", true);
    $("#pw").focus();
    return;
  }

  const btn = $("#lf .btn");
  btn.classList.add("load");
  btn.disabled = true;

  try {
    const user = await api.login(email, password);

    const greeting = user && user.first_name
      ? `Welcome back, ${user.first_name}`
      : "Welcome back";
    api.toast(greeting);

    const p = new URLSearchParams(location.search);
    const next = p.get("next") || "../index.html";

    // Small delay so the toast is visible before the redirect
    setTimeout(() => location.replace(next), 350);
  } catch (err) {
    const msg = err.message || "Login failed";
    errEl.textContent = msg;
    api.toast(msg, true);
    btn.classList.remove("load");
    btn.disabled = false;
    $("#pw").focus();
    $("#pw").select();
  }
};

// Clear inline error as soon as the user starts fixing the form
$("#em").addEventListener("input", () => { $("#err").textContent = ""; });
$("#pw").addEventListener("input", () => { $("#err").textContent = ""; });