export const TickerHandler = {
  mounted() {
    this.handleEvent("ticker-removed", ({ ticker }) => {
      console.log(ticker, "TICKERREMOVE")
      let element = document.getElementById(ticker);
      if (element) element.remove();
    })

    this.handleEvent("ticker-added", ({ ticker }) => {
      console.log(ticker, "TICKERADD")
      let table = document.getElementById("ticker-table");
      if (table) {
        let rows = Array.from(table.rows);

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
  // updated() {
  //   let table = document.getElementById("ticker-table");
  //   console.log(table, "TABLE")
  //   if (table) {
  //     let rows = Array.from(table.rows);
  //     console.log(rows, "ROWS")

  //     // Sort the rows by id
  //     rows.sort((a, b) => a.id.localeCompare(b.id));

  //     // Organize the rows in the table
  //     rows.forEach(row => table.appendChild(row));
  //     console.log(rows, "ROWS2")
  //   }
  // }
}