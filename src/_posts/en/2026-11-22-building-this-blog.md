---
title: "How I (vibe)coded this blog"
date: 2026-11-22
description: "A bilingual, static, Gruvbox-themed blog: the decisions behind it, and what it was like building it with an AI agent."
tags: [tooling]
ref: building-this-blog
---

So I've been doing a lot of interesting stuff recently and I came to the realization that I should actually start documenting it. I've been making (or trying to make) a kernel for a little while now and this past year I also participated in my first Student Cluster Competition at CARLA 2026 and got 3rd place, was part of my first hackathon at the NASA Space Apps Challenge and built a web game for my Software Engineering course at uni that was kind of fun to make. So, thinking about it now, documenting all the stuff I do would be a great plus for when I want to get a job somewhere! hehe.

So, after all of that consideration, I decided to build a blog as a kind of portfolio, using lots of AI, of course, because I'm not really interested in webdev and I don't want to spend too much time on a project like that.

## The short version

- Static site built with **Jekyll**, hosted on **GitHub Pages**, mirrored to **Codeberg**.
- **English and Spanish**, with every interface string translated and posts linked across languages.
- **Gruvbox**, in a light and a dark theme, with every text colour checked for contrast.
- **Works without JavaScript.** The five scripts on the site add up to about 9 KB and only add conveniences.
- **CI that refuses to deploy broken content:** schemas for every data file, link checks, and a build that fails on bad math.

## Why static, and why Jekyll

A blog is mostly text that changes when I publish, not when someone visits. That's exactly what a static site is for: no server, no database, nothing to patch, and hosting is free!!!

I picked Jekyll because GitHub Pages speaks it natively. And for what I want it for, it is more than enough: Markdown, HTML and CSS are all I need to write a few posts from time to time and have a good-looking portfolio. Anything Jekyll can't do, a few dozen lines of Ruby in `_plugins/` can.

## Planning before code

Before any code there was a document: a plan, a specification, a design document, the JSON "contracts" for every data file, and a list of tickets (BLG-01 to BLG-53) grouped into milestones. Next to it, a design canvas with every page drawn in both themes.

This turned out to matter more than any technical choice. Every ticket had acceptance criteria, so "done" meant something. And when the AI drifted from the design, there was a canvas to point at.

I think it's very important when working with AI to plan everything in advance; having as few gaps as possible is a must! One might code little (if at all) when using AI, but design, architecture and planning are the essential stuff you can't get wrong if you want a good final product when working with AI.

As one of my professors said: *"In the age of AI, writing code is no longer the bottleneck of a complex project"*.

## Two languages, one site

I live in Argentina, a Spanish-speaking country of course, so I decided to add Spanish and English support for the site. One never knows if a recruiter would appreciate it...

Each post lives in `_posts/en/` or `_posts/es/`. The two versions share a `ref`:

```yaml
---
title: "Why the concept of skibidi toilet is so funny (in my opinion)."
date: 2026-06-07
tags: [memes]
ref: skibidi-toilet
---
```
{: data-file="_posts/en/2026-06-07-skibidi-toilet.md"}

The `ref` links the translations for the language switch, and it's also the key the comments are stored under. That way both versions of a post share one comment thread.

Interface text (menus, headings, buttons) lives in two JSON files, `i18n/en.json` and `i18n/es.json`. A missing key in either one fails the build. There's no "I'll translate it later" that silently ships English to Spanish readers.

One rule I added is: if a post has no Spanish version yet, it still appears on the Spanish pages, in English. Once the translation exists, it takes its place:

```ruby
def posts_for(lang)
  site = @context.registers[:site]
  default = site.config["default_lang"]
  site.posts.docs.reverse.select do |post|
    post_lang = post.data["lang"]
    post_lang == lang || (post_lang == default && !post.data.dig("translations", lang))
  end
end
```
{: data-file="_plugins/i18n.rb"}

> It's not done the other way around because I will always write English posts first!
{: .note}

## Gruvbox, but readable

Gruvbox is the colour scheme my terminal, editor, window manager, app themes... already use, so the site HAD to be Gruvbox!!! Each colour is a pair, light and dark, using CSS `light-dark()`:

