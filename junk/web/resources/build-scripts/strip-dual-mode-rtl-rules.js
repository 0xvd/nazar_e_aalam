/**
 * AdminKit's app.css already ships self-contained LTR/RTL pairs for sidebar
 * positioning, gated behind `body[data-sidebar-position="right"]` (covers
 * sidebar margins, collapse/expand, navbar-align, scrollbar track — at every
 * breakpoint). rtlcss has no way to know that, so it blindly re-mirrors those
 * already-correct rules too, producing a second, contradictory copy. Since
 * app-rtl.css loads after app.css, its mirrored copy wins the cascade and
 * fights the theme's own correct values once the attribute is set.
 *
 * Rather than re-deriving every breakpoint by hand, just drop any rule whose
 * selector references this attribute from the generated RTL file — the
 * original app.css already has the correct counterpart for both states.
 */
import fs from "node:fs";
import postcss from "postcss";

const file = process.argv[2];
if (!file) {
    console.error("Usage: node strip-dual-mode-rtl-rules.js <css-file>");
    process.exit(1);
}

const css = fs.readFileSync(file, "utf8");
const root = postcss.parse(css);

let removed = 0;
root.walkRules((rule) => {
    if (rule.selector.includes("data-sidebar-position")) {
        rule.remove();
        removed++;
    }
});

// Drop now-empty @media blocks left behind.
root.walkAtRules("media", (atRule) => {
    if (atRule.nodes.length === 0) atRule.remove();
});

fs.writeFileSync(file, root.toString());
console.log(`Stripped ${removed} data-sidebar-position rule(s) from ${file}`);
