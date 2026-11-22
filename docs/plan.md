# Plan

> Snapshot of the planning document as of 2026-11-22 (launch). Not updated after that.

## Plan: strinix.com.ar

*2026-11-21*

This plan is the summary. Where it disagrees with the Specification, Design document, JSON contracts and interfaces, or Tickets tabs, those tabs win.

### Concept

A personal dev blog for Juan Martín Hernández at **strinix.com.ar**: posts about Rust, Go, databases, tooling and HPC, a projects page, an about page with competitions and hackathons, and RSS feeds. The site is called ~/strinix; every place that shows the name reads one config value.

The look is settled. The designs live on the design canvas (private): a Gruvbox card layout (option C) in a dark and a light theme, for six pages: landing, post, archive, projects, about and the RSS feed page.

What the blog should be, in three sentences:

1. A place to write longer technical posts in English or Spanish, with code that reads well in both themes.
1. A portfolio that shows projects, HPC team work and competitions without needing a separate site.
1. Static, fast and private: no tracking, no ads, nothing to keep running except GitHub Pages.

### What it has to do

- **Read well.** Long posts with code and math, a readable column, read time, previous and next links, and comments for people with a GitHub account.
- **Two languages, no duplication of work.** English at the root and Spanish under /es/. Every interface string exists in both languages; a post can exist in one language or in both.
- **Two themes.** Dark and light Gruvbox, following the visitor's system setting until they press the toggle, then remembering their choice.
- **Codeberg and GitHub, per project.** Each project links to the forges it is really on: Codeberg, GitHub or both, Codeberg first. Most projects are only on Codeberg. This blog's own repository is on GitHub with a Codeberg mirror, so its source links show both.
- **Easy to keep.** Writing a post is adding one Markdown file and pushing. Adding a project is editing one data file.

### Technical approach

Jekyll generates the site; a GitHub Actions workflow builds it and deploys it to GitHub Pages on every push to main. Using Actions instead of the built-in Pages build allows custom plugins, so languages, tag feeds and validation can be done properly.

1. **Theme from the designs.** The Gruvbox palettes become CSS custom properties, one set per theme. Every colour in the designs maps to a token.
1. **Layouts and includes.** One layout per page type (home, post, archive, projects, about) plus shared includes for the header, footer, cards and code blocks.
1. **Languages by folder and front matter.** Posts carry lang and a translation key ref. Pages exist once per language as thin files that set lang and reuse the same layout. Strings come from _data/i18n/en.json and _data/i18n/es.json.
1. **Data files for the non-post content.** Projects, about-page entries and topics live in JSON files in _data/, validated against JSON Schemas in CI.
1. **Little JavaScript, all optional.** Theme toggle, archive search and filters, copy buttons, and giscus comments. Without JavaScript every page still reads, and the theme follows the system.
1. **Feeds.** An Atom feed per language and per tag. The RSS link opens a normal page with the feed page design that shows the feed address; the XML itself stays plain.
1. **Math.** LaTeX in posts is turned into KaTeX HTML when the site is built, so formulas need no JavaScript in the browser and read in both themes.
1. **Mirror.** After each deploy, the workflow pushes main and tags to Codeberg.

Detail: Specification and Design document tabs.

### Pages

| **Page** | **URL (English / Spanish)** | **Design** | **Content source** |
|---|---|---|---|
| Home | / and /es/ | Landing page (dark / light) | Latest post as hero, recent posts, follow section |
| Post | /posts/&lt;slug>/ and /es/posts/&lt;slug>/ | Post | _posts/&lt;lang>/\*.md |
| Archive | /posts/ and /es/posts/ | Archive | All posts of the language, grouped by year |
| Projects | /projects/ and /es/projects/ | Projects | _data/projects.json |
| About | /about/ and /es/about/ | About | _data/about.json |
| RSS feed page | /feed/ and /es/feed/ | RSS feed | Explains RSS and shows the feed address /feed.xml or /es/feed.xml |
| Not found | /404.html | 404 (dark / light) | Short message in both languages |

