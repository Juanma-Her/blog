# JSON contracts and interfaces

> Snapshot of the planning document as of 2026-11-22 (launch). Not updated after that.

## JSON contracts and interfaces

*2026-11-21*

### 1. Conventions

The blog has no API: GitHub Pages serves static files. The contracts that matter are the **content files** the author writes (front matter and JSON data files), the **routes** the build produces, the **include and filter signatures** layouts call, and the **browser-side contracts** between HTML and JavaScript. Each data contract has a JSON Schema in schemas/, and scripts/validate.rb checks every file against it in CI (BLG-50).

- Keys in snake_case; identifiers as in section 3 of the Design document.
- A missing optional value is left out. null, empty strings and placeholder text such as "TODO" are rejected.
- **Localized** means { "en": string, "es": string } with both keys required and non-empty.
- **Url** means an absolute https:// URL, or a site path starting with /.
- In the examples, // comment explains a field. Real files are strict JSON or YAML without those comments.
- Examples are **normative in names, types and structure**, and are copied into _posts/ and _data/ as sample content to build pages before real content exists (BLG-10). Names, dates and numbers in them are illustrative.
- Schemas set "additionalProperties": false: a typo in a key fails CI instead of being silently ignored.

### 2. Routes

The equivalent of an endpoint table: every URL the build produces. All are GET, static, and return 200 unless stated.

| **Route** | **Lang** | **Source** | **Content type** | **Description** | **Status** |
|---|---|---|---|---|---|
| / | en | index.html + home layout | text/html | Home | Planned |
| /es/ | es | es/index.html | text/html | Home | Planned |
| /posts/ | en | posts.html + archive layout | text/html | Archive | Planned |
| /es/posts/ | es | es/posts.html | text/html | Archive | Planned |
| /posts/{slug}/ | en | _posts/en/\*.md + post layout | text/html | Post | Planned |
| /es/posts/{slug}/ | es | _posts/es/\*.md | text/html | Post | Planned |
| /projects/ | en | projects.html + _data/projects.json | text/html | Projects | Planned |
| /es/projects/ | es | es/projects.html | text/html | Projects | Planned |
| /about/ | en | about.html + _data/about.json | text/html | About | Planned |
| /es/about/ | es | es/about.html | text/html | About | Planned |
| /feed/ | en | feed.html + feed layout | text/html | Feed page | Planned |
| /es/feed/ | es | es/feed.html | text/html | Feed page | Planned |
| /feed.xml | en | feed.xml | application/xml (Atom) | Latest 20 English posts | Planned |
| /es/feed.xml | es | es/feed.xml | application/xml (Atom) | Latest 20 Spanish posts | Planned |
| /feed/by_tag/{tag}.xml | en | _plugins/feeds.rb | application/xml (Atom) | English posts with that tag | Planned |
| /es/feed/by_tag/{tag}.xml | es | _plugins/feeds.rb | application/xml (Atom) | Spanish posts with that tag | Planned |
| /sitemap.xml | both | jekyll-sitemap | application/xml | All pages | Planned |
| /robots.txt | both | robots.txt | text/plain | Points to the sitemap | Planned |
| /404.html | both | 404.html | text/html (served with 404) | Not found | Planned |

Notes:

- {slug} is the file name without the date and extension. {tag} is a key of _data/topics.json.
- Every HTML route has a trailing slash; Jekyll writes index.html inside a folder.
- Nothing writes data, so there is nothing equivalent to POST, PUT or DELETE. Comments go to GitHub through giscus, outside this site.

### 3. Post front matter

#### 3.1 Fields

| **Field** | **Type** | **Required** | **Description** |
|---|---|---|---|
| title | string, 1 to 110 characters | Yes | Post title |
| date | date or datetime | Yes | Publication date; in the file name too |
| description | string, 40 to 200 characters, one sentence | Yes | Summary for cards, archive, feeds and meta description |
| tags | array of tag, 1 to 5, unique | Yes | First one is the primary topic; all must exist in topics.json |
| ref | string, lowercase with hyphens | Yes | Translation key; the same in both language versions |
| lang | "en" or "es" | No | Set by the folder; if present it must match the folder |
| updated | date | No | Shown as "Updated" under the date |
| hero_code | object | No | Code shown on the home hero when this is the latest post |
| hero_code.lang | string | Yes, in hero_code | Rouge language name |
| hero_code.code | string, at most 12 lines | Yes, in hero_code | The code |
| comments | boolean | No, default true | false hides the comment box |
| image | Url | No | Social preview image |

