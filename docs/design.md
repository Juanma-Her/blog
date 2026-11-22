# Design document

> Snapshot of the planning document as of 2026-11-22 (launch). Not updated after that.

## Design document: strinix.com.ar (v1)

*2026-11-21*

**Status: M0 to M2 are implemented. The table below shows each area and the ticket that builds it.**

**Inputs:** the Plan and Specification tabs, and the design canvas (private) with the landing, post, archive, projects, about and RSS feed pages in dark and light.

**Language:** this document is in English; code identifiers, file names, JSON keys and CSS tokens are in English; site text exists in English and Spanish.

#### Legend

| **Mark** | **Meaning** |
|---|---|
| Decided | Decided by Juan Martín |
| Assumption | Holds until someone changes it (section 14) |
| Later | Outside v1; an extension if time allows |

#### Implementation status

| **Area** | **Status** | **Ticket** |
|---|---|---|
| Accounts, DNS, repository, mirror, language switch design | Done | BLG-01 to BLG-06 |
| Jekyll skeleton, config, pinned versions | Done | BLG-10 |
| Colour tokens, fonts, base CSS | Done | BLG-11 |
| Theme toggle | Done | BLG-12 |
| Base layout, header, footer | Done | BLG-13, BLG-14 |
| Languages and string files | Done | BLG-15 |
| Home, post, archive, projects, about layouts | Done | BLG-20 to BLG-24 |
| Code blocks and highlighting | Done | BLG-30 |
| Math (KaTeX) | Done | BLG-35 |
| Archive and card filters | Done | BLG-31 |
| Comments | Done | BLG-32 |
| Feeds and feed page | Done | BLG-33, BLG-34 |
| Content validation and CI checks | Done | BLG-04, BLG-50 |
| Full-text search, series, Open Graph images, scheduled rebuild | Later | BLG-60 to BLG-63 |

### 1. Core and parameters

#### 1.1 Constants

They live in _config.yml under site.\* and are the only source used by layouts, plugins and scripts.

