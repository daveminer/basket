export const HideShowArticles = {
  mounted() {
    this.el.addEventListener("click", (event) => {
      if (event.target && event.target.matches(".article-content-toggle")) {
        const elemId = event.target.parentElement.id;
        const idParts = elemId.split("-");

        const action = idParts[2];
        const id = idParts[3];

        const content = document.getElementById(`article-content-${id}`);
        const toggle = document.getElementById(`article-toggle-open-${id}`);
        const otherToggle = document.getElementById(`article-toggle-close-${id}`);

        toggle.classList.toggle('hidden');
        otherToggle.classList.toggle('hidden');

        if (action === "open") {
          content.style.display = "block";

        } else if (action === "close") {
          content.style.display = "none";
        }
      }
    })
  },
};