#### 3.2 Example

```
---
title: "Writing a tiny Lisp interpreter in Rust"
date: 2026-11-14
description: "Tokenize, parse, evaluate: a working interpreter in about 200 lines."
tags: [rust, interpreters]
ref: tiny-lisp
hero_code:
  lang: scheme
  code: |
    (define (fact n)
      (if (= n 0) 1
          (* n (fact (- n 1)))))
---
```

The Spanish version is _posts/es/2026-11-14-un-lisp-pequeno-en-rust.md with ref: tiny-lisp and its own title and description.

#### 3.3 Markdown extensions used in posts

| **Element** | **Syntax** | **Renders as** |
|---|---|---|
| Code with file name | Fenced block followed by {: data-file="src/lexer.rs"} | Code figure with header and copy button |
| Note callout | Blockquote followed by {: .note} | Blue note with icon |
| Heading anchors | Automatic from kramdown ids | Linkable headings |
| Inline math | $$O(n \\log n)$$ inside a sentence | KaTeX formula in the line of text. A single $ is plain text; a literal $$ is written \\$\\$ |
| Display math | A paragraph that is only $$ ... $$, with a blank line before and after | Centred KaTeX block; scrolls sideways if wider than the column |

#### 3.4 Static pages

Page stubs (index.html, es/posts.html, and so on) have only front matter:

```
---
layout: archive
lang: es
ref: archive
permalink: /es/posts/
---
```

### 4. Data files

#### 4.1 _data/topics.json

```
{
  "rust": {
    "label": { "en": "Rust", "es": "Rust" },
    "dark": "#fe8019",
    "light_text": "#af3a03",
    "light_bar": "#af3a03"
  },
  "databases": {
    "label": { "en": "Databases", "es": "Bases de datos" },
    "dark": "#83a598",
    "light_text": "#076678",
    "light_bar": "#076678"
  }
}
```

The real file has the six topics of the Design document, section 2.3. A tag used by a post but absent here fails validation. Extra tags that should not show as topics (like interpreters) are listed with "hidden": true and no colours.

#### 4.2 _data/projects.json

```
{
  "schema_version": 1,
  "projects": [
    {
      "id": "tiny-lisp",
      "featured": true,
      "type": "tool",                       // tool | hpc | hackathon
      "status": "active",                   // active | maintained | finished | archived
      "title": "tiny-lisp",
      "description": {
        "en": "A small Lisp interpreter in Rust, the project behind the Building a Lisp posts.",
        "es": "Un intérprete de Lisp pequeño en Rust, el proyecto detrás de los posts sobre Lisp."
      },
      "stack": ["Rust"],
      "links": {
        "codeberg": "https://codeberg.org/Strinix/tiny-lisp",
        "github": "https://github.com/Juanma-Her/tiny-lisp",
        "writeup": "tiny-lisp",            // a post ref, optional
        "demo": null                        // left out when there is none
      },
      "terminal": {                         // optional, featured project only
        "command": "cargo run --release",
        "output": "λ> (fact 10)\n3628800"
      },
      "year": 2026
    }
  ]
}
```

Rules:

- Exactly one project has featured: true.
- links.codeberg and links.github are each optional, but every project MUST have at least one of them, or links.team for a hackathon project whose code lives in a team account. The page shows a button only for the links present, Codeberg first. Most projects have only links.codeberg.
- links.writeup is a post ref; the card links to the version in the page's language, or the other language if that is the only one.
- Order on the page: featured first, then by year descending, then by title.
- The demo: null in the example only shows the field; real files leave it out.

#### 4.3 _data/about.json

