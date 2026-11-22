# Tickets

> Snapshot of the planning document as of 2026-11-22 (launch). Not updated after that.

## Tickets by milestone

*2026-11-21*

### Conventions

There are 31 tickets in six milestones, plus 4 extensions. Each has an estimate, dependencies and acceptance criteria; status is updated in each milestone's table.

- **Identifier:** BLG-NN. 01 to 06 setup; 10 to 15 foundation; 20 to 24 pages; 30 to 35 features; 40 to 43 content; 50 to 53 launch; 60 to 63 extensions.
- **Owner:** Juan Martín for every ticket.
- **Done means: acceptance criteria met, pushed to main, CI green,** and checked in both themes and both languages when the ticket touches a page.
- **No pull requests: work is solo, so each ticket is one commit pushed straight to main after a clean local build. The workflow deploys only when the build passes, so a broken commit never reaches the site. A branch is used only for an experiment that might be thrown away.**
- **Blocked:** if a ticket takes twice its estimate, apply the cut written in the ticket and note it in the ticket.
- **Sample content first: until M4, pages are built from sample posts in _posts/ and sample data in _data/, copied from the examples in JSON contracts and interfaces. M4 replaces them with real content.**

#### Hours per milestone

| **Milestone** | **Tickets** | **Hours** |
|---|---|---|
| M0 Setup | BLG-01 to BLG-06 | 5 |
| M1 Foundation | BLG-10 to BLG-15 | 12 |
| M2 Pages | BLG-20 to BLG-24 | 17.5 |
| M3 Features | BLG-30 to BLG-35 | 15.5 |
| M4 Content | BLG-40 to BLG-43 | 10.5 |
| M5 Launch | BLG-50 to BLG-53 | 7 |
| Total |  | 67.5 |

#### Milestone gates

| **End of** | **Must work** | **If not** |
|---|---|---|
| M0 | https://strinix.com.ar shows a placeholder page over HTTPS, deployed by Actions, mirrored on Codeberg | Keep the github.io address and move on; DNS can finish in parallel |
| M1 | An empty page in both themes and both languages with the real header and footer | Drop the OS listener (RF-02 second half) and the disabled language switch state until M5 |
| M2 | All six page types from fixtures | Ship About without the timeline component first; projects without chips |
| M3 | Code, math, filters, comments, feeds | Cut in this order: archive URL state, / shortcut, tag feeds, home chips |

### M0 Setup: accounts, domain, repository

No site code yet: accounts, DNS, an empty deployed page and the mirror.

| **ID** | **Ticket** | **Hours** | **Depends on** | **Status** |
|---|---|---|---|---|
| BLG-01 | Accounts and access | 0.5 | — | Done |
| BLG-02 | DNS and custom domain | 1 | BLG-04 | Done |
| BLG-03 | Confirm assumptions | 0.5 | — | Done |
| BLG-04 | Repository and deploy workflow | 1.5 | BLG-01 | Done |
| BLG-05 | Codeberg mirror | 1 | BLG-04 | Done |
| BLG-06 | Language switch on the designs | 0.5 | — | Done |

#### BLG-01 · Accounts and access

Given that the build, the mirror and the comments depend on three services, when Juan Martín checks the GitHub and Codeberg accounts and creates the Codeberg token, then nothing later is blocked by a missing login or permission.

**Technical notes:**

- GitHub Juanma-Her: two-factor authentication on; permission to create repositories and enable Pages.
- Codeberg Strinix: access token with repository write scope, named blog-mirror. Keep it only in a password manager until BLG-05.
- Access to the DNS panel of strinix.com.ar.

**Acceptance criteria:**

- Both accounts can create a repository.
- The Codeberg token exists and is stored outside the repository.
- The Cloudflare DNS panel for strinix.com.ar opens.

#### BLG-02 · DNS and custom domain

Given that the blog lives at strinix.com.ar, when Juan Martín points the domain at GitHub Pages and sets the custom domain, then the site is served at that address over HTTPS, and no other GitHub account can claim it.

**Technical notes:**

- DNS at Cloudflare, DNS only (grey cloud): CNAME @ → juanma-her.github.io (flattened at the apex) and CNAME www → juanma-her.github.io. (Design document 7.2).
- GitHub account settings → Pages → verified domains: add strinix.com.ar with the TXT record GitHub asks for.
- Repository settings → Pages: custom domain strinix.com.ar, then "Enforce HTTPS" once the certificate is issued (can take up to an hour).
- Add a CNAME file with strinix.com.ar.

