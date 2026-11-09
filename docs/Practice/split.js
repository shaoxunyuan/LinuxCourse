(function () {
  const KEY = "linuxcourse-sidebar-width";
  const MIN = 200;
  const MAX = 560;
  const DEFAULT = 300;

  function clamp(n) {
    return Math.max(MIN, Math.min(MAX, n));
  }

  function applyWidth(shell, width) {
    shell.style.setProperty("--sidebar-width", clamp(width) + "px");
  }

  function initShell(shell) {
    const sidebar = shell.querySelector(".book-sidebar");
    const main = shell.querySelector(".book-main");
    if (!sidebar || !main) return;

    let resizer = shell.querySelector(".book-resizer");
    if (!resizer) {
      resizer = document.createElement("div");
      resizer.className = "book-resizer";
      resizer.setAttribute("role", "separator");
      resizer.setAttribute("aria-orientation", "vertical");
      resizer.setAttribute("aria-label", "拖动调整目录宽度");
      resizer.tabIndex = 0;
      sidebar.after(resizer);
    }

    const saved = parseInt(localStorage.getItem(KEY) || "", 10);
    applyWidth(shell, Number.isFinite(saved) ? saved : DEFAULT);

    let dragging = false;

    const onMove = (clientX) => {
      if (!dragging) return;
      const rect = shell.getBoundingClientRect();
      const width = clamp(clientX - rect.left);
      applyWidth(shell, width);
      localStorage.setItem(KEY, String(width));
    };

    resizer.addEventListener("pointerdown", (e) => {
      if (window.matchMedia("(max-width: 1280px)").matches) return;
      dragging = true;
      shell.classList.add("is-resizing");
      resizer.classList.add("is-dragging");
      resizer.setPointerCapture(e.pointerId);
      e.preventDefault();
    });

    resizer.addEventListener("pointermove", (e) => onMove(e.clientX));

    const stop = (e) => {
      if (!dragging) return;
      dragging = false;
      shell.classList.remove("is-resizing");
      resizer.classList.remove("is-dragging");
      try {
        resizer.releasePointerCapture(e.pointerId);
      } catch (_) {}
    };

    resizer.addEventListener("pointerup", stop);
    resizer.addEventListener("pointercancel", stop);

    resizer.addEventListener("keydown", (e) => {
      const current = parseInt(getComputedStyle(shell).getPropertyValue("--sidebar-width"), 10) || DEFAULT;
      if (e.key === "ArrowLeft") {
        applyWidth(shell, current - 16);
        localStorage.setItem(KEY, String(clamp(current - 16)));
        e.preventDefault();
      } else if (e.key === "ArrowRight") {
        applyWidth(shell, current + 16);
        localStorage.setItem(KEY, String(clamp(current + 16)));
        e.preventDefault();
      }
    });
  }

  document.querySelectorAll(".book-shell").forEach(initShell);
})();
