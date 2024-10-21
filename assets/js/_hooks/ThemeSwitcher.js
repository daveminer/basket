// Toggles the theme icon based on the state of localStorage
export const ThemeSwitcher = {
    mounted() {
        const themeController = document.querySelector('.theme-controller');

        // Set the initial state of the toggle based on localStorage
        const savedTheme = localStorage.getItem('theme');
        if (themeController) {
            themeController.checked = savedTheme === 'night';
        }
    }
};