**Acceptance criteria:**

- dig strinix.com.ar A returns the four GitHub Pages addresses, and https://www.strinix.com.ar redirects to https://strinix.com.ar.
- The domain shows as verified in account settings.
- http://strinix.com.ar redirects to https://, and the certificate is valid.

#### BLG-03 · Confirm assumptions

Given that the Design document lists 17 assumptions (A1 to A17), when Juan Martín reads section 14 and confirms or changes each one, then M1 starts with no open question that changes the code.

**Technical notes:**

- The ones that change code: A1 site name (confirmed: ~/strinix), A2 email (confirmed: contact@strinix.com.ar), A3 repository name, A4 JSON data files (confirmed), A10 comment threads (changed: one per post, shared by both languages), A17 feed page (confirmed).
- Write the result into the table and change the Specification's D-table where needed.

**Acceptance criteria:**

- Every row of section 14 is marked confirmed or changed.
- A2 has a real address, or a decision to launch without email.

#### BLG-04 · Repository and deploy workflow

Given that every later ticket is merged through CI, when Juan Martín creates Juanma-Her/blog with a placeholder page and the deploy workflow, then pushes to main deploy to GitHub Pages and pull requests run the build without deploying.

**Technical notes:**

- Public or private to start; it must be public before launch (BLG-52).
- Pages source: "GitHub Actions".
- .github/workflows/deploy.yml with the build and deploy jobs of Design document 7.1; the validation and link-check steps are added in BLG-50.
- Gemfile with jekyll 4.x, .ruby-version, Gemfile.lock committed.
- index.html with one line of text.

**Acceptance criteria:**

- A push to main deploys in under 3 minutes.
- A pull request runs the build job and not the deploy job.
- The Pages URL shows the placeholder.

#### BLG-05 · Codeberg mirror

Given that this blog's own source links show GitHub and Codeberg, when Juan Martín creates Strinix/blog and adds the mirror job, then Codeberg receives main and tags after every deploy.

**Technical notes:**

- Create Strinix/blog empty on Codeberg, with a description that says it is a mirror and points to GitHub.
- Actions secret CODEBERG_TOKEN with the token from BLG-01.
- Mirror job as in Design document 7.3: push HEAD:main and --tags, never --mirror; continue-on-error: true so it cannot block the deploy.
- Check Codeberg's current rules on mirrors; if pushing from CI is not allowed, set up a pull mirror instead and note it in the Design document (A11).

**Acceptance criteria:**

- After a push, Codeberg shows the same commit hash within 5 minutes.
- The token does not appear in the repository or in logs.
- A failing mirror job leaves the deploy green.

#### BLG-06 · Language switch on the designs

Given that the designs have no language control and the header needs one (Design document, risk 7), when the "EN · ES" control is added to the header of the six designs in both themes, then BLG-13 builds the header from a design instead of improvising.

**Technical notes:**

- Globe menu (option C, chosen from five options on the canvas) left of the theme toggle: globe, current language code and chevron; the menu lists English and Español with a check on the current one.
- Show the open menu with the disabled Español item on the light post design.
- 44 px targets.

**Acceptance criteria:**

- The 12 artboards on the canvas show the control.
- The disabled state is shown on at least one post artboard.

### M1 Foundation: skeleton, theme, languages

At the end, an empty page renders in both themes and both languages with the real header and footer.

| **ID** | **Ticket** | **Hours** | **Depends on** | **Status** |
|---|---|---|---|---|
| BLG-10 | Jekyll config, gems and sample content | 2 | BLG-04 | Done |
| BLG-11 | Colour tokens, fonts and base CSS | 2.5 | BLG-10 | Done |
| BLG-12 | Theme toggle | 1.5 | BLG-11 | Done |
| BLG-13 | Base layout and header | 2 | BLG-11, BLG-06 | Done |
| BLG-14 | Footer, head and SEO | 1 | BLG-13 | Done |
| BLG-15 | Languages: plugin, strings and switch | 3 | BLG-13 | Done |

#### BLG-10 · Jekyll config, gems and sample content

