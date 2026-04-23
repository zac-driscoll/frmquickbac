// ============================================================================
// barplot.js
// Horizontal bar chart for r2d3 (D3 v5)
// Styled to match ggplot2 custom_theme()
// Includes: header band, gradient legend, gridlines, tooltips, enter animation,
//           and glow-on-hover
// ============================================================================

// ============================================================================
// SETUP & CLEANUP
// ============================================================================

svg.selectAll("*").remove();

if (options.no_records) {
  svg.append("rect")
    .attr("x", 0)
    .attr("y", 0)
    .attr("width", width)
    .attr("height", height)
    .attr("fill", "#F1F9FF");

  svg.append("text")
    .attr("x", width / 2)
    .attr("y", height / 2)
    .attr("text-anchor", "middle")
    .attr("dominant-baseline", "middle")
    .attr("font-family", "Segoe UI, sans-serif")
    .attr("font-size", "18px")
    .attr("fill", "#5A6E8C")
    .text("No data available for this selection");

  return; // ⛔ STOP EXECUTION HERE
}

const headerHeight = 10;
const margin = { top: 30, right: 25, bottom: 50, left: 75 };
const w = width - margin.left - margin.right;
const h = height - headerHeight - margin.top - margin.bottom;


// ============================================================================
// THEME COLORS (from ggplot custom_theme)
// ============================================================================
const colors = {
  plotBg: "#F1F9FF",
  panelBg: "#E6ECF4",
  border: "#A9CCE3",
  gridMajor: "#C0C7CD",
  gridMinor: "#E5E9ED",
  axisText: "#064789",
  axisTitle: "#0A2B43",
  caption: "#345A88"
};


// ============================================================================
// OPTIONS (defensive)
// ============================================================================
const opts = options || {};
const sortDesc = !!opts.sort_desc;       // true => descending
const units = opts.units || "";
const title = opts.title || "";
const subtitle = opts.subtitle || "";
const precip_title = opts.precip_title || "";
const info_html = opts.info_html
const info_icon = opts.infoIcon
const wq_std = opts.wq_std
const base_size = opts.base_size

// ============================================================================
// SVG BACKGROUND (plot.background)
// ============================================================================

// ---- Background ----
svg
  .style("background", colors.plotBg)
  .style("border", `1px solid ${colors.border}`)
  .attr("viewBox", `0 0 ${width} ${height}`)
  .attr("preserveAspectRatio", "xMidYMid meet");

// ============================================================================
// DEFINITIONS (single <defs> for legend + glow)
// ============================================================================
const defs = svg.append("defs");


// ============================================================================
// ROOT GROUP (plotting area)
// ============================================================================
const g = svg.append("g")
  .attr("transform", `translate(${margin.left}, ${headerHeight + margin.top})`);


// -----------------------------------------------------------------------------
// SVG TOOLTIP (single instance) + drop shadow (define ONCE)
// Requires: defs already exists (const defs = svg.append("defs");)
// -----------------------------------------------------------------------------

// Drop shadow filter (define once)
defs.select("#tooltip-shadow").remove(); // safe if re-rendering
const shadow = defs.append("filter")
  .attr("id", "tooltip-shadow")
  .attr("x", "-50%")
  .attr("y", "-50%")
  .attr("width", "200%")
  .attr("height", "200%");

shadow.append("feGaussianBlur")
  .attr("in", "SourceAlpha")
  .attr("stdDeviation", 4)
  .attr("result", "blur");

shadow.append("feOffset")
  .attr("dx", 0)
  .attr("dy", 4)
  .attr("result", "offsetBlur");

const feMerge1 = shadow.append("feMerge");
feMerge1.append("feMergeNode").attr("in", "offsetBlur");
feMerge1.append("feMergeNode").attr("in", "SourceGraphic");

// Tooltip group
const tooltip1 = svg.append("g")
  .style("pointer-events", "none")
  .style("display", "none")
  .style("opacity", 0);

const tooltipBg = tooltip1.append("rect")
  .attr("rx", 10)
  .attr("ry", 10)
  .attr("fill", "rgba(20, 30, 45, 0.95)")
  .attr("stroke", "rgba(255,255,255,0.15)")
  .attr("stroke-width", 1)
  .attr("filter", "url(#tooltip-shadow)");

