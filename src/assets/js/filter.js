// Chips and search for the lists on home, archive and projects (JSON contracts 6.2).
// Every item is already in the HTML; this script only hides the ones that do
// not match, and keeps the filter in the URL (?topic= or ?type=, and ?q=).

// Same rule as the filter_text Liquid filter: lower case, no accents,
// punctuation turned into spaces.
const normalize = (text) =>
  text
    .normalize("NFD")
    .replace(/\p{Mn}/gu, "")
    .toLowerCase()
    .replace(/[^a-z0-9+#]+/g, " ")
    .trim();

for (const root of document.querySelectorAll("[data-filter-root]")) {
  const param = root.dataset.filterParam;
  const chips = [...root.querySelectorAll("[data-filter-value]")];
  const items = [...root.querySelectorAll("[data-filter-item]")];
  const groups = [...root.querySelectorAll("[data-filter-group]")];
  const search = root.querySelector("[data-filter-search]");
  const empty = root.querySelector("[data-filter-empty]");
  const status = root.querySelector("[data-filter-status]");
  const params = new URLSearchParams(location.search);

  let selected = params.get(param) ?? "";
  if (!chips.some((chip) => chip.dataset.filterValue === selected)) selected = "";
  if (search) search.value = params.get("q") ?? "";

  function apply({ announce }) {
    const words = search ? normalize(search.value).split(" ").filter(Boolean) : [];
    let shown = 0;

    for (const item of items) {
      const keys = item.dataset.filterKey.split(" ");
      const text = item.dataset.filterText ?? "";
      const match = (!selected || keys.includes(selected)) && words.every((word) => text.includes(word));
      item.hidden = !match;
      if (match) shown++;
    }

    for (const group of groups) {
      group.hidden = !group.querySelector("[data-filter-item]:not([hidden])");
    }
    for (const chip of chips) {
      chip.setAttribute("aria-pressed", chip.dataset.filterValue === selected);
    }
    if (empty) empty.hidden = shown > 0;
    if (announce && status) {
      const template = shown === 1 ? root.dataset.filterResultsOne : root.dataset.filterResults;
      status.textContent = template.replace("{n}", shown);
    }
    updateUrl();
  }

  function updateUrl() {
    const url = new URL(location.href);
    const query = search?.value.trim();
    if (selected) url.searchParams.set(param, selected);
    else url.searchParams.delete(param);
    if (query) url.searchParams.set("q", query);
    else url.searchParams.delete("q");
    history.replaceState(null, "", url);
  }

  for (const chip of chips) {
    chip.addEventListener("click", () => {
      selected = chip.dataset.filterValue;
      apply({ announce: true });
    });
  }

  search?.addEventListener("input", () => apply({ announce: true }));

  root.querySelector("[data-filter-clear]")?.addEventListener("click", () => {
    selected = "";
    if (search) {
      search.value = "";
      search.focus();
    }
    apply({ announce: true });
  });

  // "/" jumps to the search box, unless the reader is already typing somewhere.
  if (search) {
    document.addEventListener("keydown", (event) => {
      const typing = event.target.closest("input, textarea, select, [contenteditable]");
      if (event.key !== "/" || typing || event.ctrlKey || event.metaKey || event.altKey) return;
      event.preventDefault();
      search.focus();
    });
  }

  apply({ announce: false });
}
