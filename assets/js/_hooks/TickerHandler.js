export const TickerHandler = {
  mounted() {
    this.handleEvent("ticker-removed", ({ ticker }) => {
      let element = document.getElementById(ticker);
      if (element) element.remove();
    })

    this.handleEvent("ticker-added", ({ bars }) => {
      let table = document.getElementById("ticker-table");
      if (table) {
        let rows = Array.from(table.rows);
        rows.push(createRow(bars))

        // Sort the rows by id
        rows.sort((a, b) => a.id.localeCompare(b.id));

        // Remove all rows from the table
        while (table.firstChild) {
          table.removeChild(table.firstChild);
        }

        // Append the sorted rows to the table
        for (let row of rows) {
          table.appendChild(row);
        }
      }
    })
  }
}

function createRow(bars) {
  console.log(bars, "BARS")
  let row = document.createElement("tr");
  // add an id to the row
  row.id = bars.ticker;

  // add classes to the row
  row.classList.add("group");
  row.classList.add("hover:bg-zinc-50");
  row.classList.add("text-sm");
  row.classList.add("text-zinc-700");

  let tickerTd = createCell(bars)
  row.appendChild(tickerTd);

  const labelledValues = buildLabels(bars);

  for (idx in labelledValues) {
    //console.log(td, "TD")
    //let td = createCell(cell, bars.ticker)
    row.appendChild(labelledValues[idx]);
  }

  let deleteTd = createCell('x')
  row.appendChild(deleteTd)
  // for (cell in bars) {
  //   let td = createCell(cell)
  //   row.appendChild(td);
  // }

  return row
}

function buildLabels(bars) {
  const labels = [
    { label: "Open", value: bars.open },
    { label: "High", value: bars.high },
    { label: "Low", value: bars.low },
    { label: "Close", value: bars.close },
    { label: "Volume", value: bars.volume },
    { label: "Timestamp", value: bars.timestamp }
  ]

  let cells = [];
  for (idx in labels) {
    const { label, value } = labels[idx];
    let td = createCell(label, bars.ticker, value)
    cells.push(td);
  }

  return cells;
}

function createCell(label, ticker, value) {
  let td = document.createElement("td");
  td.classList.add("relative");
  td.classList.add("p-0");
  td.classList.add("text-center");
  td.classList.add("hover:cursor-pointer");

  // add a data-key attribute to the cell
  td.setAttribute("data-key", `${ticker}_${label}`);

  // add a div to the cell inner
  let div = document.createElement("div");
  div.classList.add("block");
  div.classList.add("py-4");
  div.classList.add("pr-6");

  let span = document.createElement("span");
  span.classList.add("absolute");
  span.classList.add("-inset-y-px");
  span.classList.add("right-0");
  span.classList.add("-left-4");
  span.classList.add("group-hover:bg-zinc-50");
  span.classList.add("sm:rounded-l-xl");

  let contentSpan = document.createElement("span");
  contentSpan.classList.add(`${ticker}_${label}-content-slot`)
  contentSpan.classList.add("relative");
  contentSpan.classList.add("font-semibold");
  contentSpan.classList.add("text-zinc-900");
  contentSpan.innerText = value;

  div.appendChild(span);
  div.appendChild(contentSpan);

  td.appendChild(div);

  return td;
}