```
{
  "schema_version": 1,
  "profile": {
    "photo": "/assets/img/profile.webp",
    "photo_alt": { "en": "Juan Martín Hernández", "es": "Juan Martín Hernández" },
    "role": { "en": "Student and developer", "es": "Estudiante y desarrollador" },
    "details": [
      { "key": "based", "value": { "en": "[City, Country]", "es": "[Ciudad, País]" } },
      { "key": "writes", "value": { "en": "Rust, Go, databases", "es": "Rust, Go, bases de datos" } },
      { "key": "editor", "value": { "en": "Neovim", "es": "Neovim" } },
      { "key": "team", "value": { "en": "[University] HPC", "es": "HPC de [Universidad]" } }
    ]
  },
  "headline": { "en": "I build systems and write down what I learn.", "es": "Armo sistemas y escribo lo que aprendo." },
  "intro": { "en": "Markdown text.", "es": "Texto en Markdown." },
  "experience": [
    {
      "start": "2025-03",
      "end": null,                          // null means "present"; the only place null is allowed
      "title": { "en": "Member, HPC team", "es": "Integrante, equipo de HPC" },
      "org": "[University]",
      "summary": { "en": "One sentence.", "es": "Una oración." }
    }
  ],
  "elsewhere": [
    {
      "kind": "talk",                       // talk | article | podcast
      "title": "Title of the talk",
      "venue": "Event name",
      "date": "2026-05",
      "url": "https://example.org"
    }
  ],
  "competitions": {
    "team": {
      "name": "[University] HPC team",
      "summary": { "en": "One or two sentences.", "es": "Una o dos oraciones." },
      "url": "https://example.org"          // optional
    },
    "entries": [
      {
        "kind": "scc",                      // scc | hackathon
        "event": "SC26 Student Cluster Competition",
        "date": "2026-11",
        "role": { "en": "Team member", "es": "Integrante" },
        "result": { "en": "Finalist", "es": "Finalista" },   // optional
        "url": "https://example.org"        // optional
      }
    ],
    "interested_subject": { "en": "Hackathon team", "es": "Equipo para hackathon" }
  },
  "skills": [
    { "label": "Rust", "topic": "rust" },
    { "label": "Slurm", "topic": "hpc" },
    { "label": "Docker" }
  ]
}
```

- details[].key is a string key in i18n (about.details.based, and so on), so the labels are translated too.
- headline is plain text and becomes the page's h1; intro (paragraphs) and summary accept inline Markdown.
- skills[].topic is optional; when present the tag takes that topic's colour.

#### 4.4 _data/i18n/en.json and es.json

Both files have exactly the same keys; CI fails if one has a key the other lacks.

```
{
  "nav": { "posts": "Posts", "projects": "Projects", "about": "About", "rss": "RSS", "main_label": "Main" },
  "theme": { "to_light": "Switch to light theme", "to_dark": "Switch to dark theme" },
  "lang_switch": { "label": "Language", "only_in": "Only in English" },
  "post": {
    "read_time": "{n} min read",
    "updated": "Updated {date}",
    "edit_github": "Edit on GitHub",
    "spotted_mistake": "Spotted a mistake?",
    "previous": "Previous",
    "next": "Next",
    "more_on": "More on {topic}",
    "copy": "Copy",
    "copied": "Copied"
  },
  "comments": {
    "heading": "Comments",
    "intro": "Comments live in this repo's GitHub Discussions. Sign in with GitHub to join in.",
    "no_js": "Comments need JavaScript. You can also read and reply on GitHub."
  },
  "archive": {
    "heading": "All posts",
    "search_label": "Search posts",
    "search_placeholder": "Search titles, tags and summaries…",
    "all": "All",
    "no_results": "No posts match.",
    "clear": "Clear filters",
    "results": "{n} posts"
  },
  "footer": { "hosted": "Hosted on GitHub Pages", "code_licence": "Code: GPL-3.0", "content_licence": "Posts: CC BY-SA 4.0" },
  "date": { "format": "%b %-d, %Y", "months": ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"] }
}
```

