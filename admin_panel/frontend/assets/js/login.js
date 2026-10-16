/* ---------- login / session ---------- */
$("#lf").onsubmit = (e) => {
  e.preventDefault();
  if ($("#pw").value.length < 6) {
    $("#err").textContent = "Password must be at least 6 characters.";
    return;
  }
  $("#err").textContent = "";
  const b = $("#lf .btn");
  window.location.href = '../index.html'
  b.classList.add("load");
};