### Tools and links

| **Tool** | **What it does here** | **Link** |
|---|---|---|
| Jekyll 4 | Static site generator | [jekyllrb.com](https://jekyllrb.com/) |
| GitHub Actions and Pages | Build, deploy and host | [docs.github.com/pages](https://docs.github.com/en/pages) |
| giscus | Comments stored in GitHub Discussions | [giscus.app](https://giscus.app/) |
| Rouge | Syntax highlighting at build time | [rouge-ruby](https://github.com/rouge-ruby/rouge) |
| KaTeX | Math in posts, rendered at build time by kramdown-math-katex | [katex.org](https://katex.org/) |
| jekyll-seo-tag and jekyll-sitemap | Meta tags and sitemap | [jekyll-seo-tag](https://github.com/jekyll/jekyll-seo-tag) |
| html-proofer | Broken links and images in CI | [html-proofer](https://github.com/gjtorikian/html-proofer) |
| json_schemer | Validates data files and front matter in CI | [json_schemer](https://github.com/davishmcclurg/json_schemer) |
| Codeberg | Mirror of the repository | [codeberg.org](https://codeberg.org/) |
| Gruvbox | Colour palette | [gruvbox](https://github.com/morhetz/gruvbox) |
| Space Grotesk, Inter, JetBrains Mono | Fonts, self-hosted | [Google Fonts](https://fonts.google.com/) |

The design canvas (private) has both themes of every page.

### Working model

One person, Juan Martín, works through the tickets in milestone order. There are no calendar dates; each ticket has an hour estimate (67.5 hours in total), and each milestone ends with something that works in a browser.

| **Milestone** | **What exists at the end** | **Hours** |
|---|---|---|
| M0 Setup | Repository on GitHub, mirror on Codeberg, DNS pointing at Pages, an empty site deployed over HTTPS | 5 |
| M1 Foundation | Base layout, theme tokens, theme toggle, header and footer in both languages | 12 |
| M2 Pages | Home, post, archive, projects and about built from sample content, in both themes and both languages | 17.5 |
| M3 Features | Code blocks, math, filters, comments, feeds, the feed page and the 404 page | 15.5 |
| M4 Content | Real about and projects data, photo and the first two posts | 10.5 |
| M5 Launch | CI checks, accessibility and performance pass, launch | 7 |

The rule of the plan: **nothing from M4 starts until M2 is merged**, so the content is written into pages that already exist.

### Launch checklist

- [ ] strinix.com.ar opens over HTTPS, in both themes and both languages.
- [ ] At least two real posts, one of them in both languages.
- [ ] Projects and about pages with real data, a Codeberg or GitHub link (or both) on every project.
- [ ] The RSS link opens the feed page, and the feed address imports into a feed reader.
- [ ] Comments work on a post.
- [ ] CI passes: build, schema validation, link check.
- [ ] Codeberg mirror matches GitHub.

### Risks and what to cut

If something takes too long, cut from the bottom up. The two themes, the two languages and the forge links are never cut.

| **Risk** | **Sign** | **Response** |
|---|---|---|
| Bilingual routing gets complicated | M1 takes more than twice its estimate | Keep English and Spanish pages as separate thin files; drop the "translation available" link on posts until later |
| giscus does not match the theme | The comment box stays light in dark mode | Use giscus's built-in gruvbox_dark and gruvbox_light themes without custom CSS |
| Codeberg changes its mirror rules | The push from CI is refused | Switch to a Codeberg pull mirror, or push by hand until fixed |
| Mirror push fails | Codeberg falls behind | The mirror job never blocks the deploy; push by hand until the token is fixed |
| Writing time runs out | Launch slips because posts are not ready | Launch with one post; the site is the deliverable, posts follow |

Cut first: archive search, per-tag feeds, the copy button on code. Keep always: both themes, both languages, the six pages, and the forge links on every project.
