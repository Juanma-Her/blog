# frozen_string_literal: true

# Links to other sites open in a new tab: target="_blank" and rel="noopener"
# (the new page gets no handle on this one), plus a hidden "(opens in a new
# tab)" in the page's language, so screen readers announce it (WCAG G201).
#
# Runs on the finished HTML of every page and post, so it covers templates,
# Markdown and data files alike. Feeds are XML and stay as they are.

module ExternalLinks
  LINK = %r{<a\s([^>]*?\bhref="(https?://[^"]+)"[^>]*)>(.*?)</a>}m

  def self.process(doc)
    return unless doc.output_ext == ".html"

    site = doc.site
    own = site.config["url"].to_s
    note = site.data.dig("i18n", doc.data["lang"] || site.config["default_lang"], "links", "new_tab")

    doc.output = doc.output.gsub(LINK) do
      attributes, href, text = $1, $2, $3
      next $& if href.start_with?(own) || attributes.include?("target=")

      %(<a #{attributes} target="_blank" rel="noopener">#{text}<span class="visually-hidden"> #{note}</span></a>)
    end
  end
end

Jekyll::Hooks.register [:pages, :documents], :post_render do |doc|
  ExternalLinks.process(doc)
end
