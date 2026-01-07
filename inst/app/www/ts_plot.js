// ============================================================================
// Faceted time-series (r2d3 / D3 v5)
// Shared X (Date), per-facet Y (ReadingNum)
// ============================================================================

// r2d3 provides: data, svg, width, height
svg.selectAll("*").remove();


// ---- Layout constants ----
const headerHeight = 90;
const margin = { top: 30, right: 25, bottom: 25, left: 25 };
const colGutter = 50;
const rowGutter = 10;
const nCols = 2;

// ---- Theme colors ----
const colors = {
  plotBg: "#F1F9FF",
  panelBg: "#dee6f2",
  border: "#4b7591ff",
  gridMajor: "#C0C7CD",
  gridMinor: "#E5E9ED",
  axisText: "#064789",
  axisTitle: "#0A2B43",
  caption: "#345A88"
};

// ---- Background ----
svg
  .attr("width", width)
  .attr("height", height)
  .style("background", colors.plotBg)
  .style("border", `1px solid ${colors.border}`);

svg.append("rect")
  .attr("x", 0)
  .attr("y", 0)
  .attr("width", width)
  .attr("height", height)
  .attr("fill", colors.plotBg)

// ---- Parse + sanitize once (DO THIS FIRST) ----
const parseYMD = d3.timeParse("%Y-%m-%d");

data.forEach(d => {
  // If Date already, keep it. If string like "2025-04-08", parse locally.
  d.Date = (d.Date instanceof Date) ? d.Date : parseYMD(String(d.Date).slice(0, 10));
  d.ReadingNum = +d.ReadingNum;
});

const clean = data.filter(d =>
  d.LabelName != null &&
  d.Date instanceof Date && !isNaN(+d.Date) &&
  isFinite(d.ReadingNum)
);

// ---- Build facets ONCE from clean data ----
const facets = d3.nest()
  .key(d => d.LabelName)
  .entries(clean);

// ---- Optional fixed facet order ----
const desiredOrder = [
  "E. coli",
  "Dissolved Oxygen",
  "Fecal Coliform",
  "Average Basin Wide Precip"
];

const orderIndex = {};
desiredOrder.forEach((d, i) => { orderIndex[d] = i; });

facets.sort((a, b) => {
  let ia = orderIndex[a.key];
  let ib = orderIndex[b.key];
  if (ia === undefined) ia = 9999;
  if (ib === undefined) ib = 9999;
  return ia - ib;
});

// ---- Inner plotting area within each facet ----
const inner = { top: 70, right: 50, bottom: 40, left: 80 };

// ---- Compute facet plot size (based on final facets) ----
const nRows = Math.ceil(facets.length / nCols);

const plotWidth =
  (width - margin.left - margin.right - colGutter * (nCols - 1)) / nCols;

const plotHeight =
  (height - margin.top - margin.bottom - headerHeight - rowGutter * (nRows - 1)) / nRows;

const innerW = plotWidth - inner.left - inner.right;
const innerH = plotHeight - inner.top - inner.bottom;

// ---- Shared X (global domain) ----
const xDomain = d3.extent(clean, d => d.Date);

// --- derive the year from your filtered data ---
const year = d3.timeYear.floor(xDomain[0]).getFullYear();

// --- fixed ticks: Jan 1..Dec 1 (always 12 ticks) ---
const monthTicks = d3.timeMonth.range(
  new Date(year, 0, 1),
  new Date(year + 1, 0, 1) // exclusive end
);

// single-letter month labels
const monthLetter = d => "JFMAMJJASOND"[d.getMonth()];

const x = d3.scaleTime()
  .domain([new Date(year, 0, 1), new Date(year, 11, 31, 23, 59, 59)]) // force full year
  .range([0, innerW]);

const xAxis = d3.axisBottom(x)
  .tickValues(monthTicks)
  .tickFormat(monthLetter)
  .tickSizeOuter(0);

// ---- Root group ----
const gRoot = svg.append("g")
  .attr("transform", `translate(${margin.left},${margin.top + headerHeight})`);

// ---- One group per facet ----
const facetG = gRoot.selectAll(".facet")
  .data(facets, d => d.key)
  .enter()
  .append("g")
  .attr("class", "facet")
  .attr("transform", (d, i) => {
    const col = i % nCols;
    const row = Math.floor(i / nCols);
    const x0 = col * (plotWidth + colGutter);
    const y0 = row * (plotHeight + rowGutter);
    return `translate(${x0},${y0})`;
  });

// ---- Panel + title ----
facetG.append("rect")
  .attr("class", "panel-bg")
  .attr("x", 0)
  .attr("y", 0)
  .attr("width", plotWidth)
  .attr("height", plotHeight)
  .attr("fill", colors.panelBg)
  .attr("stroke", colors.border);


// ---- Plot area group per facet ----
facetG.append("g")
  .attr("class", "plot-area")
  .attr("transform", `translate(0,${inner.top})`);

// ---- Line generator (per-facet y injected) ----
const line = d3.line()
  .defined(d => isFinite(d.ReadingNum))
  .x(d => x(d.Date))
  .y(d => d._y(d.ReadingNum));

