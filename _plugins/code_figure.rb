# frozen_string_literal: true

# Wraps every highlighted code block of a post in the code figure of JSON
# contracts 6.3: a caption with the file name ({: data-file="src/lexer.rs"})
# or the language, and a copy button that copy.js shows and runs.

module Strinix
  module CodeFigure
    BLOCK = %r{<div(?: data-file="(?<file>[^"]*)")? class="(?:language-(?<lang>\S+) )?highlighter-rouge"><div class="highlight">(?<pre><pre.*?</pre>)</div>\s*</div>}m
    ICON = File.read(File.join(__dir__, "..", "_includes", "icon-copy.html")).strip

    def self.wrap(html, strings)
      html.gsub(BLOCK) do
        match = Regexp.last_match
        label = match[:file] || match[:lang]
        file = match[:file] ? %( data-file="#{match[:file]}") : ""
        <<~HTML.strip
          <figure class="code"#{file}>
          <figcaption><span>#{label}</span><button type="button" class="copy" data-copy data-copied="#{strings["copied"]}" hidden>#{ICON}<span data-copy-label>#{strings["copy"]}</span></button><span class="visually-hidden" aria-live="polite" data-copy-status></span></figcaption>
          <div class="highlight">#{match[:pre]}</div>
          </figure>
        HTML
      end
    end
  end
end

Jekyll::Hooks.register :posts, :post_convert do |post|
  strings = post.site.data.dig("i18n", post.data["lang"], "post")
  post.content = Strinix::CodeFigure.wrap(post.content, strings)
end