const tooltipText = tooltip1.append("text")
  .attr("font-family", "Segoe UI, sans-serif")
  .attr("fill", "#fff");

function setTooltipText(lines) {
  tooltipText.selectAll("tspan").remove();

  lines.forEach((line, i) => {
    tooltipText.append("tspan")
      .attr("x", 0)
      .attr("dy", i === 0 ? "1.4em" : "1.6em")   // more breathing room
      .attr("font-weight", i === 0 ? "700" : "400")
      .attr("font-size", i === 0 ? "16px" : "14px") // ⬅️ INCREASED
      .attr("fill", "#ffffff")
      .text(line);
  });
}


// ============================================================================
// TOOLTIP CONTAINER (Leaflet-style HTML)
// NOTE: each render adds a div; remove old ones first (nice in Shiny re-render)
// ============================================================================
d3.selectAll("div.r2d3-tooltip").remove();

const tooltip = d3.select("body")
  .append("div")
  .attr("class", "r2d3-tooltip")
  .style("position", "absolute")
  .style("pointer-events", "none")
  .style("opacity", 0)
  .style("z-index", 9999);


// ============================================================================
// DATA PREP
// ============================================================================
data.forEach(d => {
  d.Result_num = Number(String(d.Result).replace(/,/g, ""));
});

// sortDesc = true => descending (largest at top)
data.sort((a, b) =>
  sortDesc
    ? d3.ascending(a.Result_num, b.Result_num)
    : d3.descending(a.Result_num, b.Result_num)
);


// ============================================================================
// SCALES
// ============================================================================
const xMax = d3.max(data, d => d.Result_num) || 0;

const x = d3.scaleLinear()
  .domain([0, xMax * 1.1])   // pad so max isn't flush
  .range([0, w]);

const y = d3.scaleBand()
  .domain(data.map(d => d.Site))
  .range([0, h])
  .padding(0.2);


// ============================================================================
// PANEL BACKGROUND + BORDER (panel.background / panel.border)
// ============================================================================
g.append("rect")
  .attr("width", w)
  .attr("height", h)
  .attr("fill", colors.panelBg)
  .attr("stroke", colors.border)
  .attr("stroke-width", 1)
  .lower();


// ============================================================================
// GRIDLINES (draw FIRST so they sit behind bars)
// ============================================================================
const gridMajor = g.append("g")
  .attr("class", "grid grid-major")
  .call(
    d3.axisBottom(x)
      .ticks(5)
      .tickSize(h)
      .tickFormat("")
  );

gridMajor.selectAll("line")
  .attr("stroke", colors.gridMajor)
  .attr("stroke-width", 1);

gridMajor.selectAll("path").remove();

const gridMinor = g.append("g")
  .attr("class", "grid grid-minor")
  .call(
    d3.axisBottom(x)
      .ticks(10)
      .tickSize(h)
      .tickFormat("")
  );

gridMinor.selectAll("line")
  .attr("stroke", colors.gridMinor)
  .attr("stroke-width", 0.5)
  .attr("opacity", 0.6);

gridMinor.selectAll("path").remove();


// ============================================================================
// GLOW FILTER (SVG) — create ONCE, reuse
// ============================================================================
const glowFilter = defs.append("filter")
  .attr("id", "bar-glow")
  .attr("x", "-50%")
  .attr("y", "-50%")
  .attr("width", "200%")
  .attr("height", "200%");

glowFilter.append("feGaussianBlur")
  .attr("stdDeviation", 3)
  .attr("result", "coloredBlur");

const feMerge = glowFilter.append("feMerge");

feMerge.append("feMergeNode")
  .attr("in", "coloredBlur");

feMerge.append("feMergeNode")
  .attr("in", "SourceGraphic");


// ============================================================================
// BARS (enter animation)
// ============================================================================
const bars = g.selectAll("rect.bar")
  .data(data)
  .enter()
  .append("rect")
  .attr("class", "bar")
  .attr("y", d => y(d.Site))
  .attr("height", y.bandwidth())
  .attr("x", 0)
  .attr("width", 0)
  .attr("fill", d => d.Color)         // must be passed from R
  .attr("stroke", "#030c13")
  .attr("stroke-width", 1)
  .attr("opacity", 0.85);

