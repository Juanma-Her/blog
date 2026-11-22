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
