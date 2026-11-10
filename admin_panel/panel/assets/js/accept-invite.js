/* Nazar-e-Aalam — accept invitation. */
"use strict";
const $ = (s) => document.querySelector(s);

const params = new URLSearchParams(location.search);
const token = params.get("token") || "";

$("#eye").onclick = () => {
  const p = $("#pw");
  p.type = p.type === "password" ? "text" : "password";
};

let inviteEmail = "";

(async () => {
  if (!token) {
    showError("This link is missing its invitation token.");
    return;
  }
  try {
    const r = await api.get(`/auth/accept-invite/${encodeURIComponent(token)}`);
    inviteEmail = r.email;
    $("#af-title").textContent = r.inviter_name
      ? `${r.inviter_name} invited you`
      : "You've been invited";
    $("#af-sub").textContent =
      `Joining as ${r.role_name || "Administrator"} · ${r.email}`;
    $("#af-loading").hidden = true;
    $("#af-fields").hidden = false;
    $("#af").hidden = false;
    setTimeout(() => $("#fn").focus(), 30);
  } catch (err) {
    showError(err.message || "This invitation link is invalid or has expired.");
  }
})();

function showError(msg) {
  $("#af").hidden = false;
  $("#af-loading").hidden = true;
  $("#af-fields").hidden = true;
  const box = $("#af-error");
  box.hidden = false;
  box.textContent = msg;
  const btn = document.createElement("a");
  btn.href = "login.html";
  btn.className = "b3";
  btn.style.marginTop = "16px";
  btn.style.display = "inline-block";
  btn.textContent = "Back to sign in";
  box.appendChild(document.createElement("br"));
  box.appendChild(btn);
}

$("#af").onsubmit = async (e) => {
  e.preventDefault();
  const pw = $("#pw").value;
  const pw2 = $("#pw2").value;
  const errEl = $("#err");
  errEl.textContent = "";

  if (pw.length < 6) {
    errEl.textContent = "Password must be at least 6 characters.";
    $("#pw").focus();
    return;
  }
  if (pw !== pw2) {
    errEl.textContent = "Passwords don't match.";
    $("#pw2").focus();
    return;
  }

  const btn = $("#af .btn");
  btn.classList.add("load");
  btn.disabled = true;

  try {
    await api.post("/auth/accept-invite", {
      token,
      password: pw,
      first_name: $("#fn").value.trim() || null,
      last_name: $("#ln").value.trim() || null,
    });

    // The server returned a token pair + user — stash them so the
    // next page load lands signed-in. But we still send them to login
    // so they go through OTP (Part B). For Part A, straight to panel.
    api.toast("Account activated — welcome aboard!");
    setTimeout(() => {
      location.replace("../index.html");
    }, 600);
  } catch (err) {
    errEl.textContent = err.message || "Activation failed";
    btn.classList.remove("load");
    btn.disabled = false;
  }
};

$("#pw").addEventListener("input", () => { $("#err").textContent = ""; });
$("#pw2").addEventListener("input", () => { $("#err").textContent = ""; });