bars.transition()
  .duration(800)
  .delay((d, i) => i * 40)
  .ease(d3.easeCubicOut)
  .attr("width", d => x(d.Result_num));


// ============================================================================
// TOOLTIP + INTERACTIONS (D3 v5)
// ============================================================================
bars
  .on("mouseover", function (d) {
    d3.select(this)
      .attr("opacity", 1)
      .attr("stroke-width", 2)
      .attr("filter", "url(#bar-glow)");

    tooltip
      .html(d.TooltipHTML || "")
      .style("opacity", 1);
  })
  .on("mousemove", function () {
    tooltip
      .style("left", (d3.event.pageX + 15) + "px")
      .style("top", (d3.event.pageY + 15) + "px");
  })
  .on("mouseout", function () {
    d3.select(this)
      .attr("opacity", 0.85)
      .attr("stroke-width", 1)
      .attr("filter", null);

    tooltip.style("opacity", 0);
  });


// ============================================================================
// Y AXIS
// ============================================================================

function clamp(x, lo, hi) {
  return Math.max(lo, Math.min(hi, x));
}

// Use the number of visible ticks/labels (pick one)
const fontEm = clamp(1.75 - 0.02 * data.length, 1.3, 1.75);

const yAxis = g.append("g")
  .attr("class", "axis axis-y")
  .call(d3.axisLeft(y));

yAxis.selectAll("text")
  .attr("font-family", "Segoe UI, sans-serif")
  .style("font-size", `${fontEm}em`)
  .attr("fill", colors.axisText);

yAxis.selectAll("path, line")
  .attr("stroke", colors.axisTitle)
  .attr("stroke-width", 1);


// ============================================================================
// X AXIS
// ============================================================================

const maxVal = d3.max(data, d => d.Result);
const digitCount = Math.floor(Math.abs(maxVal)).toString().length;
const fontEmX = digitCount <= 5 ? 6 : 4;


const xAxis = g.append("g")
  .attr("class", "axis axis-x")
  .attr("transform", `translate(0,${h})`)
  .call(d3.axisBottom(x).ticks(fontEmX));

xAxis.selectAll("text")
  .attr("font-family", "Segoe UI, sans-serif")
  .style("font-size", `${fontEm}em`)
  .attr("fill", colors.axisText);

xAxis.selectAll("path, line")
  .attr("stroke", colors.axisTitle)
  .attr("stroke-width", 1);


// ============================================================================
// X AXIS TITLE
// ============================================================================
svg.append("text")
  .attr("text-anchor", "middle")
  .attr("font-family", "Segoe UI, sans-serif")
  .attr("font-size", "1em")
  .attr("font-weight", "bold")
  .attr("fill", colors.axisTitle)
  .attr("x", margin.left + w / 2)
  .attr("y", height - 10)
  .text(units);



//wq std line
const xStd = margin.left + x(wq_std);
const yTop = margin.top + headerHeight;
const yBot = yTop + h;

const wqLine = svg.append("line")
  .attr("x1", xStd)
  .attr("x2", xStd)
  .attr("y1", yTop)
  .attr("y2", yTop)               // start collapsed
  .attr("stroke", "#C0392B")
  .attr("stroke-width", 2)
  .attr("stroke-dasharray", "6,4")
  .attr("opacity", 0.9);

wqLine
  .transition()
  .duration(800)
  .ease(d3.easeCubicOut)
  .attr("y2", yBot);              // animate to full height

const label = svg.append("text")
  .attr("x", xStd)
  .attr("y", yTop - 8)
  .attr("text-anchor", "middle")
  .attr("font-family", "Segoe UI, sans-serif")
  .attr("font-size", "0.9em")
  .attr("fill", "#C0392B")
  .attr("font-weight", 600)
  .attr("opacity", 0)
  .text("WQ Standard");

label.transition()
  .delay(450)
  .duration(350)
  .attr("opacity", 1);
