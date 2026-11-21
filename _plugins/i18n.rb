# frozen_string_literal: true

# Languages (Design document 2.2, JSON contracts 7.2).
#
# - page.translations: { "en" => url, "es" => url } for every page or post
#   with a `ref`. Pages that share a ref are translations of each other.
# - t:             {{ "post.read_time" | t: page.lang, n: 12 }}
# - localize:      {{ project.description | localize: page.lang }}
# - localize_date: {{ page.date | localize_date: page.lang }}

module Strinix
  class Translations < Jekyll::Generator
    def generate(site)
      documents = site.pages + site.posts.docs
      by_ref = Hash.new { |hash, ref| hash[ref] = {} }

      documents.each do |doc|
        ref = doc.data["ref"]
        by_ref[ref][doc.data["lang"]] = doc.url if ref
      end

      documents.each do |doc|
        ref = doc.data["ref"]
        doc.data["translations"] = by_ref[ref] if ref
      end
    end
  end

  module I18nFilters
    def t(key, lang, placeholders = {})
      text = strings(lang).dig(*key.split("."))
      return missing(key, lang) unless text.is_a?(String)

      placeholders.reduce(text) { |result, (name, value)| result.gsub("{#{name}}", value.to_s) }
    end

    def localize(value, lang)
      return value unless value.is_a?(Hash)

      value.fetch(lang) { raise Jekyll::Errors::FatalException, "No #{lang} text in #{value.inspect}" }
    end

    def localize_date(date, lang)
      date = Jekyll::Utils.parse_date(date.to_s) unless date.respond_to?(:strftime)
      format = strings(lang).dig("date", "format")
      month = strings(lang).dig("date", "months")[date.month - 1]
      date.strftime(format.gsub("%b", month))
    end

    private

    def strings(lang)
      @context.registers[:site].data.dig("i18n", lang) || {}
    end

    def missing(key, lang)
      message = "Missing string #{lang}.#{key} in _data/i18n/#{lang}.json"
      raise Jekyll::Errors::FatalException, message if Jekyll.env == "production"

      Jekyll.logger.warn("i18n:", message)
      "[#{key}]"
    end
  end
end

Liquid::Template.register_filter(Strinix::I18nFilters)
