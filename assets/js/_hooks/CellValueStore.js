export const CellValueStore = {
  mounted() {
    this.handleEvent("ticker-update-received", (values) => {
      const id = values["S"];
      // select the table row with id equal to id
      const row = document.querySelector(`tr[id="${id}"]`);
      this.highlightChanges(row, values);
    });
  },

  highlightChanges(row, values) {
    const cells = row.querySelectorAll('td[data-key]')
    // Loop through each cell in the row and update the text content
    cells.forEach((cell) => {
      const dataKey = cell.getAttribute('data-key');
      const [_ticker, key] = dataKey.split('_');

      let value;
      switch (key) {
        case 'open':
          value = values['o'];
          break;
        case 'high':
          value = values['h'];
          break;
        case 'low':
          value = values['l'];
          break;
        case 'close':
          value = values['c'];
          break;
        case 'volume':
          value = values['v'];
          break;
        default:
          break;
      }

      if (isFinite(value)) {
        // Multiple content slots
        const content = cell.querySelectorAll('[id$=content-slot]')
        const oldValue = content[0].textContent;
        content[0].textContent = value;
        if (oldValue && isFinite(oldValue)) {
          const oldNum = parseFloat(oldValue);
          const newNum = parseFloat(value);
          if (oldNum < newNum) {
            cell.classList.add('bg-emerald-300');
            setTimeout(() => {
              cell.classList.remove('bg-emerald-300');
            }, 3000);
          } else if (oldNum > newNum) {
            cell.classList.add('bg-rose-300');
            setTimeout(() => {
              cell.classList.remove('bg-rose-300');
            }, 3000);
          }
        }
      }
    });
  }
};