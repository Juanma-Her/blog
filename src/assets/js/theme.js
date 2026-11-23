// Theme toggle (Design document 5, JSON contracts 6.1).
//
// <html data-theme> holds the reader's choice. Without it, CSS follows the
// system theme, so this script only needs to know the system theme to label
// the button and to tell listeners (giscus) which theme is showing.

const root = document.documentElement;
const button = document.getElementById("theme-toggle");
const systemDark = matchMedia("(prefers-color-scheme: dark)");

function currentTheme() {
  return root.dataset.theme ?? (systemDark.matches ? "dark" : "light");
}

function updateButton() {
  const dark = currentTheme() === "dark";
  const label = dark ? button.dataset.labelToLight : button.dataset.labelToDark;
  button.setAttribute("aria-label", label);
  button.title = label;
}

function announce() {
  document.dispatchEvent(new CustomEvent("themechange", { detail: { theme: currentTheme() } }));
}

function choose(theme) {
  root.dataset.theme = theme;
  try {
    localStorage.setItem("theme", theme);
  } catch {
    // Storage blocked (private window): the choice lasts for this page only.
  }
  updateButton();
  announce();
}

// Drop a stored value that is neither "dark" nor "light".
try {
  if (!root.dataset.theme) localStorage.removeItem("theme");
} catch {}

button.addEventListener("click", () => choose(currentTheme() === "dark" ? "light" : "dark"));

systemDark.addEventListener("change", () => {
  if (root.dataset.theme) return; // the reader's choice wins over the system
  updateButton();
  announce();
});

updateButton();
