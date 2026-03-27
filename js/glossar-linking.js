document.addEventListener("DOMContentLoaded", async () => {

    // Do not run on the glossary page itself
    if (window.location.pathname.startsWith('/pages/glossary')) return;

    // Only run on blog article pages
    if (!window.location.pathname.startsWith('/blog/')) return;

    // 1) Load glossary JSON
    let glossary = {};
    try {
        const res = await fetch("/pages/terms.json");
        glossary = await res.json();
    } catch (e) {
        console.error("Glossary could not be loaded:", e);
        return;
    }

    // 2) Find target content area
    const selectors = [
        ".article-body",
        ".container",
        "main",
        ".post",
        ".content"
    ];

    let target = null;
    for (const s of selectors) {
        const el = document.querySelector(s);
        if (el) { target = el; break; }
    }
    if (!target) return;

    let html = target.innerHTML;

    // Protect existing links from being modified
    html = html.replace(/<a\b[^>]*>.*?<\/a>/gi, m =>
        m.replace(/</g, "§§LT§§").replace(/>/g, "§§GT§§")
    );

    // 3) Link glossary terms
    for (const [term, slug] of Object.entries(glossary)) {
        const safeTerm = term.replace(/[-/\\^$*+?.()|[\]{}]/g, "\\$&");
        const regex = new RegExp(`\\b(${safeTerm})\\b`, "gi");

        html = html.replace(regex,
            `<a href="/pages/glossary.html?term=${slug}" class="glossar-link">$1</a>`
        );
    }

    // Restore protected links
    html = html.replace(/§§LT§§/g, "<").replace(/§§GT§§/g, ">");

    // 4) Apply changes
    target.innerHTML = html;

});
