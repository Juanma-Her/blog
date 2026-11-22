// Comments with giscus (Design document 11, JSON contracts 6.4).
// giscus loads only when the comment section is within 600px of the viewport,
// so readers who never scroll there make no request to giscus.app.

const section = document.querySelector("[data-giscus]");

// The theme on screen: the reader's choice, else the system's (as in theme.js).
function giscusTheme() {
  const dark =
    (document.documentElement.dataset.theme ??
      (matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light")) === "dark";
  return dark ? section.dataset.themeDark : section.dataset.themeLight;
}

function load() {
  const script = document.createElement("script");
  script.src = "https://giscus.app/client.js";
  const { repo, repoId, category, categoryId, mapping, term, lang } = section.dataset;
  Object.assign(script.dataset, {
    repo, repoId, category, categoryId, mapping, term, lang,
    strict: "1", // match the term exactly, never a similar discussion title
    reactionsEnabled: "0", // no post-level reactions; comments keep theirs
    emitMetadata: "0",
    inputPosition: "bottom",
    loading: "lazy",
    theme: giscusTheme(),
  });
  script.crossOrigin = "anonymous";
  script.async = true;
  section.append(script);
}

if (section) {
  const observer = new IntersectionObserver(
    (entries) => {
      if (!entries.some((entry) => entry.isIntersecting)) return;
      observer.disconnect();
      load();
    },
    { rootMargin: "600px" },
  );
  observer.observe(section);

  document.addEventListener("themechange", () => {
    const frame = section.querySelector("iframe.giscus-frame");
    frame?.contentWindow.postMessage({ giscus: { setConfig: { theme: giscusTheme() } } }, "https://giscus.app");
  });
}
