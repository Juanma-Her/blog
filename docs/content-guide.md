# ~/strinix content guide

Quick reference for changing the blog's content. All paths are relative to the repository root.

## Where things live

| What | File |
|---|---|
| Posts | `src/_posts/en/`, `src/_posts/es/` |
| Drafts (not published) | `src/_drafts/` |
| About page | `src/_data/about.json` |
| Projects page | `src/_data/projects.json` |
| Tags / topics and their colours | `src/_data/topics.json` |
| Interface text (menus, headings, labels) | `src/_data/i18n/en.json`, `src/_data/i18n/es.json` |
| Images | `src/assets/img/` |
| Site settings | `_config.yml` |
| Allowed fields and values | `schemas/*.schema.json` |

## Text in two languages

Most text fields are a pair, and **both languages are required**:

```json
{ "en": "Team member", "es": "Integrante" }
```

Plain strings (same in both languages): project `title` and `stack`, about `org`, competition `event`, team `name`. A skill's `label` can be either a plain string or a pair.

Dates in the data files are `"YYYY-MM"` (for example `"2026-11"`). An experience `end` of `null` means "now".

## Tags (topics)

Defined in `src/_data/topics.json`. A coloured topic:

```json
"linux": {
  "label": { "en": "Linux", "es": "Linux" },
  "dark": "#fabd2f",
  "light_text": "#504945",
  "light_bar": "#b57614"
}
```

- **Key:** lowercase letters, digits and `+`, words joined with `-`. No spaces.
- **`dark`:** text and dots in the dark theme. Needs 4.5:1 contrast on `#282828`, `#1d2021` and `#32302f`.
- **`light_text`:** text in the light theme. Needs 4.5:1 on `#fbf1c7`, `#f2e5bc` and `#f9f5d7`. If the colour is too pale, use `#504945` (dark grey).
- **`light_bar`:** dots and bars in the light theme. Needs 3:1.
- **Tag without a colour:** `"mpi": { "hidden": true }`. Allowed as a post's 2nd–5th tag, never the first.
- **Filter chips:** a tag appears as a chip on home and the archive only once a post uses it.

Gruvbox colours already taken: orange `rust`, blue `cpp`, violet `homelab`, yellow-green `tooling`, yellow `python`, pink `hpc`, red `asm`, aqua `graphics`.

## Posts

File: `src/_posts/en/YYYY-MM-DD-slug.md` (or `es/`). Address: `/posts/slug/` or `/es/posts/slug/`.

```yaml
---
title: "How I (vibe)coded this blog"               # up to 110 characters
date: 2026-11-22                                   # must match the file name
description: "One sentence, 40 to 200 characters."
tags: [tooling]                                    # 1 to 5; the first must be a coloured topic
ref: building-this-blog                            # same ref in both languages
---
```

Optional front matter:
- `updated: 2026-12-01`: shows an "Updated" date.
- `comments: false`: hides the comment box.
- `hero_code`: `lang` plus `code` (at most 12 lines), shown on the home page while it's the newest post.

Rules:
- **`ref`:** never change it after publishing; the comments are tied to it.
- **Untranslated posts:** an English post without a Spanish version also appears on the Spanish pages, in English, until you add the translation with the same `ref`.
- **Future dates:** a post dated in the future appears with the first deploy on or after that date.

Markdown extras:
- **File name on a code block:** put `{: data-file="src/lexer.rs"}` on the line right after the block.
- **Note box:** a `> quote` followed by `{: .note}`.
- **Inline math:** `$$O(n)$$` inside a sentence.
- **Centred formula:** `$$` on its own line, the formula, then `$$` on its own line.
- **Literal dollar signs:** write `\$\$`.

## About page (`src/_data/about.json`)

| Section | Fields |
|---|---|
| `profile` | `photo` (path like `/assets/img/profile.webp`), `photo_alt`, `role`, `details` |
| `profile.details[]` | `key` + `value`. The key's label lives in the string files under `about.details.<key>`, so a new key needs a label in both `en.json` and `es.json` |
| `headline`, `intro` | Pairs. `intro` is Markdown (`**bold**`, `*italic*`, `\n\n` for a new paragraph) |
| `experience[]` | `start`, `end` (or `null`), `title`, `org`, `summary` |
| `elsewhere[]` | `kind` (`talk`/`article`/`podcast`), `title`, `venue`, `date`, `url`. Use `[]` to hide the section |
| `competitions.team` | `name`, `summary`, optional `url` and `logo` (image path; it replaces the server icon) |
| `competitions.entries[]` | `kind` (`scc`/`hackathon`), `event`, `date`, `role`, optional `result` and `url` |
| `skills[]` | `label` (string or pair), optional `topic` (a key in `topics.json`, which gives the dot its colour) |

Order in the file is the order on the page.

## Projects page (`src/_data/projects.json`)

```json
{
  "id": "rasterizer",
  "featured": false,
  "type": "graphics",
  "status": "active",
  "title": "rasterizer",
  "description": { "en": "...", "es": "..." },
  "stack": ["C++", "raylib"],
  "links": { "codeberg": "https://codeberg.org/Strinix/rasterizer" },
  "year": 2026
}
```

- **Featured project:** exactly one project has `"featured": true`. Only the featured one shows its `terminal` (`command` plus `output`, using `\n` for new lines; 4–6 lines look best).
- **`type`:** one of `tool`, `hpc`, `hackathon`, `os`, `graphics`.
- **`status`:** one of `active`, `maintained`, `finished`, `archived`.
- **`links`:** needs at least one of `codeberg`, `github` or `team`. Optional `demo`, and `writeup`, which is the `ref` of an existing post.

### Adding a new project type

