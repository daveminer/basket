
function darkExpected() {
  return localStorage.theme === 'dark' || (!('theme' in localStorage) &&
    window.matchMedia('(prefers-color-scheme: dark)').matches);
}

function setMode() {
  // On page load or when changing themes, best to add inline in `head` to avoid FOUC
  if (darkExpected()) document.documentElement.classList.add('dark');
  else document.documentElement.classList.remove('dark');
}

export function toggleDarkMode() {
  console.log("TOGGLEDARKMODE")
  if (darkExpected()) localStorage.theme = 'light';
  else localStorage.theme = 'dark';
  setMode();
}
