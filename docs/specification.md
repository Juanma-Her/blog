# Specification

> Snapshot of the planning document as of 2026-11-22 (launch). Not updated after that.

## Software specification: strinix.com.ar

*2026-11-21*

### 1. Purpose and scope

strinix.com.ar is a static, bilingual dev blog. It publishes posts, a projects page and an about page in a dark and a light Gruvbox theme, and offers RSS feeds. It is built with Jekyll by GitHub Actions and served by GitHub Pages.

This document states **what** the system must do. **How** is in the Design document, data formats are in JSON contracts and interfaces, and the work is in Tickets. MUST, MUST NOT and MAY mark obligation, prohibition and option.

**In scope (v1):**

- Six page types (home, post, archive, projects, about, feed) in English and Spanish, each in both themes.
- A theme toggle that remembers the visitor's choice.
- Posts in one or both languages, with read time, code blocks with copy button, LaTeX math rendered with KaTeX, previous and next links and comments.
- Archive with search over titles, tags and summaries, and topic filters.
- Atom feeds per language and per tag, and a feed page that explains how to subscribe.
- Each project links to the forges it is on: Codeberg, GitHub or both. This blog's own repository: GitHub main, Codeberg mirror.
- CI that builds, validates content and checks links before deploying.

**Out of scope (v1):** full-text search, a newsletter, analytics of any kind, a CV download, post series, tag pages, a CMS or editor, comments without a GitHub account, a third language, and a downloadable PDF of posts.

**Actors:**

| **Actor** | **Who** | **What they do with the system** |
|---|---|---|
| Reader | Anyone who opens the site, including recruiters and hackathon organisers | Reads posts, switches theme and language, filters the archive, subscribes, comments, contacts |
| Author | Juan Martín Hernández | Writes posts and data files, previews locally, pushes to publish |
| CI | GitHub Actions | Builds, validates, deploys and mirrors on each push |
| Contributor | A reader who spots a mistake | Opens the post's source on Codeberg or GitHub and proposes a fix |

### 2. Design decisions

The first eleven are decided. The rest are assumptions that hold until someone changes them (full list in section 14 of the Design document).

| **#** | **Topic** | **Decision** | **Origin** |
|---|---|---|---|
| D1 | Generator | Jekyll 4, built by a GitHub Actions workflow and deployed to GitHub Pages | Decided |
| D2 | Languages | English at the site root, Spanish under /es/ | Decided |
| D3 | Translations | Optional per post. Lists show only the current language; on a post without a translation the language switch is shown disabled with "Only in English" or "Solo en español" | Decided |
| D4 | Comments | giscus, stored in GitHub Discussions of the main repository; one thread per post, shared by its English and Spanish versions | Decided |
| D5 | Domain | strinix.com.ar, custom domain on GitHub Pages, HTTPS enforced | Decided |
| D6 | Projects data | Hand-written data file, both languages in one file | Decided |
| D7 | Forges | Projects live on Codeberg (Strinix), GitHub (Juanma-Her) or both; each shows buttons only for the forges it is on, Codeberg first. This blog's own repository is on GitHub with a Codeberg mirror, so its source links show both | Decided |
| D8 | Licences | Code under GPL-3.0-or-later; posts and other written content under CC BY-SA 4.0 | Decided |
| D9 | CV | No CV button or file in v1 | Decided |
| D10 | Theme | Follows prefers-color-scheme until the reader presses the toggle; the choice is stored in the browser | Decided |
| D11 | Documents | Documents in English; code identifiers in English; site text in both languages | Decided |
| D12 | Data file format | JSON, validated with JSON Schema (confirmed) | Assumption |
| D13 | Search | Filters the archive rows already on the page; no search index | Assumption |
| D14 | Fonts | Self-hosted WOFF2; no requests to Google Fonts | Assumption |
| D15 | Site name | ~/strinix, set in one config value (title); logo in JetBrains Mono with "~/" in the accent colour | Assumption |
| D16 | Repository name | blog on both forges: Juanma-Her/blog and Strinix/blog (confirmed) | Assumption |
| D17 | Math | LaTeX math in posts, rendered with KaTeX at build time by kramdown's math engine; KaTeX's CSS loads on every post page | Decided |

