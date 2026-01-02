// Remove structural elements that might still contain clutter
document.querySelectorAll('header, footer, nav, aside, form').forEach(el => el.remove());

// Remove any leftover inline styles or scripts for a clean slate
document.querySelectorAll('style, script, link').forEach(el => el.remove());

// Apply new styles for readability
const style = document.createElement('style');
style.textContent = `
    body {
        font-family: -apple-system, sans-serif;
        line-height: 1.6;
        font-size: 18px;
        max-width: 800px;
        margin: 0 auto;
        padding: 2rem;
        background-color: #ffffff;
        color: #212121;
    }
    a {
        color: #007aff;
    }
    h1, h2, h3, h4, h5, h6 {
        line-height: 1.2;
    }
`;
document.head.appendChild(style);
