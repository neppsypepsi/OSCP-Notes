# HTML Basics (OSCP Context)

HTML is the language browsers use to display web pages. You don't need to build sites — you need to read it, navigate it, and inject into it without breaking things.

---

## Tags

Everything in HTML is a **tag** — an instruction wrapped in angle brackets.

```html
<h2>This is a heading</h2>
<p>This is a paragraph</p>
```

- Opening tag: `<h2>`
- Content: whatever sits between them
- Closing tag: `</h2>` — the `/` is what closes it

Some tags don't need a closing tag — they're self-contained:
```html
<img src="/images/logo.png" />
<br />
```

---

## Attributes

Extra info attached to a tag, always inside the opening tag:
```html
<a href="https://google.com">Click here</a>
<img src="/logo.png" alt="logo" align="left" />
```

Format is always `attribute="value"`. The quotes matter — breaking out of them is how XSS works.

---

## Structure — Tags Inside Tags

HTML is nested. Tags live inside other tags:
```html
<div>
    <h2>Title</h2>
    <p>Some text with a <a href="#">link</a> inside it</p>
</div>
```

`<div>` is just an invisible container used to group things — no visual effect on its own.

---

## Common Tags You'll See

| Tag | What it does |
|---|---|
| `<h1>` to `<h6>` | Headings (h1 = biggest) |
| `<p>` | Paragraph |
| `<a href="...">` | Clickable link |
| `<img src="...">` | Image |
| `<div>` | Container/grouping |
| `<form>` | User input form |
| `<input>` | Text field, button, etc. |
| `<script>` | JavaScript code |
| `<style>` | CSS styling |

---

## Why This Matters for OSCP

**Don't break the page structure**
When injecting a payload, unclosed tags can corrupt the page and stop your code from executing. Keep your payload self-contained and on its own line.

**Know where you are**
Your injection point changes what characters cause problems:
- Inside a tag's content → `<` and `>` are your escape characters
- Inside an attribute value → `"` or `'` is what you need to break out of
- Inside a `<script>` block → you're already in JavaScript context

**XSS lives here**
Cross-site scripting is about injecting a `<script>` tag (or breaking out of an attribute into one) so the browser executes your JavaScript. Knowing HTML structure tells you how to do that.

**View source is your friend**
`Ctrl+U` in the browser shows raw HTML. Use it to:
- Find hidden inputs and fields
- Spot comments left by developers
- See what template tags are in the page
- Identify what scripting engine is being used

---

## Related Notes

- [[Web_Enum]]
- [[Web_Template_RCE]]
- [[ReverseShells]]
