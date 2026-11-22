# frozen_string_literal: true

# {{ "Un intérprete: Rust" | filter_text }} → "un interprete rust"
# Lower case, accents removed, punctuation turned into spaces, so the filter
# script can match words with a plain substring test (JSON contracts 6.2).

module Strinix
  module FilterTextFilter
    def filter_text(input)
      input.to_s
           .unicode_normalize(:nfd)
           .gsub(/\p{Mn}/, "")
           .downcase
           .gsub(/[^a-z0-9+#]+/, " ")
           .strip
    end
  end
end

Liquid::Template.register_filter(Strinix::FilterTextFilter)
