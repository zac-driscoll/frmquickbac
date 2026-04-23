$(document).on("click", "#open_loc_map", function () {
  // find the *closest* namespace carrier in the same card/page
  const nsHolder = this.closest("div")?.querySelector("[id$='loc_map_ns']")
    || document.querySelector("[id$='loc_map_ns']");
  const ns = nsHolder ? nsHolder.getAttribute("data-ns") : "";
  Shiny.setInputValue(ns + "open_loc_map", Date.now(), { priority: "event" });
});

$(document).on("keydown", "#open_loc_map", function (e) {
  if (e.key === "Enter" || e.key === " ") {
    const nsHolder = this.closest("div")?.querySelector("[id$='loc_map_ns']")
      || document.querySelector("[id$='loc_map_ns']");
    const ns = nsHolder ? nsHolder.getAttribute("data-ns") : "";
    Shiny.setInputValue(ns + "open_loc_map", Date.now(), { priority: "event" });
    e.preventDefault();
  }
});