Given that every page needs the same structure and settings, when Juan Martín creates the folder structure of Design document 8.1, the config of JSON contracts 5 and the fixtures, then later tickets add files to known places and build pages from sample content.

**Technical notes:**

- _config.yml with every key of JSON contracts 5 and the front matter defaults. Every folder of Design document 8.1 exists from the start, with a .gitkeep while empty.
- Gems: jekyll-seo-tag, jekyll-sitemap, html-proofer, json_schemer, kramdown-math-katex, versions pinned.
- Sample content: four English posts and two Spanish ones (one translation pair, one Spanish-only) in _posts/, and projects.json and about.json in _data/, copied from the contract examples. topics.json is real from the start.
- No placeholder content: schemas/ stays empty until BLG-50 writes the schemas.

**Acceptance criteria:**

- bundle exec jekyll serve builds with no warnings.
- The fixture posts appear at /posts/&lt;slug>/ and /es/posts/&lt;slug>/.
- site.forges.codeberg.user prints Strinix in a test page.

#### BLG-11 · Colour tokens, fonts and base CSS

Given that every colour in the designs must come from one place, when Juan Martín writes the tokens of Design document 4.1, self-hosts the fonts and writes the base styles, then both themes exist before any component is built.

**Technical notes:**

- _tokens.css: the table of 4.1 as light-dark() values on :root; color-scheme follows data-theme, or the system when it is absent.
- Fonts: variable WOFF2 for Space Grotesk, Inter and JetBrains Mono (all weights in one file each), latin and latin-ext subsets selected by unicode-range; OFL licence files in assets/fonts/. About 110 KB per page.
- _base.css: reset, body, headings, links, focus ring, container widths, .visually-hidden, reduced motion.
- **main.css joins the partials with include_relative into the only stylesheet.**

**Acceptance criteria:**

- A test page with every token as a swatch matches the canvas in both themes.
- No request to fonts.googleapis.com or fonts.gstatic.com.
- Text "Información, año" renders in Inter without fallback glyphs.

#### BLG-12 · Theme toggle

Given that the theme must follow the system until the reader picks one, and never flash, when Juan Martín writes the inline head script and theme.js as in Design document 5 and JSON contracts 6.1, then the toggle works on every page and the choice persists.

**Technical notes:**

- Inline script in head.html before the stylesheet, applying only a stored choice; under 500 bytes (136).
- theme.js: click handler, label and icon swap (sun in dark, moon in light), themechange event, matchMedia listener that relabels the button while nothing is stored. The button is hidden until theme.js runs.
- Wrap localStorage access in try; in a private window without storage the toggle still works for the page.

**Acceptance criteria:**

- Reload with a stored theme that differs from the OS: no flash, recorded with DevTools performance screenshots.
- Before any click, switching the OS theme switches the site; after a click, it does not.
- The button's accessible name is "Switch to light theme" or "Switch to dark theme", and the Spanish strings once BLG-15 lands.

#### BLG-13 · Base layout and header

Given that all pages share a skeleton, when Juan Martín writes base.html and header.html from the designs, then every later layout only fills main.

**Technical notes:**

- Skip link, header with logo (site.title: "~/" in the accent colour and "strinix" in --text, JetBrains Mono 500), nav, language switch slot, theme toggle; main#content; footer slot.
- Current nav item: aria-current="page", outlined in the accent, as on the feed design.
- Header wraps under 480 px as in the designs.

**Acceptance criteria:**

- Header matches the canvas at 1280 and 375 px in both themes.
- Keyboard: skip link first, then logo, nav items, language switch, toggle.
- One h1 per page is left to the page layouts.

#### BLG-14 · Footer, head and SEO

Given that every page needs metadata and the footer from the designs, when Juan Martín writes head.html and footer.html, then pages have correct titles, descriptions, canonical URLs, feed links and licences.

**Technical notes:**

- jekyll-seo-tag for title, description, canonical, Open Graph; jekyll-sitemap.
- &lt;link rel="alternate" type="application/atom+xml"> to the page language's feed (RF-64).
- Footer: "© 2026 Juan Martín Hernández · Code: GPL-3.0 · Posts: CC BY-SA 4.0 · Hosted on GitHub Pages", from strings.
- robots.txt pointing to the sitemap.

**Acceptance criteria:**