```css
:root {
  color-scheme: light dark;
  --bg:     light-dark(#fbf1c7, #282828);
  --text:   light-dark(#3c3836, #ebdbb2);
  --accent: light-dark(#af3a03, #fabd2f);
}
```
{: data-file="assets/css/_tokens.css"}

The theme follows your system until you pick one with the toggle. With JavaScript off, it still follows your system.

The catch: some Gruvbox colours aren't readable as text. Gruvbox's red on a dark card is about 3.8:1, below the 4.5:1 that WCAG asks for normal text. So every colour on the site was checked against every background it sits on, and a few were nudged: a slightly lighter red, lighter comments in code, a darker green in the light theme. You probably can't tell, but your eyes can.

## Math, rendered at build time

Some posts will have formulas, so the site renders them with KaTeX when it's built, not in your browser. A formula like $$O(n \log n)$$ arrives as finished HTML, with no math JavaScript.

A broken formula used to fail silently. Now a TeX error or an unclosed `$$` fails the production build, so I find out before you do.

## Comments without the tracking

Comments use giscus, which stores them in GitHub Discussions. But giscus means loading a script from another site, so it only loads when you scroll near the comments:

```js
const observer = new IntersectionObserver(
  (entries) => {
    if (!entries.some((entry) => entry.isIntersecting)) return;
    observer.disconnect();
    load();
  },
  { rootMargin: "600px" },
);
observer.observe(section);
```
{: data-file="assets/js/comments.js"}

If you read a post and leave, your browser never talks to anyone but GitHub Pages.

## RSS that works in real readers

There's a full Atom feed, plus one per tag. Testing it in NewsFlash taught me that feed readers are not browsers: they strip styles, and some drop the MathML KaTeX produces. The feeds now carry plain code blocks and show formulas as TeX source. Not pretty, but always readable.

## CI that says no

Every push runs the same pipeline before anything is deployed:

1. Check every post's front matter and every data file against a JSON Schema, plus cross-checks: a tag must exist, a project's write-up must point at a real post, each language must have the same strings.
2. Build the site in production mode. That's where TeX errors and missing translations fail.
3. Check that every feed is valid XML with entries.
4. Check every internal link and image with html-proofer.
5. Deploy to GitHub Pages, then mirror the repository to Codeberg.

If any step fails, the live site stays as it was.

## Building it with the best 10x engineer, Claude

Now the shame! I built this with Claude Code, working in my editor and terminal. The division of labour was roughly:

- **Me:** what the site should be, the plan and the design, every decision, and reviewing every page before it shipped.
- **Claude:** most of the code, the checks, and a lot of the tedious parts, like computing contrast ratios for every colour pair.

What worked:
- **Ticket by ticket.** Each ticket was small enough to review properly: build locally, I look at it, then it ships.
- **A design to compare against.** "Make it match the canvas" is a much better instruction than "make it look nice".
- **Checks as guardrails.** Schemas, link checks and the math check catch mistakes from either of us.

What didn't, or needed me:
- **Visual details:** an off-centre card, timeline dots a few pixels off, a title wrapping too early. It took me pointing at screenshots to get those right.
- **Taste.** It proposed; I picked. Sometimes it confidently followed the design when the design itself was wrong. The archive page was narrower than the rest because the canvas said so.
- **Real-world testing.** A feed that looks fine in a validator can look broken in an actual reader.

For a project I wasn't really interested in learning a lot from, it was really good and fast: all of the planning took one evening and the coding itself took a day. It was fun and a good experience and experiment. In the end I learned quite a lot of stuff about the stack but I wouldn't be advertising myself as an expert webdev (not even a beginner) since if I had to redo all of this on my own I would be, as we say in Spanish, as lost as a Turkish man in the mist. Maybe not completely lost but it would take me a lot more than a day to code everything from scratch again.

## What's next

The source is public on [GitHub](https://github.com/Juanma-Her/blog) and [Codeberg](https://codeberg.org/Strinix/blog), code under GPL-3.0 and posts under CC BY-SA 4.0.

In the near future I'll be writing about a rasterizer I've been working on to learn C++ and a small operating system (kernel) I've also been working on for some time now but haven't really dedicated enough time to it (until now!).

If you spot a mistake, every post has a link at the bottom to suggest an edit.
