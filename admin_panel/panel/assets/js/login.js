/* Nazar-e-Aalam — real login with email OTP. */
"use strict";
const $ = (s) => document.querySelector(s);

// If already signed in, jump to the panel (or `next=` if provided)
if (api.isAuthenticated()) {
  const p = new URLSearchParams(location.search);
  location.replace(p.get("next") || "../index.html");
}

const nextUrl = (() => {
  const p = new URLSearchParams(location.search);
  return p.get("next") || "../index.html";
})();

let challenge = null;
let resendTimer = null;
let resendCooldown = 0;

// ── Password step ──────────────────────────────────────────────────────
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

  if (!email) {
    errEl.textContent = "Enter your email address.";
    $("#em").focus();
    return;
  }
  if (password.length < 6) {
    errEl.textContent = "Password must be at least 6 characters.";
    $("#pw").focus();
    return;
  }

  const btn = $("#lf .btn");
  btn.classList.add("load");
  btn.disabled = true;

  try {
    const res = await api.login(email, password);

    // 2FA challenge response — show the OTP screen
    if (res && res.challenge_token) {
      challenge = res;
      showOtpScreen();
      api.toast("Check your email for the code");
      return;
    }

    // 2FA off — straight in (dev only)
    const greeting =
      res && res.user && res.user.first_name
        ? `Welcome back, ${res.user.first_name}`
        : "Welcome back";
    api.toast(greeting);
    setTimeout(() => location.replace(nextUrl), 300);
  } catch (err) {
    const msg = err.message || "Login failed";
    errEl.textContent = msg;
    api.toast(msg, true);
    $("#pw").focus();
    $("#pw").select();
  } finally {
    btn.classList.remove("load");
    btn.disabled = false;
  }
};

// ── OTP step ───────────────────────────────────────────────────────────
function showOtpScreen() {
  $("#lf").hidden = true;
  $("#of").hidden = false;
  $("#otp-sub").textContent = challenge.email_hint
    ? `We sent a 6-digit code to ${challenge.email_hint}.`
    : "We sent a 6-digit code to your email.";

  const otpEl = $("#otp");
  otpEl.value = "";
  otpEl.focus();
  startResendCooldown();
}

function startResendCooldown() {
  resendCooldown = 30;
  updateResendUi();
  clearInterval(resendTimer);
  resendTimer = setInterval(() => {
    resendCooldown -= 1;
    if (resendCooldown <= 0) {
      clearInterval(resendTimer);
      resendTimer = null;
      resendCooldown = 0;
    }
    updateResendUi();
  }, 1000);
}

function updateResendUi() {
  const link = $("#resend");
  const cd = $("#resend-cd");
  const sec = $("#resend-sec");
  if (resendCooldown > 0) {
    link.style.pointerEvents = "none";
    link.style.opacity = "0.4";
    cd.style.display = "inline";
    sec.textContent = String(resendCooldown);
  } else {
    link.style.pointerEvents = "";
    link.style.opacity = "";
    cd.style.display = "none";
  }
}

$("#otp").addEventListener("input", (e) => {
  const v = e.target.value.replace(/\D/g, "").slice(0, 6);
  e.target.value = v;
  $("#oerr").textContent = "";
  if (v.length === 6) $("#of").requestSubmit();
});

$("#of").onsubmit = async (e) => {
  e.preventDefault();
  const otp = $("#otp").value.trim();
  const errEl = $("#oerr");
  errEl.textContent = "";

  if (otp.length !== 6) {
    errEl.textContent = "Enter the 6-digit code from your email.";
    $("#otp").focus();
    return;
  }

  const btn = $("#of .btn");
  btn.classList.add("load");
  btn.disabled = true;

  try {
    const res = await api.verifyOtp(challenge.challenge_token, otp);

    const greeting =
      res && res.user && res.user.first_name
        ? `Welcome, ${res.user.first_name}`
        : "Welcome";
    api.toast(greeting);
    setTimeout(() => location.replace(nextUrl), 300);
  } catch (err) {
    errEl.textContent = err.message || "Verification failed";
    $("#otp").focus();
    $("#otp").select();
  } finally {
    btn.classList.remove("load");
    btn.disabled = false;
  }
};

// ── Resend ─────────────────────────────────────────────────────────────
$("#resend").addEventListener("click", async (e) => {
  e.preventDefault();
  if (!challenge || resendCooldown > 0) return;

  try {
    const res = await api.resendOtp(challenge.challenge_token);
    challenge = res;
    api.toast("New code sent");
    startResendCooldown();
    $("#otp").focus();
  } catch (err) {
    api.toast(err.message || "Resend failed", true);
  }
});

// ── Back to login ──────────────────────────────────────────────────────
$("#back-to-login").addEventListener("click", (e) => {
  e.preventDefault();
  challenge = null;
  clearInterval(resendTimer);
  resendTimer = null;
  $("#of").hidden = true;
  $("#lf").hidden = false;
  $("#pw").value = "";
  $("#em").focus();
});

$("#em").addEventListener("input", () => { $("#err").textContent = ""; });
$("#pw").addEventListener("input", () => { $("#err").textContent = ""; });
$("#otp").addEventListener("input", () => { $("#oerr").textContent = ""; });