- View source on home and a post: title, description, canonical and Open Graph present and different per page.
- /sitemap.xml lists both languages.
- The footer names both licences.

#### BLG-15 · Languages: plugin, strings and switch

Given that every page exists in English and Spanish and posts may exist in one or both, when Juan Martín writes _plugins/i18n.rb, the two string files and the language switch, then layouts get page.lang, page.translations and the t filter, and the switch never links to a missing page.

**Technical notes:**

- Plugin: translation map by ref (Design document 2.2), t and localize filters (JSON contracts 7.2), date formatting per language, hreflang alternates.
- Strings: every string of the six designs into en.json, then es.json. The Spanish copy is written by Juan Martín, not machine-translated.
- lang-switch.html: the globe menu from BLG-06, as a details element that opens without JavaScript; lang-switch.js adds Escape, click outside and arrow keys.
- Spanish page stubs under es/.

**Acceptance criteria:**

- /es/ shows a Spanish header and footer with &lt;html lang="es">.
- On the translated fixture post, the menu links to the other version; on the Spanish-only fixture, the English item is disabled and says "This post isn't translated". The menu works with keyboard only.
- A missing key fails JEKYLL_ENV=production jekyll build.

### M2 Pages: the six layouts from fixtures

Every page type is built from fixtures, in both themes and both languages. No real content yet.

| **ID** | **Ticket** | **Hours** | **Depends on** | **Status** |
|---|---|---|---|---|
| BLG-20 | Home | 3.5 | BLG-15 | Done |
| BLG-21 | Post layout | 4 | BLG-15 | Done |
| BLG-22 | Archive | 2.5 | BLG-20 | Done |
| BLG-23 | Projects | 3.5 | BLG-15 | Done |
| BLG-24 | About | 4 | BLG-15 | Done |

#### BLG-20 · Home

Given that the home page is the first thing a reader sees, when Juan Martín builds the home layout from the landing designs, then it shows the latest post as hero, six cards and the follow section, in the page's language.

**Technical notes:**

- Includes hero.html, post-card.html, topic.html, chips.html (chips render now; filtering comes in BLG-31), forge-links.html.
- read_minutes filter (_plugins/read_time.rb), shared with BLG-21.
- "Follow along": Subscribe via RSS to /feed/ of the language, Codeberg and GitHub profile links.
- Topic colours from topics.json, set by topic.html as light-dark() custom properties (no extra filter).

**Acceptance criteria:**

- / shows English posts only, /es/ Spanish posts only.
- The hero is the newest post; it is not repeated in the cards.
- A fixture post without hero_code gives a hero with no code panel.
- Matches the canvas in both themes at 1280 and 375 px.

#### BLG-21 · Post layout

Given that posts are the core of the blog, when Juan Martín builds the post layout from the post design, then a post shows breadcrumb, read time, title, author line, body, edit links, previous and next, and the related band.

**Technical notes:**

- Breadcrumb "Posts / &lt;topic>" · clock icon · "12 min read" above the title (RF-20, RF-21).
- Body typography for paragraphs, lists, tables, images, blockquotes, inline code; the note callout (blockquote.note).
- "Edit on GitHub" link to github.com/Juanma-Her/blog/edit/main/&lt;page.path> (no Codeberg link: it is a mirror).
- Previous and next within the language; "More on &lt;topic>" with up to three posts.
- Leave the comment slot empty for BLG-32 and plain code blocks for BLG-30.

**Acceptance criteria:**

- The edit link opens the post's source file in GitHub's editor.
- The first and last fixture posts show only "Next" or only "Previous".
- "More on" is hidden when no other post shares the topic.
- Matches the post design in both themes.

#### BLG-22 · Archive

Given that readers look for older posts by year and topic, when Juan Martín builds the archive layout from the archive design, then all posts of the language are listed by year with their summaries and the filter attributes.

**Technical notes:**

- archive-row.html with the attributes of JSON contracts 6.2 (filter_text filter).
- Search box and chips rendered; the script comes in BLG-31.
- Current year heading in the accent; other years in --meta.

**Acceptance criteria:**

- Row count equals the number of fixture posts of the language.
- Years are newest first; rows inside a year newest first.
- data-filter-text is lower-case without accents.

#### BLG-23 · Projects

Given that projects show what Juan Martín builds, when Juan Martín builds the projects layout from the projects design and projects.json, then the featured panel and the cards show, with a link to each forge the project is on.

