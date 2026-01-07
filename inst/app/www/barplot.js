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

const headerHeight = 105;
const margin = { top: 30, right: 25, bottom: 90, left: 75 };
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


// ============================================================================
// SVG BACKGROUND (plot.background)
// ============================================================================
svg
  .style("background", colors.plotBg)
  .style("border", `1px solid ${colors.border}`);


// ============================================================================
// DEFINITIONS (single <defs> for legend + glow)
// ============================================================================
const defs = svg.append("defs");


// ============================================================================
// HEADER BAND
// ============================================================================
svg.append("rect")
  .attr("x", 0)
  .attr("y", 0)
  .attr("width", width)
  .attr("height", headerHeight)
  .attr("fill", colors.panelBg)
  .attr("stroke", colors.border)
  .attr("stroke-width", 1);


// ============================================================================
// TITLE + SUBTITLE (left-aligned)
// ============================================================================
const titleGroup = svg.append("g")
  .attr("transform", "translate(25, 32)");

titleGroup.append("text")
  .attr("font-family", "Segoe UI, sans-serif")
  .attr("font-size", "24px")
  .attr("font-weight", "bold")
  .attr("fill", colors.axisTitle)
  .text(title);

titleGroup.append("text")
  .attr("y", 26)
  .attr("font-family", "Segoe UI, sans-serif")
  .attr("font-size", "16px")
  .attr("fill", colors.caption)
  .text(subtitle);

titleGroup.append("text")
  .attr("y", 50)
  .attr("font-family", "Segoe UI, sans-serif")
  .attr("font-size", "16px")
  .attr("fill", colors.caption)
  .text(precip_title);

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

// -----------------------------------------------------------------------------
// Precip line + inline info glyph
// -----------------------------------------------------------------------------
const precipText = titleGroup.append("text")
  .attr("y", 50)
  .attr("font-family", "Segoe UI, sans-serif")
  .attr("font-size", "16px")
  .attr("fill", colors.caption);

precipText.append("tspan").text(precip_title);

const infoIcon = precipText.append("tspan")
  .text("  ⓘ")
  .attr("fill", colors.axisTitle)
  .style("cursor", "help");

// Tooltip content
const tooltipLines = [
  "Precipitation Data",
  "MMSD maintains a network of weather stations throughout its service area.",
  "Each monitoring site is assigned the nearest weather station.",
  "Values represent total precipitation during the 72 hours prior to sampling.",
  "Range reflects min and max based on current page filters."
];

// -----------------------------------------------------------------------------
// Hover behavior (simple + clean)
// -----------------------------------------------------------------------------
infoIcon
  .on("mouseover", function () {
    const pad = 12;

    // Build text
    setTooltipText(tooltipLines);

    // Position text inside tooltip
    tooltipText.attr("x", pad).attr("y", pad);
    tooltipText.selectAll("tspan").attr("x", pad);

    // Measure after it exists
    const bbox = tooltipText.node().getBBox();

    // Size background
    tooltipBg
      .attr("width", bbox.width + pad * 2)
      .attr("height", bbox.height + pad * 2);

    // Position tooltip near icon (using icon bbox in titleGroup space)
    const iconBox = this.getBBox();
    const tipX = 25 + iconBox.x + iconBox.width - 220;  // move left ~220px
    const tipY = 32 + 50 - 14; // slight lift looks nicer

    tooltip1.raise(); // keep above other SVG elements
    tooltip1
      .attr("transform", `translate(${tipX}, ${tipY + 4})`)
      .style("display", null)
      .interrupt()
      .style("opacity", 0)
      .transition()
      .duration(120)
      .style("opacity", 1)
      .attr("transform", `translate(${tipX}, ${tipY})`);
  })
  .on("mouseout", function () {
    tooltip1
      .interrupt()
      .transition()
      .duration(100)
      .style("opacity", 0)
      .on("end", () => tooltip1.style("display", "none"));
  });

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
const yAxis = g.append("g")
  .attr("class", "axis axis-y")
  .call(d3.axisLeft(y));

yAxis.selectAll("text")
  .attr("font-family", "Segoe UI, sans-serif")
  .attr("font-size", "20px")
  .attr("fill", colors.axisText);

yAxis.selectAll("path, line")
  .attr("stroke", colors.axisTitle)
  .attr("stroke-width", 1);


// ============================================================================
// X AXIS
// ============================================================================
const xAxis = g.append("g")
  .attr("class", "axis axis-x")
  .attr("transform", `translate(0,${h})`)
  .call(d3.axisBottom(x).ticks(5));

xAxis.selectAll("text")
  .attr("font-family", "Segoe UI, sans-serif")
  .attr("font-size", "20px")
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
  .attr("font-size", "22px")
  .attr("font-weight", "bold")
  .attr("fill", colors.axisTitle)
  .attr("x", margin.left + w / 2)
  .attr("y", height - 20)
  .text(units);


// ============================================================================
// GRADIENT LEGEND (right-aligned in header)
// ============================================================================
const legendWidth = 260;
const legendHeight = 16;

const legendX = width - legendWidth - 25;
const legendY = 48;

const legendGroup = svg.append("g")
  .attr("transform", `translate(${legendX}, ${legendY})`);

const gradient = defs.append("linearGradient")
  .attr("id", "legend-gradient")
  .attr("x1", "0%")
  .attr("x2", "100%")
  .attr("y1", "0%")
  .attr("y2", "0%");

// ----------------------------------------------------------------------------
// Legend gradient: value-linear, matches R palette direction via options.sort_desc
// ----------------------------------------------------------------------------
const valueAccessor = d => +d.Result_num; // or +d.Result, whichever your data actually has
const extent = d3.extent(data, valueAccessor);
const minV = extent[0], maxV = extent[1];
const midV = (minV + maxV) / 2;

// In R:
//   if (is_do) palette = c("red","orange","blue")
//   else       palette = c("blue","orange","red")
const legendColors = options.sort_desc
  ? ["red", "orange", "blue"]
  : ["blue", "orange", "red"];

const legendColorScale = d3.scaleLinear()
  .domain([minV, midV, maxV])
  .range(legendColors)
  .clamp(true)
  .interpolate(d3.interpolateLab);

const nStops = 40;
d3.range(nStops).forEach(i => {
  const t = i / (nStops - 1);
  const v = minV + t * (maxV - minV);
  gradient.append("stop")
    .attr("offset", `${t * 100}%`)
    .attr("stop-color", legendColorScale(v));
});

legendGroup.append("rect")
  .attr("width", legendWidth)
  .attr("height", legendHeight)
  .attr("rx", 4)
  .attr("ry", 4)
  .attr("fill", "url(#legend-gradient)")
  .attr("stroke", colors.axisTitle)
  .attr("stroke-width", 1);

const legendScale = d3.scaleLinear()
  .domain(extent)         // reuse the same extent from above
  .range([0, legendWidth]);
const legendAxis = d3.axisBottom(legendScale)
  .ticks(4)
  .tickSize(6);

legendGroup.append("g")
  .attr("transform", `translate(0, ${legendHeight})`)
  .call(legendAxis);

legendGroup.selectAll("text")
  .attr("font-family", "Segoe UI, sans-serif")
  .attr("font-size", "14px")
  .attr("fill", colors.axisText);

legendGroup.selectAll("path, line")
  .attr("stroke", colors.axisTitle);