1. `schemas/projects.schema.json`: add it to the `type` enum.
2. `en.json` and `es.json`: add it under `projects.types` (the pill) and `projects.type_filters` (the filter chip).
3. `src/assets/css/_components.css`: add `.type--newtype { --type: light-dark(<light colour>, <dark colour>); }`, with 4.5:1 contrast in both themes.

## Interface text

Everything that isn't content (menus, headings, buttons, page descriptions) is in `src/_data/i18n/en.json` and `es.json`.

- **Both files must have the same keys.** A key in one but not the other fails the check.
- **Placeholders:** `{n}`, `{year}`, `{topic}` and the like are filled in by the site. Keep them.
- **Site description:** `pages.home.description`. It's what search engines and link previews show, and it's also the RSS subtitle (`feed.subtitle`).

## Images

- **Profile photo:** `src/assets/img/profile.webp`, shown at 380×280 (crop landscape, about 4:3; 760×560 is enough).
- **Team logo:** square, shown at 52×52 (104×104 is enough).
- **Size:** keep files small. Every KB loads on every visit to that page.
- **Privacy:** strip location data from phone photos before adding them.

## Before pushing

```sh
bundle exec ruby scripts/validate.rb            # front matter and data files
JEKYLL_ENV=production bundle exec jekyll build  # also fails on TeX errors and missing strings
bundle exec ruby scripts/validate.rb --feeds
bundle exec htmlproofer ./_site --disable-external
```

Common failures:
- **Invalid JSON:** usually a trailing comma after the last item in a `{}` or `[]`.
- **Unknown value:** a `type`, `status`, `kind` or `topic` that isn't in the allowed list.
- **Missing translation:** a pair with only `en` or only `es`.

Not caught by the checks: a `[placeholder]` left in the text. Search for `[` before pushing.

Changes go to GitHub (`main`); Codeberg is overwritten from it on every deploy.

## Colour palette

Every set below is ready to paste into a topic. All were checked against the site's backgrounds:
- **`dark`:** at least 4.5:1 on all three dark backgrounds.
- **`light_text`:** at least 4.5:1 on all three light backgrounds.
- **`light_bar`:** at least 3:1.

The numbers are the worst-case contrast for each.

For a **project type** colour, use `light-dark(<light_text>, <dark>)`: the pill is text, so it needs the 4.5:1 pair.

### Already in use

| Topic | Colour | `dark` | `light_text` | `light_bar` |
|---|---|---|---|---|
| rust | orange | `#fe8019` (5.2) | `#af3a03` (4.9) | `#af3a03` |
| cpp | blue | `#83a598` (4.9) | `#076678` (5.3) | `#076678` |
| homelab | violet | `#b496d6` (5.2) | `#6a4c93` (5.5) | `#6a4c93` |
| tooling | yellow-green | `#b8bb26` (6.4) | `#504945` (7.0) | `#79740e` |
| python | yellow | `#fabd2f` (7.7) | `#504945` (7.0) | `#b57614` |
| hpc | pink | `#d3869b` (4.8) | `#8f3f71` (5.4) | `#8f3f71` |
| asm | red | `#fb6a55` (4.6) | `#9d0006` (6.9) | `#9d0006` |
| graphics | aqua | `#8ec07c` (6.2) | `#504945` (7.0) | `#427b58` |

Project types use the same colours: tool blue, hpc pink, hackathon orange, os red, graphics aqua.

### Free, and clearly different from the ones in use

| Name | `dark` | `light_text` | `light_bar` |
|---|---|---|---|
| indigo | `#9aa5e6` (5.6) | `#3f4a99` (6.3) | `#3f4a99` |
| sky | `#7fb8e0` (6.2) | `#2f5f8a` (5.4) | `#2f5f8a` |
| teal | `#5fb3b3` (5.4) | `#2b6b6b` (4.9) | `#2b6b6b` |
| brown | `#d4a373` (5.8) | `#7a4a1e` (5.9) | `#7a4a1e` |
| magenta | `#e08fd0` (5.6) | `#8a2d7a` (6.1) | `#8a2d7a` |
| gray | `#a89984` (4.7) | `#6d625a` (4.7) | `#7c6f64` |

### Free, but close to a colour in use

Use these only if you run out. Next to their neighbour, they can be hard to tell apart.

| Name | Close to | `dark` | `light_text` | `light_bar` |
|---|---|---|---|---|
| mint | aqua (graphics) | `#7fd6a8` (7.6) | `#256b45` (5.1) | `#256b45` |
| lime | yellow-green (tooling) | `#a6d15a` (7.4) | `#466e0f` (4.8) | `#4f7a12` |
| olive | yellow-green (tooling) | `#c7c26a` (7.1) | `#6b660c` (4.7) | `#6b660c` |
| gold | yellow (python) | `#e6c55c` (7.8) | `#7a5c00` (5.0) | `#7a5c00` |
| coral | orange (rust) | `#ff9e7a` (6.5) | `#a6401c` (5.0) | `#a6401c` |
| rose | red (asm) | `#f28fa0` (5.8) | `#a32642` (5.7) | `#a32642` |

### Gruvbox colours that fail as text

These are fine for dots and bars, but not for text:
- `#fb4934` (red) is only 3.8:1 on dark cards. Use `#fb6a55` instead.
- `#427b58` (aqua) is 4.0:1 on light panels. Use `#3a6f50` for light text.
- `#79740e` (green) and `#b57614` (yellow) are under 4.5:1 on light backgrounds. Use `#6a680c` and `#885b0f`, or `#504945`.
- `#458588`, `#cc241d` and the other "normal" Gruvbox shades fail in at least one theme.

If you pick a colour that isn't listed, check its contrast against the six backgrounds above before using it.
