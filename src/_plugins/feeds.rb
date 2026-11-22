# frozen_string_literal: true

# Atom feeds (Design document 2.1, JSON contracts 6.5).
#
# - Tag feeds: one page per tag in use per language, /feed/by_tag/<tag>.xml
#   and /es/feed/by_tag/<tag>.xml, rendered by the atom layout.
# - feed_html: a post's HTML made ready for feed readers (see below).

module Strinix
  class TagFeeds < Jekyll::Generator
    def generate(site)
      default = site.config["default_lang"]
      site.posts.docs.group_by { |post| post.data["lang"] }.each do |lang, posts|
        dir = lang == default ? "/feed/by_tag" : "/#{lang}/feed/by_tag"
        posts.flat_map { |post| post.data["tags"] }.uniq.each do |tag|
          page = Jekyll::PageWithoutAFile.new(site, site.source, dir, "#{tag}.xml")
          page.data.merge!("layout" => "atom", "lang" => lang, "tag" => tag, "sitemap" => false)
          site.pages << page
        end
      end
    end
  end

  module FeedFilters
    # Feed readers load none of the site's CSS or JavaScript, so the post HTML
    # is simplified: plain code blocks, formulas as their TeX source,
    # no page-only controls, and absolute URLs.
    def feed_html(html)
      url = @context.registers[:site].config["url"]
      Strinix::FeedFilters.tex_only(html.to_s)
        .gsub(%r{<figure class="code"[^>]*>\s*<figcaption><span>(.*?)</span>.*?</figcaption>\s*(.*?)\s*</figure>}m) do
          caption = $1.empty? ? "" : "<p><code>#{$1}</code></p>\n"
          "#{caption}#{$2}"
        end
        .gsub(%r{<span class="katex-display">(<pre>.*?</pre>)</span>}m, "\\1")
        .gsub(%r{<a class="heading-anchor"[^>]*>#</a>}, "")
        .gsub(/(href|src)="\//, "\\1=\"#{url}/")
    end

    # Replaces each KaTeX formula (<span class="katex">…</span>, nested spans
    # included) with its TeX source as code: many feed readers strip MathML and
    # none load KaTeX's CSS, but every reader shows code.
    def self.tex_only(html)
      result = +""
      position = 0
      while (start = html.index('<span class="katex">', position))
        result << html[position...start]
        finish = closing_span_end(html, start)
        formula = html[start...finish]
        tex = formula[%r{<annotation encoding="application/x-tex">(.*?)</annotation>}m, 1]
        display = formula.include?('display="block"')
        result << if tex.nil? then formula
                  elsif display then "<pre><code>#{tex.strip}</code></pre>"
                  else "<code>#{tex.strip}</code>"
                  end
        position = finish
      end
      result << html[position..]
    end

    # Index just past the </span> that closes the <span> opening at start.
    def self.closing_span_end(html, start)
      depth = 0
      index = start
      loop do
        opening = html.index("<span", index)
        closing = html.index("</span>", index)
        if opening && opening < closing
          depth += 1
          index = opening + 5
        else
          depth -= 1
          index = closing + 7
          return index if depth.zero?
        end
      end
    end
  end
end

Liquid::Template.register_filter(Strinix::FeedFilters)