**Technical notes:**

- project-card.html with featured true or false; forge-links.html with style: "buttons" on the featured panel and "links" on cards.
- Status label with coloured dot and text (never colour alone).
- Write-up link resolves a post ref to the page's language, or the other language with a language badge.
- Last card: "More on Codeberg and GitHub" with both profile links.

**Acceptance criteria:**

- The featured project appears once, in the panel, not again as a card.
- A project without demo shows no demo link.
- Each card shows only its project's forge links: a Codeberg-only fixture shows no GitHub link.

#### BLG-24 · About

Given that the about page is also a portfolio for teams and recruiters, when Juan Martín builds the about layout from the About design and about.json, then the profile card, timeline and the four sections appear in order, without a CV button.

**Technical notes:**

- Profile card: photo, name, role, details list, links Codeberg, GitHub, Email, RSS feed. Fixed width, centred when stacked.
- Experience timeline with "present" for end: null.
- Sections in order: Talks and writing elsewhere; Competitions and hackathons (team card, SCC rows, hackathon rows, "I'm interested" mailto: with the subject from interested_subject); Things I work with; Say hello.
- **Cut:** render the timeline as a plain list if the dot layout takes more than an hour.

**Acceptance criteria:**

- Section order matches RF-52; no CV button.
- "I'm interested" opens the mail app with subject "Hackathon team" or "Equipo para hackathon".
- Profile card does not stretch beyond its width when the row stacks.

### M3 Features: code, math, filters, comments, feeds

| **ID** | **Ticket** | **Hours** | **Depends on** | **Status** |
|---|---|---|---|---|
| BLG-30 | Code blocks | 3 | BLG-21 | Done |
| BLG-31 | Filters and search | 3 | BLG-20, BLG-22, BLG-23 | Done |
| BLG-32 | Comments with giscus | 2 | BLG-21, BLG-12 | Done |
| BLG-33 | Atom feeds | 3 | BLG-15 | Done |
| BLG-34 | Feed page and 404 | 2.5 | BLG-33 | Done |
| BLG-35 | Math with KaTeX | 2 | BLG-21 | Done |

#### BLG-30 · Code blocks

Given that most posts carry code, when Juan Martín adds the syntax colours, the code figure plugin and the copy button, then code reads well in both themes and can be copied in one click.

**Technical notes:**

- _syntax.css from Design document 4.2, as light-dark() values.
- _plugins/code_figure.rb: post-render hook that wraps div.highlight in the figure of JSON contracts 6.3 and reads data-file.
- copy.js: Clipboard API, label swap, aria-live message.
- Long lines scroll horizontally inside the figure, never the page.

**Acceptance criteria:**

- Rust, Go, Python, SQL and shell samples are coloured in both themes; switching theme recolours without reload.
- Pasted text equals the source exactly.
- A 200-character line does not cause page-level horizontal scroll at 320 px.

#### BLG-31 · Filters and search

Given that the archive, home and projects all filter lists, when Juan Martín writes filter.js against the contract in JSON contracts 6.2, then chips and search filter the items on all three pages with one script.

**Technical notes:**

- Normalise the query like filter_text (normalize("NFD") and strip combining marks).
- Hide empty year groups; show the empty message and "Clear filters".
- Update ?q= and ?topic= or ?type= with history.replaceState; read them on load.
- / focuses the search box when focus is not in a field.
- **Cut:** URL state and the / shortcut first.

**Acceptance criteria:**

- "busqueda" matches a summary containing "búsqueda".
- Topic chip and search combine.
- The result count is announced to screen readers.
- Without JavaScript all items are visible and the search box is hidden.

#### BLG-32 · Comments with giscus

Given that readers can discuss posts with a GitHub account, when Juan Martín enables Discussions, installs giscus and writes comments.js, then each post has a comment box in the page's language and theme that loads only when needed.

**Technical notes:**

- Discussions on Juanma-Her/blog; category "Comments" of type Announcements; giscus app installed on the repository only.
- IDs into _config.yml (repo_id, category_id).
- comments.js: IntersectionObserver with 600 px root margin, injects the giscus script with the attributes of JSON contracts 6.4; on themechange posts setConfig.
- noscript link to the discussions page.

**Acceptance criteria:**