The real files hold every string of the six pages. {n}, {date} and {topic} are placeholders the t filter fills (section 7.2). In es.json, lang_switch.only_in is "Solo en español".

### 5. Site configuration

The keys this project adds to _config.yml, beyond Jekyll's own:

```
title: "~/strinix"
url: "https://strinix.com.ar"
author:
  name: "Juan Martín Hernández"
email: "contact@strinix.com.ar"
languages: ["en", "es"]
default_lang: "en"
timezone: "America/Argentina/Buenos_Aires"
future: false
words_per_minute: 200
home_cards: 6
more_on_count: 3          # not related_posts: Jekyll reserves site.related_posts
feed_limit: 20
forges:
  github:   { user: "Juanma-Her", repo: "blog", branch: "main" }
  codeberg: { user: "Strinix",    repo: "blog", branch: "main" }
giscus:
  repo: "Juanma-Her/blog"
  repo_id: "R_..."
  category: "Comments"
  category_id: "DIC_..."
  mapping: "specific"            # data-term is post:<ref>, shared by both languages
kramdown:
  math_engine: katex
licence:
  code: "GPL-3.0-or-later"
  content: "CC BY-SA 4.0"
defaults:
  - scope: { path: "_posts/en" }
    values: { lang: "en", layout: "post", permalink: "/posts/:title/" }
  - scope: { path: "_posts/es" }
    values: { lang: "es", layout: "post", permalink: "/es/posts/:title/" }
  - scope: { path: "es" }
    values: { lang: "es" }
  - scope: { path: "" }
    values: { lang: "en" }
```

repo_id and category_id come from giscus.app after enabling Discussions (BLG-32).

### 6. Browser-side contracts

#### 6.1 Theme

| **Item** | **Value** |
|---|---|
| Storage key | localStorage["theme"] |
| Stored values | "dark" or "light"; anything else is ignored and removed |
| Attribute | &lt;html data-theme="dark"> or "light"; absent when nothing is stored, and then the system theme applies |
| Toggle | &lt;button id="theme-toggle" type="button" aria-label="..."> in the header |
| Event | document.dispatchEvent(new CustomEvent("themechange", { detail: { theme } })) |

#### 6.2 Filterable lists

Home cards, archive rows and project cards share one contract, so one script handles all three.

```
<div data-filter-root data-filter-param="topic">
  <input type="search" data-filter-search>                 <!-- archive only -->
  <div role="group" data-filter-chips>
    <button type="button" data-filter-value="" aria-pressed="true">All</button>
    <button type="button" data-filter-value="rust" aria-pressed="false">Rust</button>
  </div>
  <section data-filter-group>                               <!-- a year; hidden when empty -->
    <article data-filter-item
             data-filter-key="rust interpreters"
             data-filter-text="writing a tiny lisp interpreter in rust tokenize parse evaluate">
    </article>
  </section>
  <p data-filter-empty hidden>No posts match.</p>
  <p data-filter-status aria-live="polite" class="visually-hidden"></p>
</div>
```

- data-filter-key lists the item's tags (or the project type), space-separated.
- data-filter-text is the title, tags and summary, lower-cased with accents removed at build time; the script normalises the query the same way.
- An item shows when its key contains the selected chip value (empty means all) and its text contains every word of the query.
- data-filter-param names the URL parameter for the chip (topic or type); the query uses q.

#### 6.3 Code figure

```
<figure class="code" data-file="src/lexer.rs">
  <figcaption>src/lexer.rs <button type="button" class="copy" data-copy>Copy</button></figcaption>
  <div class="highlight"><pre><code class="language-rust">…</code></pre></div>
</figure>
```

Without data-file the caption shows only the language name. copy.js copies the text of code, swaps the label to the copied string for 2 seconds, and announces it through aria-live.

#### 6.4 giscus

```
<section id="comments" data-giscus
         data-repo="Juanma-Her/blog" data-repo-id="R_..."
         data-category="Comments" data-category-id="DIC_..."
         data-mapping="specific" data-term="post:tiny-lisp" data-lang="es"
         data-theme-dark="gruvbox_dark" data-theme-light="gruvbox_light">
  <noscript><a href="https://github.com/Juanma-Her/blog/discussions">…</a></noscript>
</section>
```

