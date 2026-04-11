# Financial Table Styling

## Standard Financial Projection Table

Use PptxGenJS `addTable()` for complex data tables. HTML tables don't convert well.

### Header Row Styling

```javascript
const headerRow = [
  { text: "Year", options: { fill: { color: "0A2540" }, color: "FFFFFF", bold: true, fontSize: 10, align: "center" }},
  { text: "EBITDA", options: { fill: { color: "0A2540" }, color: "FFFFFF", bold: true, fontSize: 10, align: "center" }},
  { text: "Free Cash Flow", options: { fill: { color: "0A2540" }, color: "FFFFFF", bold: true, fontSize: 10, align: "center" }},
  { text: "Interest", options: { fill: { color: "0A2540" }, color: "FFFFFF", bold: true, fontSize: 10, align: "center" }},
  { text: "Loan Balance", options: { fill: { color: "0A2540" }, color: "FFFFFF", bold: true, fontSize: 10, align: "center" }},
  { text: "Cash Balance", options: { fill: { color: "0A2540" }, color: "FFFFFF", bold: true, fontSize: 10, align: "center" }}
];
```

### Alternating Row Styling

```javascript
function formatDataRow(rowData, isEven) {
  const bgColor = isEven ? "F8FAFC" : "FFFFFF";
  return rowData.map((cell, idx) => ({
    text: cell,
    options: {
      fill: { color: bgColor },
      color: "1A1A2E",
      fontSize: 10,
      align: idx === 0 ? "left" : "right",
      fontFace: "Arial"
    }
  }));
}
```

### Complete Table Example

```javascript
const tableData = [
  // Header
  [
    { text: "Year", options: { fill: { color: "0A2540" }, color: "FFFFFF", bold: true, fontSize: 10, align: "center" }},
    { text: "EBITDA", options: { fill: { color: "0A2540" }, color: "FFFFFF", bold: true, fontSize: 10, align: "right" }},
    { text: "Free Cash Flow", options: { fill: { color: "0A2540" }, color: "FFFFFF", bold: true, fontSize: 10, align: "right" }},
    { text: "Interest", options: { fill: { color: "0A2540" }, color: "FFFFFF", bold: true, fontSize: 10, align: "right" }},
    { text: "Loan Payment", options: { fill: { color: "0A2540" }, color: "FFFFFF", bold: true, fontSize: 10, align: "right" }},
    { text: "Loan Balance", options: { fill: { color: "0A2540" }, color: "FFFFFF", bold: true, fontSize: 10, align: "right" }},
    { text: "Cash Flow", options: { fill: { color: "0A2540" }, color: "FFFFFF", bold: true, fontSize: 10, align: "right" }},
    { text: "Cash Balance", options: { fill: { color: "0A2540" }, color: "FFFFFF", bold: true, fontSize: 10, align: "right" }}
  ],
  // Data rows - alternate fill colors
  ["Year 1", "$12,000,000", "$9,600,000", "$1,200,000", "$4,000,000", "$1,176,000", "$58,000,000", "$4,400,000", "$4,400,000"].map((t, i) => ({
    text: t, options: { fill: { color: "F8FAFC" }, fontSize: 10, align: i === 0 ? "left" : "right" }
  })),
  ["Year 2", "$14,400,000", "$11,520,000", "$1,200,000", "$4,800,000", "$1,293,600", "$64,600,000", "$5,520,000", "$9,920,000"].map((t, i) => ({
    text: t, options: { fill: { color: "FFFFFF" }, fontSize: 10, align: i === 0 ? "left" : "right" }
  })),
  // Continue pattern...
];

slide.addTable(tableData, {
  x: 0.3,
  y: 1.4,
  w: 9.4,
  colW: [0.8, 1.3, 1.3, 1.0, 1.1, 1.2, 1.1, 1.2],
  rowH: 0.35,
  border: { pt: 0.5, color: "E2E8F0" },
  valign: "middle"
});
```

## Number Formatting Helpers

```javascript
function formatCurrency(value, abbreviated = true) {
  if (abbreviated) {
    if (value >= 1000000) return `$${(value / 1000000).toFixed(1)}M`;
    if (value >= 1000) return `$${(value / 1000).toFixed(0)}K`;
    return `$${value.toFixed(0)}`;
  }
  return `$${value.toLocaleString()}`;
}

function formatPercent(value, decimals = 2) {
  return `${(value * 100).toFixed(decimals)}%`;
}

function formatMultiple(value) {
  return `${value.toFixed(1)}x`;
}
```

## Summary Metrics Table

Compact key metrics display.