- No request to giscus.app before scrolling near the comments.
- A test comment appears on the post and in the repository's Discussions, and on the post's translation too.
- Switching theme updates the comment box without reload.
- The Spanish post shows giscus in Spanish.

#### BLG-33 · Atom feeds

Given that readers subscribe per language and some only want one topic, when Juan Martín writes the feed templates and the tag feed generator, then each language has a feed and each tag a feed per language.

**Technical notes:**

- feed.xml and es/feed.xml producing the Atom of JSON contracts 6.5, feed_limit entries, full content with absolute URLs.
- _plugins/feeds.rb: one page per tag in use per language at /feed/by_tag/&lt;tag>.xml and /es/feed/by_tag/&lt;tag>.xml.
- scripts/validate.rb --feeds parses each feed (moved to BLG-50, since validate.rb arrives there; the math checks were done in BLG-35 as _plugins/math_check.rb; in BLG-33 every feed was parsed at build and the live feeds passed the W3C validator with 0 errors and 0 warnings).

**Acceptance criteria:**

- Both language feeds pass the W3C feed validator.
- The English feed has no Spanish posts and the reverse.
- /feed/by_tag/rust.xml contains only Rust posts.
- A feed reader imports /es/feed.xml and shows titles and summaries.

#### BLG-34 · Feed page and 404

Given that the RSS link opens a page that explains subscribing (Design document 6.6), when Juan Martín builds the feed layout from the RSS feed page design and the 404 page from its design, then readers can copy the feed address and find their way back from a missing page.

**Technical notes:**

- Feed layout: RSS icon, "This is an RSS feed", readonly address input with Copy (reuses copy.js), "What is RSS?" (aboutfeeds.com in English, Spanish Wikipedia in Spanish; the reader suggestions were dropped), latest five entries, per-tag note naming /feed/by_tag/rust.xml and /feed/by_tag/hpc.xml.
- RSS nav item marked current on this page.
- 404.html from the 404 design (Design document 6.7): large 404, "Page not found", Go home and Browse posts buttons, and the Spanish box linking to /es/.

**Acceptance criteria:**

- The copied address is the Atom URL of the page's language.
- The reader links open the reader with the feed pre-filled.
- A missing URL shows the 404 page with status 404.

#### BLG-35 · Math with KaTeX

Given that some posts need formulas (complexity, scaling, numerical methods), when Juan Martín turns on kramdown's KaTeX math engine and self-hosts KaTeX's CSS and fonts, then math in posts renders at build time and reads in both themes with JavaScript off.

**Technical notes:**

- Gemfile: kramdown-math-katex (pulls in katex and execjs), version pinned. _config.yml: kramdown math_engine: katex (JSON contracts 5).
- Done early in BLG-15: katex.min.css (KaTeX 0.17.0) and its WOFF2 fonts are in assets/katex/ and linked on post pages; .katex-display scrolls sideways. The checks were done in BLG-35 itself (see below).
- CSS: display math scrolls horizontally inside .katex-display, never the page; colour inherits from the text.
- _plugins/math_check.rb (instead of validate.rb --math): a production build fails, naming the post, when a formula has a KaTeX error or a $$ is left unclosed. The $$ count reads the Markdown without code and escaped \\$, because kramdown outputs an escaped \\$\\$ and an unclosed $$ the same way. Development builds only warn.
- Add a fixture post with inline and display math.

**Acceptance criteria:**

- Inline and display math render in both themes and with JavaScript off.
- The page makes no request for math to another host.
- A wide formula does not cause page-level horizontal scroll at 320 px.
- A formula with a TeX error fails CI with the post's file name.

### M4 Content: real data and first posts

| **ID** | **Ticket** | **Hours** | **Depends on** | **Status** |
|---|---|---|---|---|
| BLG-40 | About data | 2 | BLG-24 | Done |
| BLG-41 | Projects data | 2 | BLG-23 | Done |
| BLG-42 | First two posts | 6 | BLG-30, BLG-33 | Done |
| BLG-43 | Profile photo | 0.5 | BLG-24 | Done |

#### BLG-40 · About data

Given that the about page is built from about.json, when Juan Martín fills it with real details, then the page shows his real profile, experience, competitions and skills in both languages.

**Technical notes:**

- University, team name, years, SCC events and results, hackathons, talks, skills with topics.
- Remove the fixture about.json.