| **Key** | **Value** | **Use** |
|---|---|---|
| title | "~/strinix" | Logo text, page titles, feed title |
| author.name | Juan Martín Hernández | Footer, about page, feed author, meta tags |
| url | https://strinix.com.ar | Canonical URLs, feeds, sitemap |
| baseurl | "" | Site served at the domain root |
| languages | ["en", "es"] | Supported languages, first is the default |
| default_lang | en | Language at the root |
| forges.github | { user: Juanma-Her, repo: blog, branch: main } | Source and edit links, giscus |
| forges.codeberg | { user: Strinix, repo: blog, branch: main } | Source and edit links |
| email | "contact@strinix.com.ar" | mailto: links on About |
| words_per_minute | 200 | Read time |
| home_cards | 6 | Cards under the hero |
| more_on_count | 3 | "More on &lt;topic>" band |
| feed_limit | 20 | Entries per feed |
| giscus | repo, repo_id, category, category_id, mapping: specific (term from the post's ref) | Comment box (section 11) |
| licence.code | GPL-3.0-or-later | Footer, README |
| licence.content | CC BY-SA 4.0 | Footer, feeds |
| future | false | Future-dated posts are not built |
| timezone | America/Argentina/Buenos_Aires | Post dates |

#### 1.2 Principles

- **Static first.** Everything a reader needs is in the HTML at build time. JavaScript only adds conveniences: toggles, filters, copy, comments.
- **One source per fact.** Colours are tokens, strings are in _data/i18n/, settings in _config.yml, projects in _data/projects.json. A layout never repeats a value.
- **Both themes, both languages, always.** No page, component or string is merged without its other theme and its other language.
- **Each project's forges.** A project links to the forges it is on: Codeberg, GitHub or both, always in that order. Profile links and this blog's own source links show both.
- **No tracking.** No analytics, no third-party fonts, no third-party scripts except giscus on post pages after the reader scrolls to it.
- **Fail the build, not the page. Invalid content stops CI with a clear message instead of rendering a broken page.**
- **Simple, readable, maintainable. The smallest code that does the job, named and laid out so it reads without comments. No abstraction, plugin, flag or placeholder code until something needs it (empty folders with .gitkeep are fine: they show the structure). When two designs work, pick the one with less code.**

#### 1.3 Execution model

- **Build time:** Jekyll reads Markdown, data files and layouts and writes _site/. Custom plugins in _plugins/ add language helpers, tag feeds and the read-time filter. This runs on the author's machine for previews and in GitHub Actions for deploys.
- **Run time:** the browser receives static HTML, one CSS file and up to four small ES modules. There is no server code.

### 2. Information architecture

#### 2.1 Routes

| **Page** | **English** | **Spanish** | **Layout** | **Source file** |
|---|---|---|---|---|
| Home | / | /es/ | home | index.html, es/index.html |
| Post | /posts/&lt;slug>/ | /es/posts/&lt;slug>/ | post | _posts/en/YYYY-MM-DD-&lt;slug>.md, _posts/es/... |
| Archive | /posts/ | /es/posts/ | archive | posts.html, es/posts.html |
| Projects | /projects/ | /es/projects/ | projects | projects.html, es/projects.html |
| About | /about/ | /es/about/ | about | about.html, es/about.html |
| Feed page | /feed/ | /es/feed/ | feed | feed.html, es/feed.html |
| Feed (Atom) | /feed.xml | /es/feed.xml | none (Liquid XML) | feed.xml, es/feed.xml |
| Tag feed | /feed/by_tag/&lt;tag>.xml | /es/feed/by_tag/&lt;tag>.xml | generated | _plugins/feeds.rb |
| Not found | /404.html | same file, both languages | base | 404.html |
| Sitemap | /sitemap.xml | same file | jekyll-sitemap | generated |

- Slugs come from the file name. A Spanish post can use a Spanish slug; the translation link uses ref, not the slug.
- Pages per language are thin files: front matter with layout, lang and ref, and no body. The layout does the work. Their tab title and meta description come from pages.&lt;ref>.title and pages.&lt;ref>.description in the string files (PageTitles in i18n.rb); the home pages are titled just "~/strinix". _config.yml has no site-wide description, so nothing English leaks into Spanish pages.

#### 2.2 Languages and translations

- **Language of a page:** page.lang, set by front matter defaults: everything under _posts/es/ and es/ is es, everything else en.
- **Strings:** {{ site.data.i18n[page.lang].nav.posts }} or, shorter, through the t filter (section 9.1). Both string files have exactly the same keys; CI compares them.
- **Translation lookup:** a plugin builds a map ref to { en: url, es: url } once per build (site.data.translations is not used; the plugin exposes page.translations). Pages with the same ref are translations of each other.
- **Language switch: a globe menu in the header. The button shows a globe, the current language code (EN or ES) and a chevron; it opens a small menu listing "English" and "Español" by full name, with a check on the current one. The other language links to page.translations[other] if it exists; otherwise, on a post, that item is disabled with a note in that language ("This post isn't translated" or "Este post no está traducido"), and on any other page it links to that language's home. The menu is a &lt;details> element (disclosure pattern), so it opens without JavaScript and needs no ARIA menu roles; lang-switch.js closes it on Escape and on a click outside, and arrow keys move between the links.**
- **Lists come from the posts_for filter. Home, archive and the related band show the posts of page.lang plus English posts that have no translation into it yet, marked with an "EN" badge ("Solo en inglés" for screen readers); once the translation exists (same ref) it replaces the English post. English pages list English posts only. Previous and next, and the feeds, contain only posts of page.lang.**
- **Dates** are formatted per language: "Nov 14, 2026" and "14 nov 2026".
- **hreflang:** each page with a translation emits &lt;link rel="alternate" hreflang="en|es"> for both and x-default pointing to the English one.

#### 2.3 Topics

Topics are tags with a colour and a translated label, defined in _data/topics.json. A post's first tag is its primary topic: it gives the card bar colour, the breadcrumb and the "More on" band. Further tags only affect search and tag feeds.

| **tag** | **Label EN / ES** | **Dark** | **Light text** | **Light bar** |
|---|---|---|---|---|
| rust | Rust / Rust | #fe8019 | #af3a03 | #af3a03 |
| cpp | C/C++ / C/C++ | #83a598 | #076678 | #076678 |
| homelab | Homelab / Homelab | #b496d6 | #6a4c93 | #6a4c93 |
| tooling | Tooling / Herramientas | #b8bb26 | #504945 | #79740e |
| python | Python / Python | #fabd2f | #504945 | #b57614 |
| hpc | HPC / HPC | #d3869b | #8f3f71 | #8f3f71 |

A post whose tag is not in topics.json fails validation, so every topic has both colours and both labels.

### 3. Identifiers, types and formats

#### 3.1 Identifiers

| **Name** | **Type** | **Meaning** | **Example** |
|---|---|---|---|
| slug | string, lowercase, hyphens | Last part of a post URL, from the file name | tiny-lisp-in-rust |
| ref | string, lowercase, hyphens | Translation key shared by both versions of a post or page | tiny-lisp |
| lang | "en" or "es" | Language of a page | es |
| tag | string, lowercase, hyphens | Topic or extra tag | databases |
| project id | string, lowercase, hyphens | Key of a project in projects.json | tiny-lisp |
| theme | "dark" or "light" | Theme in use | dark |
| ticket | BLG-NN | Ticket identifier | BLG-21 |

#### 3.2 Formats

- Dates in front matter: YYYY-MM-DD or YYYY-MM-DD HH:MM:SS -0300. Dates in feeds: RFC 3339.
- Read time: ceil(words / 200), minimum 1, computed by the read_minutes filter from the rendered content without code blocks counted twice.
- Colours: hex #rrggbb, lowercase.
- JSON: two-space indentation, keys in snake_case, no trailing commas, UTF-8.
- Text that exists in both languages is a **Localized** object: { "en": "...", "es": "..." }. Both keys are required.

### 4. Visual system

#### 4.1 Colour tokens

Defined once in assets/css/_tokens.css as custom properties on :root, each written as light-dark(&lt;light>, &lt;dark>). color-scheme picks the value: data-theme when the reader has chosen, the system setting otherwise (also with JavaScript off). Components use only tokens.

| **Token** | **Dark** | **Light** | **Used for** |
|---|---|---|---|
| --bg | #282828 | #fbf1c7 | Page background |
| --panel | #1d2021 | #f2e5bc | Hero, featured project, HPC card, feed box, related band |
| --card | #32302f | #f9f5d7 | Cards, inputs |
| --code-bg | #1d2021 | #f9f5d7 | Code blocks |
| --inset-bg | #282828 | #f9f5d7 | Code panels inside a panel: home hero code, projects terminal |
| --border | #3c3836 | #d5c4a1 | Dividers, card borders |
| --border-strong | #504945 | #bdae93 | Buttons, chips |
| --border-dashed | #665c54 | #a89984 | "More on Codeberg and GitHub" card, feed note |
| --text | #ebdbb2 | #3c3836 | Body text, headings |
| --text-2 | #bdae93 | #504945 | Summaries, secondary text |
| --meta | #a89984 | #665c54 | Dates, read time, footer |
| --accent | #fabd2f | #af3a03 | Links, buttons, current nav item |
| --on-accent | #1d2021 | #fbf1c7 | Text on accent buttons |
| --chip-active-bg | #ebdbb2 | #3c3836 | Selected filter chip |
| --chip-active-text | #1d2021 | #fbf1c7 | Selected filter chip text |
| --note | #83a598 | #076678 | Note callout border and icon |
| --inline-code | #8ec07c on #1d2021 | #076678 on #f2e5bc (--inline-code on --inline-code-bg) | Inline code |

The canvas offers other accents (orange, aqua and blue in dark; blue, plum and red in light). v1 ships the defaults above; changing the accent is a token edit.

#### 4.2 Syntax colours

Rouge emits CSS classes; assets/css/_syntax.css maps them to tokens per theme.

| **Rouge classes** | **Role** | **Dark** | **Light** |
|---|---|---|---|
| .k, .kd, .kn | Keywords | #fb4934 | #9d0006 |
| .nf, .s, .s1, .s2 | Functions and strings | #b8bb26 | #427b58 |
| .nb, .o, .na | Built-ins, operators, attributes | #83a598 | #076678 |
| .kt, .nc | Types | #fe8019 | #af3a03 |
| .m, .mi, .mf | Numbers | #d3869b | #8f3f71 |
| .c, .c1, .cm | Comments, italic | #928374 | #665c54 |

#### 4.3 Typography and layout

- Headings Space Grotesk 500 and 700; body Inter 400, 500 and 600; code and meta JetBrains Mono 400 and 500. Self-hosted WOFF2 in assets/fonts/, Latin and Latin Extended subsets, font-display: swap.
- Body 16 px, line height 1.6. Post text 18 px, line height 1.75, filling the post column.
- Page container 1200 px with 24 px side padding (16 px below 480 px). Post pages 860 px, centred; archive and feed pages 960 px.
- Radii: 8 px buttons, 12 px cards and code, 16 px panels, 999 px chips.
- Every interactive element is at least 44 by 44 px.

#### 4.4 Components

| **Component** | **Include** | **Used on** |
|---|---|---|
| Header with nav, language switch and theme toggle | header.html | All pages |
| Footer | footer.html | All pages |
| Post card | post-card.html | Home, related band |
| Hero | hero.html | Home |
| Topic label and bar | topic.html | Cards, archive rows, breadcrumb |
| Filter chips | chips.html | Home, archive, projects |
| Archive row | archive-row.html | Archive, feed page |
| Code figure | generated by code_figure.rb hook | Posts |
| Note callout | CSS on blockquote.note | Posts |
| Forge links | forge-links.html | Home, post, projects, about |
| Project card | project-card.html | Projects |
| Comment box | comments.html | Post |
| Language switch | lang-switch.html | Header |

### 5. Theme switching

#### 5.1 Behaviour

1. An inline script in &lt;head>, before the stylesheet, reads localStorage["theme"]. If it is dark or light it sets &lt;html data-theme> to it; otherwise it does nothing.
1. Without a stored choice (and without JavaScript) &lt;html> has no data-theme, and the light-dark() tokens follow the system theme on their own (4.1).
1. The toggle switches data-theme, stores the new value, updates its own label and icon, and sends the new theme to the giscus iframe (section 11).
1. With nothing stored, the CSS follows OS changes live; theme.js only listens to relabel the button and send themechange. After the first click the stored value wins.
1. The transition of background and colour lasts 150 ms and is disabled under prefers-reduced-motion: reduce.

#### 5.2 Why inline

The script is 136 bytes and blocks rendering on purpose: running it before the first paint is what prevents the wrong theme flashing (RF-03). Everything else is deferred.

### 6. Pages

#### 6.1 Home

Hero with the newest post of the language: topic pill "Latest", topic, date, read time, title, summary, "Read the post", and the hero_code panel if the post has one. Below, "Recent posts" with topic chips and six cards, a "Browse the archive" button, and "Follow along" with Subscribe via RSS, Codeberg and GitHub.

#### 6.2 Post

Breadcrumb "Posts / &lt;topic>" · clock icon · read time; title; author line with the date; body; "Spotted a mistake?" with Edit on GitHub; previous and next cards; comments; "More on &lt;topic>" band. No series box and no table of contents in v1.

Edit link (GitHub only, because Codeberg is a read-only mirror: an edit proposed there would be overwritten):

- GitHub: https://github.com/Juanma-Her/blog/edit/main/&lt;page.path>

The README says changes go through GitHub (section 7.3).

Math: TeX between $$ delimiters (JSON contracts 3.3) becomes KaTeX HTML at build time, so formulas read with JavaScript off. Every post page links assets/katex/katex.min.css. Formulas use the theme's text colour (currentColor), so they need no per-theme styles. KaTeX's output includes MathML, so screen readers get the formula too. Feeds carry each formula as its TeX source in code (inline code, or a code block for display math), because many feed readers strip MathML and none load KaTeX's CSS; code blocks in feeds are plain, with the file name above them. A display formula wider than the column scrolls inside its own block, like code.

#### 6.3 Archive

"All posts" heading, search box with the / hint, topic chips, and the posts grouped by year. The current year heading uses the accent colour; older years use --meta. Each row: date column, title, topic and read time on the right, summary below.

Every row carries the data the filter needs (contract in JSON contracts and interfaces, section 6.2). The filter script hides rows and empty years; it never fetches anything.

#### 6.4 Projects

Header, featured project panel (type, stack, status chips, title, description, buttons for the project's forges (Codeberg, GitHub or both), write-up link, optional terminal excerpt), "All projects" with type chips, the cards, and the dashed card "More on Codeberg and GitHub" with both profile links.

#### 6.5 About

Two-column row that stacks on narrow screens: the profile card (fixed width, centred when stacked) and the intro with the experience timeline. Then full-width sections in this order: Talks and writing elsewhere; Competitions and hackathons (HPC team card, SCC rows, hackathon rows, "Putting together a hackathon team? I'm interested"); Things I work with; Say hello. No CV button.

#### 6.6 Feed page

The RSS link in the header opens /feed/ (or /es/feed/), a normal page with the feed layout: the RSS feed page design with the feed address and a copy button, "What is RSS?", the latest entries, and the note about per-tag feeds. The address shown is the Atom file, /feed.xml or /es/feed.xml, which is what feed readers use.

feed.xml is not styled with an XSLT stylesheet: Chrome is removing XSLT support, so a styled XML view would break for most readers. The Atom files stay plain XML. (A17, confirmed.)

#### 6.7 404

One 404.html for both languages, from the 404 design on the canvas (option B of four). Base layout with the normal header and footer. Left: a large "404" in the accent colour with the middle zero in a muted tone; it scales down on narrow screens (clamp 120 to 200 px). Right: "Page not found", one sentence in English, "Go home" (primary) and "Browse posts" buttons, then a dashed box in Spanish ("¿Buscabas algo en español?") linking to /es/. No JavaScript. The page is served with status 404.

### 7. Build, deploy and mirror

#### 7.1 Workflow

One workflow, .github/workflows/deploy.yml, runs on push to main and by hand; it also builds pull requests without deploying, though the project does not use them (Tickets, Conventions).

| **Job** | **Steps** | **Blocks deploy** |
|---|---|---|
| build | Checkout; ruby/setup-ruby with bundler cache; bundle exec ruby scripts/validate.rb; JEKYLL_ENV=production bundle exec jekyll build; bundle exec htmlproofer ./_site --disable-external; upload Pages artifact | Yes |
| deploy | actions/deploy-pages to the github-pages environment; only on main | Yes |
| mirror | Push main and tags to Codeberg with a token; runs after deploy; failure does not undo the deploy | No |

#### 7.2 Domain

- DNS at Cloudflare, every record DNS only (grey cloud) so GitHub can issue and renew the certificate: CNAME @ → juanma-her.github.io (Cloudflare flattens it at the apex), and CNAME www → juanma-her.github.io. GitHub redirects www to the apex.
- Pages settings: custom domain strinix.com.ar, "Enforce HTTPS" on.
- GitHub account settings: verify strinix.com.ar so no other account can claim the domain or its subdomains.
- A CNAME file is not needed with Actions deploys; it is kept anyway as documentation.

#### 7.3 Mirror

GitHub is the only place where pushes are made. The mirror job does:

```
git push --force https://Strinix:${CODEBERG_TOKEN}@codeberg.org/Strinix/blog.git HEAD:main
git push --force --tags https://Strinix:${CODEBERG_TOKEN}@codeberg.org/Strinix/blog.git
```

- It pushes main and tags only, not --mirror, so pull request references on Codeberg are not deleted.
- CODEBERG_TOKEN is a Codeberg access token with repository write scope, stored as an Actions secret.
- Alternative if this fails: a Codeberg pull mirror of the GitHub repository (Assumption; check Codeberg's current policy on mirrors in BLG-05).

### 8. Repository, components and dependencies

#### 8.1 Repository structure

```
blog/
├── _config.yml               # constants (1.1); source: src
├── Gemfile, Gemfile.lock     # pinned gems
├── .ruby-version
├── LICENSE                   # GPL-3.0-or-later
├── LICENSE-content           # CC BY-SA 4.0
├── README.md
├── .github/workflows/deploy.yml
├── schemas/                  # JSON Schemas (JSON contracts tab)
├── scripts/validate.rb       # content and feed checks (13.1)
├── docs/                     # this document exported, decisions log
└── src/                      # Jekyll source: everything that becomes the website (built into _site/, not tracked)
    ├── CNAME
    ├── _data/
    │   ├── i18n/en.json, es.json # interface strings
    │   ├── topics.json
    │   ├── projects.json
    │   └── about.json
    ├── _includes/            # components (4.4)
    ├── _layouts/             # base, home, post, archive, projects, about, feed, atom.xml
    ├── _plugins/
    │   ├── i18n.rb           # translations map, t, localize, localize_date, posts_for
    │   ├── read_time.rb      # read_minutes filter
    │   ├── filter_text.rb    # normalised text for the list filters
    │   ├── code_figure.rb    # code figure: file name and copy button
    │   ├── post_markup.rb    # heading anchors, note label
    │   ├── math_check.rb     # fails the build on TeX errors and unclosed $$
    │   └── feeds.rb          # tag feed pages, feed_html filter
    ├── _posts/en/, _posts/es/
    ├── _drafts/
    ├── assets/
    │   ├── css/              # main.css joins _fonts, _tokens, _base, _components, _syntax
    │   ├── js/               # theme.js, lang-switch.js, filter.js, copy.js, comments.js
    │   ├── fonts/
    │   ├── katex/            # katex.min.css and fonts, copied from the katex gem
    │   └── img/
    └── pages/                # index, posts, projects, about, feed (.html), feed.xml, 404.html
        └── es/               # Spanish page stubs and feed
Paths elsewhere in this document that name site files (_posts/, _data/, _layouts/, page stubs) are relative to src/.
```

#### 8.2 Components

| **Component** | **Responsibility** | **Location** | **Ticket** |
|---|---|---|---|
| Config | Constants | _config.yml | BLG-10 |
| Tokens and base CSS | Colours, type, layout | assets/css/ | BLG-11 |
| Theme script | Theme state and toggle | inline in head.html, assets/js/theme.js | BLG-12 |
| Base layout | Document skeleton, head, header, footer | _layouts/base.html | BLG-13, BLG-14 |
| Language plugin | Defaults, translation map, t | _plugins/i18n.rb | BLG-15 |
| Page layouts | One per page type | _layouts/\*.html | BLG-20 to BLG-24 |
| Code figure | File name, copy button target | _plugins/code_figure.rb, assets/js/copy.js | BLG-30 |
| Math | TeX to KaTeX HTML at build time; KaTeX CSS and fonts | _config.yml (kramdown math_engine), assets/katex/ | BLG-35 |
| Filters | Search and chips | assets/js/filter.js | BLG-31 |
| Comments | giscus loader and theme sync | _includes/comments.html, assets/js/comments.js | BLG-32 |
| Feeds | Language and tag feeds, feed page | feed.xml, es/feed.xml, _plugins/feeds.rb, _layouts/feed.html | BLG-33, BLG-34 |
| Validator | Schemas against content | scripts/validate.rb | BLG-50 |

#### 8.3 Dependency rules

- Layouts read settings only from site.\*, strings only through t, colours only through tokens.
- JavaScript modules do not import each other, except that theme.js dispatches a themechange event that comments.js listens to.
- No Node toolchain beyond the runtime KaTeX needs: no package.json and no npm packages. The katex gem runs KaTeX through ExecJS, which uses the Node already on GitHub's Ubuntu runners (locally, any Node install). CSS is plain files concatenated by Jekyll includes; JavaScript is native ES modules loaded with type="module" and defer by default.
- Gems: jekyll 4.x, jekyll-seo-tag, jekyll-sitemap, html-proofer, json_schemer, kramdown-math-katex (pulls in katex and execjs). Nothing else without updating this list.

### 9. Interfaces inside the site

#### 9.1 Liquid includes and filters

Every include takes named parameters and reads nothing global except site and page. Signatures are in JSON contracts and interfaces, section 7.

- t filter: {{ "nav.posts" | t: page.lang }}. A missing key fails the build in production and shows [nav.posts] in development.
- read_minutes filter: {{ content | read_minutes }}.
- localize filter: picks the right key from a Localized object, {{ project.description | localize: page.lang }}.

#### 9.2 JavaScript modules

| **Module** | **Loaded on** | **Does** | **Public surface** |
|---|---|---|---|
| inline theme script | Every page, in head | Sets data-theme before first paint | none |
| theme.js | Every page | Toggle button, OS listener, storage | Dispatches themechange on document with { theme } |
| filter.js | Home, archive, projects | Search box, chips, URL state | Reads data-filter-\* attributes; no exports |
| copy.js | Posts | Copy buttons on code figures | none |
| comments.js | Posts | Loads giscus when the box is near the viewport; syncs theme | Listens to themechange |

### 10. Feeds

- feed.xml and es/feed.xml are Liquid templates producing Atom 1.0, served as plain XML.
- tag_feeds.rb generates one page per tag and language from the same template, with the tag's posts only.
- Entry content is the full post HTML, with relative URLs made absolute.
- id of an entry is the post's absolute URL; changing a slug creates a new entry, so slugs are not changed after publishing.
- The feed page's "What's in the feed" list uses the same post list as the feed (latest posts of the language), so the two stay in sync.

### 11. Comments

- giscus with data-mapping="specific" and data-term="post:&lt;ref>": both language versions of a post share one discussion, so a comment on either shows on both (Decided, A10). The giscus interface still follows the page's language. Changing a post's ref after it has comments detaches them: the old discussion stays on GitHub but no page shows it, so validate.rb treats ref as permanent once published.
- data-lang is en or es. data-theme is gruvbox_dark or gruvbox_light, giscus built-in themes.
- data-loading="lazy" and the script is injected by comments.js only when the comment section is within 600 px of the viewport, so readers who never scroll there make no request to giscus.
- On themechange, comments.js posts { giscus: { setConfig: { theme } } } to the iframe.
- The box says "Comments live in this repo's GitHub Discussions. Sign in with GitHub to join in." Without JavaScript it shows a link to the discussions page instead. Post-level reactions are off (data-reactions-enabled="0"); comments keep their own reactions. data-strict="1" so giscus only matches the exact term. The giscus frame gets no outer focus ring; giscus draws its own inside. Math in comments ($...$ and $$...$$) renders once the comment is posted; giscus's Preview tab shows it as TeX text.
- Setup: enable Discussions on Juanma-Her/blog, install the giscus app, create an "Announcements"-type category "Comments", and copy the IDs into _config.yml (BLG-32).

### 12. Accessibility and performance

- Landmarks: header, nav[aria-label], main, footer; one h1 per page.
- Skip link "Skip to content" or "Saltar al contenido" as the first focusable element.
- Focus ring: 2 px --accent outline with 2 px offset, on every interactive element.
- Filter chips are button elements with aria-pressed; the result count is announced in an aria-live="polite" region.
- The theme toggle is a button with aria-label; the icon has aria-hidden.
- Images have width, height and loading="lazy" below the fold. The about photo has meaningful alt text.
- CSS is one file under 25 KB, plus KaTeX's katex.min.css (about 23 KB) on post pages; KaTeX fonts download only when a formula uses them; fonts are preloaded only for Inter 400 and Space Grotesk 700.
- Contrast was checked for every token pair in both themes during design; the light theme uses darker text variants for green, yellow and aqua for that reason.

### 13. Testing strategy

#### 13.1 Automatic checks (CI)

| **Area** | **Where** | **What it checks** | **Ticket** |
|---|---|---|---|
| Content | scripts/validate.rb | Every post's front matter and every data file against schemas/; tags exist in topics.json; one featured project; both string files have the same keys; every ref has at most one post per language | BLG-50 |
| Build | jekyll build | Liquid errors, missing includes, missing string keys in production | BLG-10 |
| Links | htmlproofer | Internal links, images, anchors, hreflang targets | BLG-50 |
| Feeds | scripts/validate.rb --feeds | Every language and tag feed in _site parses as XML and has entries (BLG-50) | BLG-33 |
| Math | _plugins/math_check.rb (during the build) | A production build fails, naming the post, on a KaTeX error or an unclosed $$ in the Markdown | BLG-35 |

#### 13.2 Manual checks (BLG-51)

- [ ] Each page in both themes and both languages at 320, 768 and 1280 px.
- [ ] Theme toggle: no flash on reload; choice survives navigation; OS change followed only before the first click.
- [ ] Keyboard only: every page usable, focus always visible, / focuses archive search.
- [ ] JavaScript off: every page readable, theme follows the system.
- [ ] Language switch on a translated and an untranslated post.
- [ ] Copy button on a code block, comment box in both themes.
- [ ] Inline and display math on a post: both themes, JavaScript off, and a screen reader reads the formula.
- [ ] The RSS link opens the feed page; its address imports into a feed reader; both feeds pass the W3C validator.
- [ ] Lighthouse mobile: performance 95 or more, accessibility 100, on home and a long post.
- [ ] Result of the BLG-51 pass (2026-11-22): every item above checked on the live site; details and known exceptions are in the BLG-51 ticket.
- [ ] Network panel: no third-party request before scrolling to comments.

### 14. Assumed values to confirm

| **#** | **Item** | **Assumed value** | **Who confirms** |
|---|---|---|---|
| A1 | Site name | "~/strinix" (confirmed) | Juan Martín |
| A2 | Contact email | contact@strinix.com.ar (confirmed; Cloudflare Email Routing forwards it to a private inbox) | Juan Martín |
| A3 | Repository name | blog on both forges (confirmed) | Juan Martín |
| A4 | Data file format | JSON with JSON Schema (confirmed) | Juan Martín |
| A5 | Archive search | Filters rows on the page; no index | Juan Martín |
| A6 | Fonts | Self-hosted, Latin and Latin Extended | Juan Martín |
| A7 | Words per minute | 200 for both languages | Juan Martín |
| A8 | Cards on home | 6 | Juan Martín |
| A9 | Feed format and size | Atom, 20 entries, full content | Juan Martín |
| A10 | Comment threads | Changed: one per post, shared by both languages (giscus mapping specific, term post:&lt;ref>) | Juan Martín |
| A11 | Mirror method | Push from CI with a token; pull mirror as fallback | Juan Martín |
| A12 | Timezone | America/Argentina/Buenos_Aires | Juan Martín |
| A13 | Accent colours | Yellow #fabd2f dark, rust #af3a03 light | Juan Martín |
| A14 | Language switch in the header | Globe menu (option C) next to the theme toggle; on all 12 canvas designs | Juan Martín |
| A15 | Hero code panel | Optional hero_code in front matter | Juan Martín |
| A16 | Post date format | "Nov 14, 2026" and "14 nov 2026" | Juan Martín |
| A17 | Feed page | HTML page at /feed/; no XSLT on feed.xml (confirmed) | Juan Martín |
| A18 | Math syntax | kramdown's: $$...$$ inside a sentence for inline math, on its own lines for display math; a single $ is plain text | Juan Martín |

### 15. Known problems, risks and debt

| **#** | **Problem** | **Detail** | **Mitigation** |
|---|---|---|---|
| 1 | Edits on Codeberg do not flow back | The mirror is overwritten from GitHub | README explains it; fixes proposed on Codeberg are applied on GitHub by hand |
| 2 | Comments need GitHub | Readers without a GitHub account cannot comment | Say hello by email is on every About page; accepted for v1 |
| 3 | Search is not full-text | Only titles, tags and summaries match | Summaries are required; full-text search is extension BLG-60 |
| 4 | Future posts need a build | A post dated tomorrow appears only after the next build | Extension BLG-63 adds a daily scheduled build |
| 5 | Untranslated posts are invisible in the other language | A Spanish reader does not see English-only posts in lists | Decided (D3); the header still links to the other language's home |
| 6 | Feed XML is unstyled in a browser | Someone who opens /feed.xml directly sees raw XML | The site never links to the XML for humans; the RSS link goes to /feed/ |
| 7 | Language switch not designed | The canvas header has no EN · ES control | Resolved: added to all 12 designs (BLG-06) |
| 8 | 404 not designed | Resolved: designed on the canvas in both themes | Built in BLG-34 from the 404 design |
| 9 | Site name unknown | Resolved: the name is ~/strinix | One config value; change before launch |
| 10 | Building needs Node | The katex gem runs KaTeX through ExecJS, which needs a JavaScript runtime | GitHub's Ubuntu runners include Node; the README tells anyone building locally to install Node |