### 3. Glossary

| **Term** | **Meaning** |
|---|---|
| Post | One article in one language: a Markdown file in _posts/en/ or _posts/es/ |
| Translation | Two posts with the same ref in different languages |
| ref | Translation key shared by the versions of a post, for example tiny-lisp |
| Topic | A tag with its own colour and label, defined in _data/topics.json. A post's first tag is its primary topic |
| Summary | The one-sentence description of a post; shown in cards, the archive and feeds |
| Theme | Dark or light; the set of colour tokens in use |
| Accent | The highlight colour of a theme: yellow #fabd2f in dark, rust #af3a03 in light |
| Forge | Codeberg or GitHub |
| Main repository | github.com/Juanma-Her/blog, where pushes go and the site is built |
| Mirror | codeberg.org/Strinix/blog, updated by CI after each deploy |
| Fixture | Sample posts and data in _posts/ and _data/ used to build pages before real content exists; replaced in M4 |

### 4. Use cases

| **ID** | **Actor** | **Use case** | **Main flow** | **Result** |
|---|---|---|---|---|
| UC-01 | Reader | Read a post | Opens a post from home, archive or a feed | Title, read time, date, body with highlighted code, previous and next, comments |
| UC-02 | Reader | Switch theme | Presses the sun or moon button in the header | Page switches theme instantly; the choice holds on every page and visit |
| UC-03 | Reader | Switch language | Opens the globe menu in the header and picks the other language | Same page in the other language; on a post, its translation |
| UC-04 | Reader | Find a post | Opens the archive, types in the search box or picks a topic | Only matching rows remain; year headings without rows hide |
| UC-05 | Reader | Subscribe | Presses RSS, copies the feed address from the feed page | The address works in a feed reader |
| UC-06 | Reader | Comment | Signs in with GitHub in the comment box and writes | Comment appears under the post and in GitHub Discussions |
| UC-07 | Reader | Look at projects | Opens Projects, filters by type | Featured project and cards with links to each project's forges |
| UC-08 | Reader | Contact the author | Presses "Say hello" or "I'm interested" on About | The mail app opens with the address and a subject filled in |
| UC-09 | Contributor | Fix a mistake | Presses "Edit on GitHub" on a post | GitHub's editor opens on that post's source file |
| UC-10 | Author | Publish a post | Adds a Markdown file, previews with bundle exec jekyll serve, pushes | CI validates, builds and deploys; the post is online within minutes |
| UC-11 | Author | Translate a post | Adds a file in the other language with the same ref | Both versions link to each other; the language switch on the post becomes active |
| UC-12 | Author | Add a project | Edits _data/projects.json and pushes | The card appears on Projects in both languages |

Alternative flows:

- **UC-01a, JavaScript off:** the post reads normally, the theme follows the system, the copy buttons and the comment box are absent, and a line links to the discussion on GitHub.
- **UC-03a, no translation: in the globe menu the other language is disabled, labelled "Only in English" or "Solo en español".** The header link to the other language's home stays available.
- **UC-04a, nothing matches:** the archive shows "No posts match" or "No hay posts que coincidan" and a button to clear the filters.
- **UC-10a, invalid front matter:** CI fails with the file name and the field; nothing is deployed.

### 5. Functional requirements

Priority: M = must have for launch; S = should have; C = could have if time allows.

#### 5.1 Layout, theme and language