**Acceptance criteria:**

- about.json validates and contains no placeholder in square brackets.
- Both language versions read naturally.
- Result (2026-11-22): about.json holds the real profile, experience (FaMAF - UNC, Team Carpinchos), competitions (NASA Space Apps Córdoba, CARLA 2026 SCC) and skills; it validates and has no bracket placeholders; the empty elsewhere list hides that section. New topics asm and graphics in topics.json for the skills. Commits 4bb9450, d51ce15.

#### BLG-41 · Projects data

Given that the projects page is built from projects.json, when Juan Martín lists his real projects with the forge links each one has, then the page shows them with the right featured project.

**Technical notes:**

- List each project only under the forges it is really on; most will have only links.codeberg.
- Pick the featured project and write its terminal excerpt.

**Acceptance criteria:**

- projects.json validates; every forge link returns 200.
- Exactly one featured project.
- Result (2026-11-22): projects.json lists strinix (featured, with its QEMU boot terminal), rasterizer, Terra Analog Index and this blog; it validates, exactly one project is featured, and every forge link returns 200. New project types os and graphics (schema, labels in both languages, filter chips, colours that pass contrast). Commit f47fdf4.

#### BLG-42 · First two posts

Given that a blog launches with content, when Juan Martín writes two posts, one of them in both languages, then the site launches with real posts that exercise code blocks, translations and topics.

**Technical notes:**

- One post with code and a file name, a note callout and hero_code.
- Translate one of them; same ref.
- One-sentence description on each.
- **Cut:** launch with one post and its translation.

**Acceptance criteria:**

- Both posts validate and appear on home, archive and the feeds of their language.
- On the translated post the language switch links both ways.
- Result (2026-11-22): launched under the ticket's cut, one post and its translation: "How I (vibe)coded this blog" (ref building-this-blog), with code blocks with file names, a note callout and inline math; no hero_code. Both versions validate, appear on home, the archive and their language's feed, and the language switch links both ways (checked on the live site). Commits 490b16e, a2026f0.

#### BLG-43 · Profile photo

Given that the profile card needs a photo, when Juan Martín adds one, then the about page shows it.

**Technical notes:**

- profile.webp 320 by 320, under 40 KB.

**Acceptance criteria:**

- About shows the photo with alt text.
- Result (2026-11-22): profile.webp is 1200 by 880 (about 178 KB), not 320 by 320 under 40 KB: the profile card became a 380 by 280 landscape box (BLG-24 redesign) and Juan Martín chose the sharper file over the weight target. The about page shows it with alt text in both languages. No social image: Juan Martín decided against one, so link previews show the plain title-and-description card. Also added: an optional competitions.team.logo, used for the Team Carpinchos logo. Commits 9543653, 78a92dc, e1e3e0d.

### M5 Launch: checks, audit, go live

| **ID** | **Ticket** | **Hours** | **Depends on** | **Status** |
|---|---|---|---|---|
| BLG-50 | Content validation and link checks in CI | 3 | BLG-10 | Done |
| BLG-51 | Accessibility, performance and manual pass | 2.5 | BLG-34, BLG-42 | Done (on sample content) |
| BLG-52 | README, licences and public repository | 1 | BLG-05 | Done |
| BLG-53 | Launch | 0.5 | BLG-50 to BLG-52 | Done |

BLG-50 only needs BLG-10 and can be done any time after it; doing it early catches content errors sooner.

#### BLG-50 · Content validation and link checks in CI

Given that invalid content must stop a deploy instead of breaking a page, when Juan Martín writes the JSON Schemas and scripts/validate.rb and adds them and html-proofer to CI, then every push is checked before it is deployed.

**Technical notes:**

- Schemas for post front matter, topics.json, projects.json, about.json, the string files.
- Cross-file checks and messages of JSON contracts 8.
- htmlproofer ./_site --disable-external --check-internal-hash.

**Acceptance criteria:**

- A post with an unknown tag fails CI with the message of JSON contracts 8.
- A missing Spanish string fails CI.
- A broken internal link fails CI.
- The real repository passes.

#### BLG-51 · Accessibility, performance and manual pass

Given that RNF-01 to RNF-09 need checking by hand, when Juan Martín runs Lighthouse and the manual list of Design document 13.2, then problems are fixed or written down before launch.