Theme update message sent by comments.js:

```
{ "giscus": { "setConfig": { "theme": "gruvbox_light" } } }
```

#### 6.5 Atom entry

```
<entry xml:lang="en">
  <title>Writing a tiny Lisp interpreter in Rust</title>
  <link href="https://strinix.com.ar/posts/tiny-lisp-in-rust/" rel="alternate" type="text/html"/>
  <link href="https://strinix.com.ar/es/posts/un-lisp-pequeno-en-rust/" rel="alternate" hreflang="es"/>
  <id>https://strinix.com.ar/posts/tiny-lisp-in-rust/</id>
  <published>2026-11-14T00:00:00-03:00</published>
  <updated>2026-11-14T00:00:00-03:00</updated>
  <summary>Tokenize, parse, evaluate: a working interpreter in about 200 lines.</summary>
  <category term="rust" label="Rust"/>
  <content type="html">…</content>
</entry>
```

The feed itself has title, subtitle, link rel="self", link rel="alternate", id, updated, author with the author's name, and rights with "CC BY-SA 4.0". The hreflang link appears only when a translation exists.

### 7. Include and filter interfaces

#### 7.1 Includes

| **Include** | **Parameters** | **Output** |
|---|---|---|
| post-card.html | post (required) | Card with topic bar, topic, title, summary, date, read time |
| hero.html | post (required) | Home hero; code panel when post.hero_code exists |
| topic.html | tag (required), style: "label", "bar" or "pill" | Topic in its colour, with text |
| chips.html | values (array of keys), labels (map), param ("topic" or "type") | Filter chip group with "All" |
| archive-row.html | post (required) | Row with date, title, topic, read time, summary and filter attributes |
| forge-links.html | path (optional), links (optional: a project's links object; without it, the blog's own forges from site.forges), style: "buttons", "links" or "list", kind: "source", "edit" or "profile" | Codeberg then GitHub, each only when it has a URL; with path they point at that file |
| project-card.html | project (required), featured (boolean) | Project card or featured panel |
| lang-switch.html | none (reads page) | Globe menu button and menu; the other-language item is disabled when there is no translation |
| comments.html | none (reads page and site.giscus) | giscus section or nothing when page.comments is false |
| icon.html | name (required), size (default 18) | Inline SVG with aria-hidden="true" |

#### 7.2 Filters

| **Filter** | **Input** | **Arguments** | **Output** | **Error** |
|---|---|---|---|---|
| t | string key, e.g. "post.read_time" | lang, then optional n, date, topic | Translated string with placeholders filled | Missing key: build fails in production, [key] in development |
| localize | Localized object or plain string | lang | The string for that language | Missing language: build fails |
| read_minutes | rendered HTML | none | Integer, at least 1 | none |
| filter_text | string | none | Lower-case, accents removed, single spaces | none |
| topic_color | tag | theme, role ("text" or "bar") | Hex colour | Unknown tag: build fails |

### 8. Errors from validation

scripts/validate.rb prints one line per problem and exits with 1 if any. Format:

```
_posts/es/2026-11-14-un-lisp-pequeno-en-rust.md: tags[0] "rustlang" is not a topic in _data/topics.json
_data/projects.json: projects[2] needs links.codeberg, links.github or links.team
_data/i18n/es.json: key "archive.clear" missing (present in en.json)
```

| **Check** | **Message pattern** |
|---|---|
| Schema violation | &lt;file>: &lt;json pointer> &lt;reason> |
| Unknown tag | &lt;file>: tags[i] "&lt;tag>" is not a topic in _data/topics.json |
| Duplicate translation | ref "&lt;ref>" has two posts in "&lt;lang>": &lt;file>, &lt;file> |
| Featured count | _data/projects.json: exactly one featured project required, found &lt;n> |
| String keys differ | _data/i18n/&lt;lang>.json: key "&lt;key>" missing (present in &lt;other>.json) |
| Language mismatch | &lt;file>: lang "&lt;x>" does not match folder "&lt;y>" |