| **ID** | **Requirement** | **Acceptance criteria** | **Priority** |
|---|---|---|---|
| RF-01 | Every page MUST have the header from the designs: site name, Posts, Projects, About, RSS, language switch and theme toggle | Present on all six page types in both languages | M |
| RF-02 | The theme MUST follow prefers-color-scheme until the reader presses the toggle, and then use the stored choice | With nothing stored, changing the OS setting changes the site; after a click, the OS setting no longer changes it | M |
| RF-03 | The page MUST NOT flash the wrong theme while loading | No visible change of background on reload with a stored choice that differs from the OS | M |
| RF-04 | The toggle MUST show a sun in dark mode and a moon in light mode, with an accessible label naming the theme it switches to | Screen reader announces "Switch to light theme" or "Switch to dark theme", translated | M |
| RF-05 | Every page MUST exist in English at the root and in Spanish under /es/, with lang set on &lt;html> and hreflang alternates | Both URLs return 200; &lt;html lang> is en or es; alternates point to each other | M |
| RF-06 | All interface text MUST come from the string files, never be written in a layout | Grep of _layouts/ and _includes/ finds no visible English or Spanish sentence outside _data/i18n/ | M |
| RF-07 | The language switch MUST lead to the equivalent page; on a post without translation it MUST be disabled with "Only in English" or "Solo en español" | Checked on a translated and an untranslated post | M |
| RF-08 | The footer MUST show the copyright, both licences, and "Hosted on GitHub Pages" | Present on every page in both languages | M |

#### 5.2 Home

| **ID** | **Requirement** | **Acceptance criteria** | **Priority** |
|---|---|---|---|
| RF-10 | The home page MUST show the latest post of the current language as the hero, with topic, date, read time, summary and a "Read the post" button | Hero changes when a newer post is added | M |
| RF-11 | The hero MAY show a code excerpt set in the post's front matter (hero_code); without it the hero is text only | A post without hero_code renders a hero with no code panel | S |
| RF-12 | The home page MUST show the next six posts of the current language as cards with topic bar, topic, title, summary, date and read time | Six cards, newest first, hero not repeated | M |
| RF-13 | Topic chips on home MUST filter the cards and include "All" | Picking Rust shows only Rust cards; "All" restores them | S |
| RF-14 | The "Follow along" section MUST link to the feed of the current language, to Codeberg and to GitHub | Three links, each opens the right target | M |

#### 5.3 Post

| **ID** | **Requirement** | **Acceptance criteria** | **Priority** |
|---|---|---|---|
| RF-20 | A post page MUST show the breadcrumb (Posts / topic), read time, title, author and date, in that order above the body | Matches the post design | M |
| RF-21 | Read time MUST be words divided by 200, rounded up, at least 1 | A 2,350-word post shows "12 min read" | M |
| RF-22 | Code blocks MUST be highlighted at build time in the Gruvbox colours of the current theme and MAY show a file name | Colours change with the theme without a reload | M |
| RF-22a | Posts MUST support LaTeX math, inline and display, rendered to HTML by KaTeX at build time | $$e^{i\\pi}+1=0$$ inside a sentence renders inline and on its own lines renders as a centred block; formulas show with JavaScript off and in both themes | M |
| RF-23 | Every code block MUST have a copy button that copies the code without line numbers and confirms with "Copied" | Pasting gives the exact code | S |
| RF-24 | A post MUST support the note callout from the design | A blockquote marked {: .note} renders as the blue note | S |
| RF-25 | A post MUST show an "Edit on GitHub" link to its source file (not Codeberg: it is a mirror) | The link opens the file on main | M |
| RF-26 | A post MUST show previous and next posts of the same language | First and last posts show only one side | M |
| RF-27 | A post MUST show the giscus comment box below previous and next, in the theme and language of the page | Toggling the theme changes the comment box without a reload | M |
| RF-28 | A post MUST show up to three more posts with the same primary topic and language ("More on Rust") | Hidden when there are none | S |
| RF-29 | A post without translation MUST NOT link to a missing page | No 404 from any language link | M |

#### 5.4 Archive

| **ID** | **Requirement** | **Acceptance criteria** | **Priority** |
|---|---|---|---|
| RF-30 | The archive MUST list every post of the current language, grouped by year, newest first, with date, title, topic, read time and summary | Count matches the number of posts of that language | M |
| RF-31 | The search box MUST filter rows by title, tags and summary as the reader types, ignoring case and accents | "busqueda" finds "búsqueda" | S |
| RF-32 | Topic chips MUST filter rows; chips and search MUST combine | Rust plus "lisp" shows only Rust rows containing "lisp" | S |
| RF-33 | Pressing / MUST focus the search box unless the reader is typing in a field | Works on the archive page only | C |
| RF-34 | Filter state MUST be reflected in the URL (?q= and ?topic=) so a filtered archive can be shared | Opening the URL restores the filter | C |

