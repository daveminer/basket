export const CellValueStore = {
  mounted() {
    this.prevValues = {}; // Initialize an empty object to store previous values
    this.updatePrevValues(); // Set initial previous values on mount

    this.handleEvent("run-updated", () => {
      // Your updated() function code here
      this.flashUpdatedCells(); // Flash cells with updated values
      this.updatePrevValues(); // Update previous values after flashing
    });
  },
  // updated() {
  //   this.flashUpdatedCells(); // Flash cells with updated values
  //   this.updatePrevValues(); // Update previous values after flashing
  // },
  updatePrevValues() {
    // Loop through each cell and update the store with its current value
    this.el.querySelectorAll('td[data-key]').forEach((cell) => {
      const key = cell.getAttribute('data-key'); // Assume each cell has a unique data-key attribute
      this.prevValues[key] = cell.textContent || cell.innerText;
    });
  },
  flashUpdatedCells() {
    let selector = this.el.querySelectorAll('td[data-key]')
    console.log(selector, "SELECTOR")
    this.el.querySelectorAll('td[data-key]').forEach((cell) => {
      const key = cell.getAttribute('data-key');
      console.log(key, "KEY")
      const currentValue = cell.textContent || cell.innerText;
      const prevValue = this.prevValues[key];

      if (!prevValue || !isFinite(Number(currentValue))) return; // Skip if no previous value or not a number

      const prevNum = parseFloat(prevValue);
      const currentNum = parseFloat(currentValue);

      if (isFinite(prevNum) && isFinite(currentNum)) {
        if (prevNum < currentNum) {
          this.applyFlash(cell, 'increase');
        } else if (prevNum > currentNum) {
          this.applyFlash(cell, 'decrease');
        }
      }
    });
  },
  applyFlash(cell, changeType) {
    console.log("APPLYING FLASH")
    // Apply classes based on whether the value increased or decreased
    const flashClass = changeType === 'increase' ? 'bg-emerald-300' : 'bg-rose-300';
    cell.classList.add(flashClass);

    setTimeout(() => {
      console.log("TIMEOUT RUN")
      cell.classList.remove(flashClass)
    }, 3000
    );
  }
};