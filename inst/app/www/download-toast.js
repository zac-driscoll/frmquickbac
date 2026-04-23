console.log("✅ download-toast.js loaded");

$(document).on("click", "a[id$='downloadData']", function () {
  // Find the *nearest* namespace carrier in the same card, fall back to any on page
  const card = this.closest(".card") || this.closest(".box") || document;
  const holder = card.querySelector("[id$='download_ns']") || document.querySelector("[id$='download_ns']");
  const ns = holder ? holder.getAttribute("data-ns") : "";

  console.log("✅ download clicked. id=", this.id, "ns=", ns);

  if (window.Shiny) {
    Shiny.setInputValue(ns + "download_clicked", Date.now(), { priority: "event" });
  } else {
    console.log("❌ window.Shiny not found");
  }
});
