// Language menu (Design document 2.2). The menu is a <details> element and
// opens without JavaScript; this adds Escape, click outside and arrow keys.

const menu = document.querySelector(".lang-switch");
const summary = menu.querySelector("summary");
const items = [...menu.querySelectorAll(".lang-switch-menu a")];

function close() {
  menu.open = false;
}

document.addEventListener("click", (event) => {
  if (!menu.contains(event.target)) close();
});

menu.addEventListener("keydown", (event) => {
  if (event.key === "Escape" && menu.open) {
    close();
    summary.focus();
    return;
  }
  if (event.key !== "ArrowDown" && event.key !== "ArrowUp") return;

  event.preventDefault();
  if (!menu.open) menu.open = true;
  const step = event.key === "ArrowDown" ? 1 : -1;
  const index = items.indexOf(document.activeElement);
  const next = index === -1 ? 0 : (index + step + items.length) % items.length;
  items[next].focus();
});
