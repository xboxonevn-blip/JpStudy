window.addEventListener("flutter-first-frame", function () {
  if (typeof window.setAccessibleViewport === "function") {
    window.setAccessibleViewport();
  }
  const shell = document.getElementById("jpstudy-shell");
  if (shell) {
    shell.classList.add("is-hidden");
    window.setTimeout(() => shell.remove(), 320);
  }
});
