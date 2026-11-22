# frozen_string_literal: true

require "cgi"

# Math checks (BLG-35). A production build (CI) fails, naming the post, when:
#
# - a formula has a TeX error: KaTeX would otherwise show the raw TeX in red;
# - a $$ is left unclosed: the formula would show as plain text.
#
# The $$ count reads the Markdown, not the HTML: kramdown outputs an escaped
# \$\$ (a literal dollar pair) and an unclosed $$ the same way.
# In development the problems are only warnings, so `jekyll serve` keeps going.

module Strinix
  module MathCheck
    FENCED_CODE = /^(```|~~~).*?^\1/m
    INLINE_CODE = /`[^`\n]*`/
    KATEX_ERROR = /<span class="katex-error" title="([^"]*)"[^>]*>(.*?)<\/span>/m

    def self.report(post, problem)
      file = File.join(File.basename(post.site.source), post.relative_path) # src/_posts/...
      message = "Math error in #{file}: #{problem}"
      raise Jekyll::Errors::FatalException, message if Jekyll.env == "production"

      Jekyll.logger.warn("Math:", message)
    end

    def self.unclosed?(markdown)
      text = markdown.gsub(FENCED_CODE, "").gsub(INLINE_CODE, "").gsub("\\$", "")
      text.scan("$$").size.odd?
    end
  end
end

Jekyll::Hooks.register :posts, :pre_render do |post|
  if Strinix::MathCheck.unclosed?(post.content)
    Strinix::MathCheck.report(post, "a $$ is not closed (write \\$\\$ for literal dollar signs)")
  end
end

Jekyll::Hooks.register :posts, :post_convert do |post|
  post.content.scan(Strinix::MathCheck::KATEX_ERROR) do |title, tex|
    Strinix::MathCheck.report(post, "#{CGI.unescapeHTML(title)} (in: #{CGI.unescapeHTML(tex)})")
  end
end