**Technical notes:**

- Lighthouse mobile on home and the longest post, both themes.
- Keyboard-only and JavaScript-off passes; screen reader spot check of the theme toggle, filters and language switch.

**Acceptance criteria:**

- Performance 95 or more and accessibility 100 on both pages.
- Every item of the 13.2 list ticked, or written as a known problem in the Design document.
- Result (2026-11-22, live site in Helium through Claude in Chrome, plus Lighthouse): Lighthouse mobile 100 performance, 100 accessibility, 100 best practices, 100 SEO on home; 100 performance, accessibility and SEO on the long post. axe-core (WCAG 2.2 AA rules) finds 0 violations on every page type in both themes. Fixed in this ticket: C/C++ and Homelab topic colours, three syntax colours, the language button's accessible name, a favicon, the photo placeholder contrast, and 44 px click areas for tag pills, project links and "What is RSS?". Checked: no horizontal scroll on 16 pages at 320, 768 and 1280 px in both themes; a visible focus ring on every focusable element; theme toggle and its persistence; language switch on translated and untranslated posts; copy button; no third-party request or cookie before the comments, giscus only after scrolling; all content readable with JavaScript off. Known exceptions: a post with math weighs about 177 KB because of KaTeX's fonts (47 KB), over RNF-02's 150 KB; GitHub Pages' 10-minute cache lifetime cannot be configured. Still to do by hand: a screen reader spot check. Repeat the pass after BLG-42 with the real posts.

#### BLG-52 · README, licences and public repository

Given that the code is GPL and the posts CC BY-SA, when Juan Martín adds the licence files and a README and makes the repository public, then readers and contributors know what they may reuse and where to propose changes.

**Technical notes:**

- LICENSE with the GPL-3.0 text and "or later" notice; LICENSE-content with CC BY-SA 4.0; font licences in assets/fonts/.
- README: what the site is, how to run it locally, how to write a post, that Codeberg is a mirror and changes go through GitHub.
- Check that no token or private email is in the history before making it public.

**Acceptance criteria:**

- Both licence files present; the footer names both.
- The repository is public and the Codeberg mirror shows the README.
- Result (2026-11-22): both repositories were already public (GitHub since its creation). History scan before calling it done: all 28 commits use the GitHub no-reply address; no private email address, token or key appears anywhere in the history; the only address in the files is contact@strinix.com.ar. LICENSE (GPL-3.0 text, "GPL-3.0-or-later" in the README), LICENSE-content (CC BY-SA 4.0), the three OFL font licences and KaTeX's MIT licence are in place. The README gained "Writing a post"; the Codeberg mirror shows it (commit 8c1eb71).

#### BLG-53 · Launch

Given that everything works on fixtures and real content is in, when Juan Martín deletes the remaining sample content and deploys, then strinix.com.ar is live.

**Technical notes:**

- Delete any sample posts still in _posts/; check that _data/ holds only real data.
- Check the title ~/strinix shows in the header, page titles and feeds.
- Tick the launch checklist in the Plan.

**Acceptance criteria:**

- The Plan's launch checklist is complete.
- No fixture content is reachable on the live site.
- Result (2026-11-22): the site is live. The sample posts are deleted, the unused interpreters topic is removed, and _data/ holds only real data; the old sample addresses and tag feeds return 404 and the build has no placeholders. ~/strinix shows in the header, every page title and the feeds, in both languages. HTTP redirects to HTTPS; CI passes; Codeberg matches GitHub. Both versions of the first post load giscus with the shared term post:building-this-blog. The Plan's launch checklist is ticked, with one post and its translation under BLG-42's cut. The planning documents are exported to docs/ as a launch snapshot. Commits 490b16e, a2026f0, 7ab4709, 996b4de.

### Extensions

Only after launch.

| **ID** | **Ticket** | **Hours** | **Notes** |
|---|---|---|---|
| BLG-60 | Full-text search | 3 | Pagefind run in CI after the Jekyll build, one index per language; replaces the row filter on the archive |
| BLG-61 | Post series | 2 | series front matter and the series box that was removed from the post design |
| BLG-62 | Open Graph images per post | 3 | Generated at build time with the post title and topic colour |
| BLG-63 | Daily scheduled build | 0.5 | schedule trigger so future-dated posts appear on their day (RF-75) |
