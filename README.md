# ~/strinix

Source of [strinix.com.ar](https://strinix.com.ar), a bilingual (English and Spanish) dev blog built with Jekyll and served by GitHub Pages.

This repository lives on GitHub ([Juanma-Her/blog](https://github.com/Juanma-Her/blog)) and is mirrored to Codeberg ([Strinix/blog](https://codeberg.org/Strinix/blog)). The Codeberg copy is overwritten on every deploy, so changes go through GitHub; a fix proposed on Codeberg is applied on GitHub by hand.

## Layout

- `src/`: everything that becomes the website. Posts are in `src/_posts/en/` and `src/_posts/es/`, the editable data in `src/_data/`, and the page files in `src/pages/`. Jekyll builds it into `_site/`, which is not tracked.
- `schemas/` and `scripts/`: the content checks CI runs before each deploy.
- `.github/workflows/`: build, check, deploy and mirror to Codeberg.
- `_config.yml`: site settings; `source: src` points Jekyll at `src/`.

## Run it locally

Needs Ruby (see `.ruby-version`) and Bundler.

```sh
bundle install
bundle exec jekyll serve
```

Then open http://localhost:4000.

## Writing a post

Create `src/_posts/en/YYYY-MM-DD-slug.md` for English or `src/_posts/es/YYYY-MM-DD-slug.md` for Spanish. The slug becomes the address: `/posts/slug/` or `/es/posts/slug/`.

```yaml
---
title: "Writing a tiny Lisp interpreter in Rust"
date: 2026-11-14
description: "Tokenize, parse, evaluate: a working interpreter in about 200 lines."
tags: [rust, interpreters]
ref: tiny-lisp
---
```

- `description`: one sentence, 40 to 200 characters. It shows on cards, in the archive, in feeds and in search results.
- `tags`: one to five. The first one is the post's topic and must be a coloured topic in `src/_data/topics.json`; the others can be any tag listed there.
- `ref`: links the two language versions of a post. The translation uses the same `ref` in the other folder and may have its own slug. Keep a `ref` once the post is published: the comments are tied to it.
- Optional: `updated: 2026-12-01` shows an "Updated" date, `comments: false` hides the comment box, and `hero_code` (with `lang` and `code`, at most 12 lines) shows code on the home page while the post is the newest one.

In the text, besides normal Markdown:

- A code block followed by `{: data-file="src/lexer.rs"}` gets that file name in its header.
- A quote followed by `{: .note}` becomes a note box.
- `$$O(n)$$` inside a sentence is inline math; `$$ ... $$` on lines of its own is a centred formula. Write `\$\$` for literal dollar signs.

Drafts go in `src/_drafts/` and are not published. A post dated in the future appears with the first deploy on or after its date.

## Checks

CI runs these on every push and deploys only if all pass. To run them locally:

```sh
bundle exec ruby scripts/validate.rb            # front matter and data files (schemas/)
JEKYLL_ENV=production bundle exec jekyll build  # also fails on TeX errors and missing strings
bundle exec ruby scripts/validate.rb --feeds    # the built Atom feeds
bundle exec htmlproofer ./_site --disable-external
```

`htmlproofer` needs libcurl installed.

## Licences

- Code: GPL-3.0-or-later, see [LICENSE](LICENSE).
- Posts and other written content: CC BY-SA 4.0, see [LICENSE-content](LICENSE-content).