#### 5.5 Projects

| **ID** | **Requirement** | **Acceptance criteria** | **Priority** |
|---|---|---|---|
| RF-40 | The projects page MUST show the featured project with type, stack, status, description, a button for each forge the project is on (Codeberg, GitHub or both, Codeberg first) and an optional write-up link | Exactly one project has featured: true; CI fails otherwise | M |
| RF-41 | It MUST show the other projects as cards with type, status, title, description, stack, and Codeberg, GitHub, write-up and demo links where present | A Codeberg-only project shows no GitHub link; a project without a demo shows no demo link | M |
| RF-42 | Type chips (All, Tools, HPC, Hackathons) MUST filter the cards | Same behaviour as RF-13 | S |
| RF-43 | The last card MUST link to the author's Codeberg and GitHub profiles | Both links present | M |

#### 5.6 About

| **ID** | **Requirement** | **Acceptance criteria** | **Priority** |
|---|---|---|---|
| RF-50 | The about page MUST show the profile card (photo, name, role, details, links to Codeberg, GitHub, email and RSS) and MUST NOT show a CV button | Matches the About design without the CV button | M |
| RF-51 | It MUST show the intro and the experience timeline from _data/about.json | Entries in date order, newest first | M |
| RF-52 | It MUST show, in this order: Talks and writing elsewhere, Competitions and hackathons, Things I work with, Say hello | Order matches the design | M |
| RF-53 | "I'm interested" in Competitions MUST open a mailto: link with the subject "Hackathon team" (translated) | Mail app opens with address and subject | M |
| RF-54 | "Say hello" MUST open a mailto: link | Mail app opens | M |

#### 5.7 Feeds

| **ID** | **Requirement** | **Acceptance criteria** | **Priority** |
|---|---|---|---|
| RF-60 | The site MUST publish an Atom feed per language: /feed.xml (English) and /es/feed.xml (Spanish), with the 20 latest posts | Both validate at validator.w3.org/feed | M |
| RF-61 | Each feed entry MUST have title, link, date, summary, primary topic and full content | Entry opens the right post | M |
| RF-62 | The site MUST publish a feed per tag and language: /feed/by_tag/&lt;tag>.xml and /es/feed/by_tag/&lt;tag>.xml | One file per tag in use in that language | S |
| RF-63 | The RSS link MUST open an HTML feed page at /feed/ and /es/feed/ with the RSS feed page design: feed address with copy button, reader links, what's in the feed, per-tag note | Page renders in both themes; the copied address imports into a feed reader | M |
| RF-64 | Every page MUST advertise its language's feed with &lt;link rel="alternate" type="application/atom+xml"> | Feed readers find it from the home page URL | M |

#### 5.8 Publishing

| **ID** | **Requirement** | **Acceptance criteria** | **Priority** |
|---|---|---|---|
| RF-70 | A push to main MUST build and deploy the site only if every check passes | A broken front matter blocks the deploy | M |
| RF-71 | CI MUST validate front matter of every post and every data file against their schemas | Error names the file and the field | M |
| RF-72 | CI MUST check internal links and images of the built site | A broken internal link fails the build | M |
| RF-73 | After a successful deploy CI MUST push main and tags to the Codeberg mirror | Codeberg shows the same commit within 5 minutes | M |
| RF-74 | Drafts in _drafts/ MUST NOT be published, and posts dated in the future MUST NOT appear until a build after their date | future: false in production | M |
| RF-75 | The site MAY be rebuilt once a day by a scheduled workflow, so future-dated posts appear on their day | Cron job present | C |

### 6. Non-functional requirements