```javascript
const metricsTable = [
  [
    { text: "Key Metrics", options: { fill: { color: "1A56DB" }, color: "FFFFFF", bold: true, fontSize: 11, colspan: 2 }}
  ],
  [
    { text: "Initial Cash Paid", options: { fontSize: 10, color: "64748B" }},
    { text: "$60,000,000", options: { fontSize: 10, bold: true, align: "right", color: "0A2540" }}
  ],
  [
    { text: "Total Acquisition Price", options: { fontSize: 10, color: "64748B", fill: { color: "F8FAFC" }}},
    { text: "$68,800,000", options: { fontSize: 10, bold: true, align: "right", color: "0A2540", fill: { color: "F8FAFC" }}}
  ],
  [
    { text: "IRR", options: { fontSize: 10, color: "64748B" }},
    { text: "98.83%", options: { fontSize: 10, bold: true, align: "right", color: "059669" }}
  ],
  [
    { text: "MOIC", options: { fontSize: 10, color: "64748B", fill: { color: "F8FAFC" }}},
    { text: "268.74x", options: { fontSize: 10, bold: true, align: "right", color: "059669", fill: { color: "F8FAFC" }}}
  ]
];

slide.addTable(metricsTable, {
  x: 5.5,
  y: 1.5,
  w: 3.5,
  colW: [2, 1.5],
  rowH: [0.4, 0.35, 0.35, 0.35, 0.35],
  border: { pt: 0.5, color: "E2E8F0" },
  valign: "middle"
});
```

## Comparison Table

Side-by-side scenario comparison.

```javascript
const comparisonTable = [
  // Headers
  [
    { text: "", options: { fill: { color: "FFFFFF" }}},
    { text: "Base Case", options: { fill: { color: "0A2540" }, color: "FFFFFF", bold: true, fontSize: 11, align: "center" }},
    { text: "Upside", options: { fill: { color: "059669" }, color: "FFFFFF", bold: true, fontSize: 11, align: "center" }},
    { text: "Downside", options: { fill: { color: "DC2626" }, color: "FFFFFF", bold: true, fontSize: 11, align: "center" }}
  ],
  // Rows
  [
    { text: "EBITDA Growth", options: { fontSize: 10, color: "64748B" }},
    { text: "20%", options: { fontSize: 10, bold: true, align: "center" }},
    { text: "25%", options: { fontSize: 10, bold: true, align: "center", color: "059669" }},
    { text: "15%", options: { fontSize: 10, bold: true, align: "center", color: "DC2626" }}
  ],
  [
    { text: "IRR", options: { fontSize: 10, color: "64748B", fill: { color: "F8FAFC" }}},
    { text: "98.8%", options: { fontSize: 10, bold: true, align: "center", fill: { color: "F8FAFC" }}},
    { text: "125.2%", options: { fontSize: 10, bold: true, align: "center", color: "059669", fill: { color: "F8FAFC" }}},
    { text: "72.4%", options: { fontSize: 10, bold: true, align: "center", color: "DC2626", fill: { color: "F8FAFC" }}}
  ],
  [
    { text: "MOIC", options: { fontSize: 10, color: "64748B" }},
    { text: "268.7x", options: { fontSize: 10, bold: true, align: "center" }},
    { text: "412.3x", options: { fontSize: 10, bold: true, align: "center", color: "059669" }},
    { text: "156.8x", options: { fontSize: 10, bold: true, align: "center", color: "DC2626" }}
  ]
];
```

## Debt Schedule Table

Loan amortization styling.

```javascript
// Highlight final payment row
const finalRow = data.length;
tableData[finalRow] = tableData[finalRow].map(cell => ({
  ...cell,
  options: {
    ...cell.options,
    fill: { color: "EFF6FF" },
    bold: true,
    color: "1A56DB"
  }
}));
```

## Column Width Guidelines

| Table Type | Suggested Column Widths |
|------------|------------------------|
| 6-col financial | [0.8, 1.4, 1.4, 1.2, 1.3, 1.3] |
| 8-col detailed | [0.7, 1.2, 1.2, 1.0, 1.0, 1.1, 1.1, 1.1] |
| 3-col summary | [2.5, 1.5, 1.5] |
| 4-col comparison | [1.8, 1.2, 1.2, 1.2] |

## Color Reference for Tables

| Element | Hex Code | Usage |
|---------|----------|-------|
| Header bg | 0A2540 | Navy header rows |
| Header text | FFFFFF | White on dark |
| Alt row | F8FAFC | Light gray alternating |
| Border | E2E8F0 | Subtle borders |
| Positive | 059669 | Green for gains |
| Negative | DC2626 | Red for losses |
| Accent | 1A56DB | Blue highlights |
| Muted text | 64748B | Secondary labels |
