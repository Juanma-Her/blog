# frozen_string_literal: true

# {{ post.content | read_minutes }}: words / words_per_minute, rounded up,
# at least 1 (Design document 3.2).

module Strinix
  module ReadTimeFilter
    def read_minutes(html)
      words = html.to_s.gsub(/<[^>]*>/, " ").split.size
      per_minute = @context.registers[:site].config.fetch("words_per_minute", 200)
      [(words / per_minute.to_f).ceil, 1].max
    end
  end
end

Liquid::Template.register_filter(Strinix::ReadTimeFilter)