| **ID** | **Category** | **Requirement** | **How it is checked** |
|---|---|---|---|
| RNF-01 | Performance | Lighthouse performance 95 or more on home and on a long post, mobile profile | Lighthouse run before launch (BLG-51) |
| RNF-02 | Weight | A post page without comments MUST weigh under 150 KB transferred, fonts included | DevTools network panel |
| RNF-03 | Privacy | No request to a third party on any page except giscus on post pages, and giscus loads only when the comment box scrolls into view | DevTools network panel; grep of built HTML for external hosts |
| RNF-04 | Privacy | No analytics, cookies or tracking pixels | Review of _includes/head.html |
| RNF-05 | Accessibility | WCAG 2.2 AA: contrast 4.5:1 for text, targets 44 by 44 px, visible focus, keyboard reachable, landmarks | Lighthouse accessibility 100 and a keyboard pass (BLG-51) |
| RNF-06 | Accessibility | Nothing is conveyed by colour alone; topics always have a text label | Review against the designs |
| RNF-07 | Progressive enhancement | Every page MUST be readable with JavaScript off; only toggles, filters, copy and comments need it | Browse with JavaScript disabled |
| RNF-08 | Motion | Theme change and hover effects MUST respect prefers-reduced-motion | Toggle the OS setting |
| RNF-09 | Responsive | Layouts MUST work from 320 px to 1440 px wide with no horizontal scroll | Responsive mode at 320, 768, 1280 |
| RNF-10 | Reproducibility | Ruby and gem versions MUST be pinned (.ruby-version, Gemfile.lock) | Clean build on a new machine matches CI |
| RNF-11 | Security | No secrets in the repository; the Codeberg token lives in an Actions secret | Review before making the repository public |
| RNF-12 | Security | HTTPS enforced; the custom domain verified in GitHub account settings | Pages settings page |
| RNF-13 | SEO | Each page has a unique title and description, canonical URL, Open Graph tags and is in the sitemap | View source; /sitemap.xml |
| RNF-14 | Licensing | Code under GPL-3.0-or-later (LICENSE); content under CC BY-SA 4.0 (LICENSE-content); third-party font licences included | Files present; footer names both |
| RNF-15 | Maintainability | No JavaScript framework and no npm packages; plain CSS and small ES modules. Node is used only as the runtime that renders KaTeX during the build | Repository has no package.json dependency for the build |
| RNF-16 | Language | Interface fully translated; no English text on Spanish pages except code and proper names | Review of every page under /es/ |

### 7. Definition of done and traceability

The launch is done when every M requirement is met and:

- [ ] strinix.com.ar opens over HTTPS from a private window, and UC-01 to UC-09 work in both languages and both themes.
- [ ] CI is green on main and the Codeberg mirror shows the same commit.
- [ ] Lighthouse: performance 95 or more, accessibility 100 on home and on a post.
- [ ] Two real posts, one with a translation.
- [ ] Projects and about contain real data.
- [ ] The repository is public with README.md, LICENSE and LICENSE-content.

Every requirement has at least one ticket:

| **Requirements** | **Tickets** |
|---|---|
| RF-01, RF-08 | BLG-13, BLG-14 |
| RF-02 to RF-04 | BLG-12 |
| RF-05 to RF-07, RF-29 | BLG-15 |
| RF-10 to RF-14 | BLG-20 |
| RF-20, RF-21, RF-25, RF-26 | BLG-21 |
| RF-22 to RF-24 | BLG-30 |
| RF-22a | BLG-35 |
| RF-27 | BLG-32 |
| RF-28 | BLG-21 |
| RF-30 | BLG-22 |
| RF-31 to RF-34 | BLG-31 |
| RF-40 to RF-43 | BLG-23 |
| RF-50 to RF-54 | BLG-24, BLG-40 |
| RF-60 to RF-62, RF-64 | BLG-33 |
| RF-63 | BLG-34 |
| RF-01, RF-07 (design) | BLG-06 |
| RF-70 to RF-72, RF-74 | BLG-04, BLG-50 |
| RF-73 | BLG-05 |
| RF-75 | BLG-63 |
| RNF-01 to RNF-09 | BLG-51 |
| RNF-10, RNF-15 | BLG-10 |
| RNF-11, RNF-12 | BLG-02, BLG-52 |
| RNF-13 | BLG-14 |
| RNF-14 | BLG-52 |
| RNF-16 | BLG-15, BLG-51 |
