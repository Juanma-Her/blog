// Copy buttons on code figures (JSON contracts 6.3). The buttons are hidden
// in the HTML and shown here, so readers without JavaScript never see a
// button that does nothing.

for (const button of document.querySelectorAll("[data-copy]")) {
  const figure = button.closest("figure");
  const label = button.querySelector("[data-copy-label]");
  const status = figure.querySelector("[data-copy-status]");
  const copyText = label.textContent;
  let timer;

  button.addEventListener("click", async () => {
    // The rendered code ends with the newline before </code>; the source does not.
    const code = figure.querySelector("code").textContent.replace(/\n$/, "");
    try {
      await navigator.clipboard.writeText(code);
    } catch {
      return; // Clipboard blocked: leave the label as it is.
    }
    label.textContent = status.textContent = button.dataset.copied;
    clearTimeout(timer);
    timer = setTimeout(() => {
      label.textContent = copyText;
      status.textContent = "";
    }, 2000);
  });

  button.hidden = false;
}
