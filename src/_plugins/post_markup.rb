# frozen_string_literal: true

# Additions to a post's HTML after Markdown conversion (Design document 6.2):
#
# - A "#" link before every h2 and h3, pointing at the heading's own id.
# - The translated "Note" label at the start of a note callout ({: .note}).

Jekyll::Hooks.register :posts, :post_convert do |post|
  strings = post.site.data.dig("i18n", post.data["lang"], "post")

  post.content = post.content
    .gsub(/<h([23]) id="([^"]+)">/) do
      %(<h#{$1} id="#{$2}"><a class="heading-anchor" href="##{$2}" aria-label="#{strings["section_link"]}">#</a>)
    end
    .gsub(%r{<blockquote class="note">\s*<p>}) do
      %(<blockquote class="note">\n<p><strong class="note-label">#{strings["note"]}</strong> )
    end
end

# {{ post.content | sections }}: the post's h2 headings as [{ "id", "title" }],
# for the "In this post" list on the home page when a post has no hero_code.
module Strinix
  module SectionsFilter
    def sections(html)
      html.to_s.scan(%r{<h2 id="([^"]+)">(.*?)</h2>}m).map do |id, inner|
        title = inner.sub(%r{<a class="heading-anchor"[^>]*>#</a>}, "").gsub(/<[^>]+>/, "").strip
        { "id" => id, "title" => title }
      end
    end
  end
end

Liquid::Template.register_filter(Strinix::SectionsFilter)
