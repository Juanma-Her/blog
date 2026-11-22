# frozen_string_literal: true

# Languages (Design document 2.2, JSON contracts 7.2).
#
# - page.translations: { "en" => url, "es" => url } for every page or post
#   with a `ref`. Pages that share a ref are translations of each other.
# - t:             {{ "post.read_time" | t: page.lang, n: 12 }}
# - localize:      {{ project.description | localize: page.lang }}
# - localize_date: {{ page.date | localize_date: page.lang }}
# - posts_for:     {{ page.lang | posts_for }}, newest first: the posts in that
#                  language plus default-language posts not yet translated to it.

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

    # {{ date | localize_date: lang }}, or with "short_format" for no year.
    def localize_date(date, lang, format_key = "format")
      date = Jekyll::Utils.parse_date(date.to_s) unless date.respond_to?(:strftime)
      format = strings(lang).dig("date", format_key)
      month = strings(lang).dig("date", "months")[date.month - 1]
      date.strftime(format.gsub("%b", month))
    end

    def posts_for(lang)
      site = @context.registers[:site]
      default = site.config["default_lang"]
      site.posts.docs.reverse.select do |post|
        post_lang = post.data["lang"]
        post_lang == lang || (post_lang == default && !post.data.dig("translations", lang))
      end
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
