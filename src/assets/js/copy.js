// Copy buttons (JSON contracts 6.3): on code figures they copy the code; with
// data-copy-target they copy that element's value (the feed address). The
// buttons are hidden in the HTML and shown here, so readers without
// JavaScript never see a button that does nothing.

for (const button of document.querySelectorAll("[data-copy]")) {
  const target = button.dataset.copyTarget
    ? document.getElementById(button.dataset.copyTarget)
    : button.closest("figure").querySelector("code");
  const label = button.querySelector("[data-copy-label]");
  const status = button.parentElement.querySelector("[data-copy-status]");
  const copyText = label.textContent;
  let timer;

  button.addEventListener("click", async () => {
    // Rendered code ends with the newline before </code>; the source does not.
    const text = target.value ?? target.textContent.replace(/\n$/, "");
    try {
      await navigator.clipboard.writeText(text);
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