// ---- Draw per facet ----
facetG.each(function (facet, i) {
  const gFacet = d3.select(this);
  const gPlot = gFacet.select(".plot-area");
  const row = Math.floor(i / nCols);

  const rows = (facet.values || [])
    .slice()
    .sort((a, b) => a.Date - b.Date);

  if (!rows.length) return;

  let [yMin, yMax] = d3.extent(rows, d => d.ReadingNum);
  if (!isFinite(yMin) || !isFinite(yMax)) return;

  if (yMin === yMax) {
    const pad = (yMin === 0 ? 1 : Math.abs(yMin) * 0.1);
    yMin -= pad;
    yMax += pad;
  }

  // Dynamic Left axis locatio
  const maxAbs = Math.max(Math.abs(yMin), Math.abs(yMax));
  const digits = String(Math.round(maxAbs)).replace("-", "").length;
  const leftPad = Math.max(45, 75 + digits * 8);

  // --- move plot area right by leftPad ---
  gPlot.attr("transform", `translate(${leftPad},${inner.top})`);


  // add background 


  // Dynamic Title Placement
  // Facet title aligned above the y-axis line
  gFacet.selectAll(".facet-title").remove();  // avoid duplicates on re-render

  gFacet.append("text")
    .attr("class", "facet-title")
    .attr("x", leftPad)      // <-- aligns with y-axis line
    .attr("y", 40)
    .attr("font-size", "28px")
    .attr("font-weight", "400")
    .style("fill", colors.axisTitle)
    .style("font-style", facet.key === "E. coli" ? "italic" : "normal")
    .attr("text-anchor", "start")
    .text(facet.key);

  const y = d3.scaleLinear()
    .domain([yMin, yMax])
    .nice()
    .range([innerH, 0]);

  const yAxis = d3.axisLeft(y)
    .ticks(4)
    .tickSizeOuter(0);

  // Clear any previous render inside this facet
  gPlot.selectAll("*").remove();

  // ----------------------------
  // GRIDLINES (draw first so they stay behind)
  // ----------------------------
  // Y gridlines
  gPlot.append("g")
    .attr("class", "y-grid")
    .call(
      d3.axisLeft(y)
        .ticks(4)
        .tickSize(-innerW)
        .tickFormat("")
    )
    .selectAll("line")
    .style("stroke", colors.gridMinor);

  gPlot.selectAll(".y-grid path").remove();

  // X gridlines (ALIGN WITH monthTicks)
  gPlot.append("g")
    .attr("class", "x-grid")
    .attr("transform", `translate(0,${innerH})`)
    .call(
      d3.axisBottom(x)
        .tickValues(monthTicks)   // <— key change vs .ticks(5)
        .tickSize(-innerH)
        .tickFormat("")
    );

  gPlot.selectAll(".x-grid line")
    .style("stroke", colors.axisText)
    .style("stroke-width", "0.5px")
    .style("stroke-opacity", 0.35)
    .style("shape-rendering", "crispEdges");

  gPlot.selectAll(".x-grid path").remove();

  // ----------------------------
  // AXES
  // ----------------------------
  gPlot.append("g")
    .attr("class", "y-axis")
    .call(yAxis)
    .selectAll("text")
    .style("font-size", 18)
    .style("fill", colors.axisText);

  const xAxisG = gPlot.append("g")
    .attr("class", "x-axis")
    .attr("transform", `translate(0,${innerH})`)
    .call(xAxis);

  xAxisG.selectAll("text")
    .attr("text-anchor", "middle")
    .attr("transform", null)   // or .attr("transform", "rotate(0)")
    .attr("dx", "0em")
    .attr("dy", "0.9em")
    .style("font-size", 18)
    .style("fill", colors.axisText);

  gPlot.selectAll(".x-axis path,.x-axis line,.y-axis path,.y-axis line")
    .style("stroke", colors.gridMajor);

  // Inject per-facet y into rows for line generator
  rows.forEach(r => { r._y = y; });


  // ----------------
  // Y axes label
  // -------------

  const unit = rows.find(d => d.Units != null && d.Units !== "")?.Units || "";
  gPlot.append("text")
    .attr("class", "y-axis-label")
    .attr("transform", "rotate(-90)")
    .attr("x", -innerH / 2)
    .attr("y", -leftPad + 28)   // tuck just left of tick labels
    .attr("text-anchor", "middle")
    .style("font-size", "20px")
    .attr("font-weight", "600")
    .style("fill", colors.axisTitle)
    .text(unit);

  // ----------------------------
  // SERIES (draw last so it's on top)
  // ----------------------------
  gPlot.append("path")
    .datum(rows)
    .attr("class", "series-line")
    .attr("fill", "none")
    .attr("stroke", colors.axisText)
    .attr("stroke-width", 3)
    .attr("d", line);

  gPlot.selectAll(".pt")
    .data(rows.filter(d => isFinite(d.ReadingNum)))
    .enter()
    .append("circle")
    .attr("class", "pt")
    .attr("r", d => /Precip/i.test(d.LabelName) ? 0 : 6)
    .attr("cx", d => x(d.Date))
    .attr("cy", d => y(d.ReadingNum))
    .attr("fill", "#219e77");
});
