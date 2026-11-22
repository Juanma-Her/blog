# frozen_string_literal: true

# Content checks run by CI before the build (JSON contracts 8, Design document 13.1).
#
#   bundle exec ruby scripts/validate.rb           posts and data files
#   bundle exec ruby scripts/validate.rb --feeds   built feeds in _site/ (after the build)
#
# Prints one line per problem, "<file>: <problem>", and exits with 1 if there is any.

require "date"
require "json"
require "json_schemer"
require "rexml/document"
require "yaml"

ROOT = File.expand_path("..", __dir__)
SITE = File.join(ROOT, "src") # Jekyll's source (_config.yml: source)
LANGUAGES = %w[en es].freeze

def relative(path) = path.delete_prefix("#{ROOT}/")
def read_json(path) = JSON.parse(File.read(path))
def schema(name) = JSONSchemer.schema(Pathname(File.join(ROOT, "schemas", name)))

# Schema errors as "<json pointer> <reason>"; the pointer is "/" for the whole document.
def schema_problems(name, data)
  schema(name).validate(data).map do |error|
    pointer = error["data_pointer"].empty? ? "/" : error["data_pointer"]
    "#{pointer} #{error['error']}"
  end
end

# YAML dates become strings, so the schema sees what the author wrote.
def plain(value)
  case value
  when Hash then value.transform_values { |v| plain(v) }
  when Array then value.map { |v| plain(v) }
  when Time then value.strftime("%Y-%m-%d %H:%M:%S %z")
  when Date then value.iso8601
  else value
  end
end

def front_matter(path)
  yaml = File.read(path)[/\A---\s*\n(.*?)\n---\s*\n/m, 1]
  plain(YAML.safe_load(yaml.to_s, permitted_classes: [Date, Time]) || {})
end

# "a.b.c" for every leaf of a nested strings file.
def keys(hash, prefix = nil)
  hash.flat_map do |key, value|
    path = [prefix, key].compact.join(".")
    value.is_a?(Hash) ? keys(value, path) : [path]
  end
end

def check_content
  problems = []
  report = ->(file, problem) { problems << "#{file}: #{problem}" }

  topics = read_json(File.join(SITE, "_data/topics.json"))
  schema_problems("topics.schema.json", topics).each { |p| report.call("src/_data/topics.json", p) }

  # Posts
  refs = Hash.new { |hash, key| hash[key] = [] }
  Dir[File.join(SITE, "_posts/*/*.md")].sort.each do |path|
    file = relative(path)
    folder = File.basename(File.dirname(path))
    data = front_matter(path)
    schema_problems("post.schema.json", data).each { |p| report.call(file, p) }

    report.call(file, %(lang "#{data['lang']}" does not match folder "#{folder}")) if data["lang"] && data["lang"] != folder
    report.call(file, %(folder "#{folder}" is not a language (#{LANGUAGES.join(', ')}))) unless LANGUAGES.include?(folder)

    Array(data["tags"]).each_with_index do |tag, i|
      report.call(file, %(tags[#{i}] "#{tag}" is not a topic in src/_data/topics.json)) unless topics.key?(tag)
    end
    primary = Array(data["tags"]).first
    if primary && topics.dig(primary, "hidden")
      report.call(file, %(tags[0] "#{primary}" is a hidden tag; the first tag must be a topic with a colour))
    end

    file_date = File.basename(path)[/\A\d{4}-\d{2}-\d{2}/]
    if data["date"].is_a?(String) && !data["date"].start_with?(file_date.to_s)
      report.call(file, %(date "#{data['date']}" does not match the file name date "#{file_date}"))
    end
    lines = data.dig("hero_code", "code").to_s.lines.size
    report.call(file, "/hero_code/code has #{lines} lines, at most 12") if lines > 12

    refs[[data["ref"], folder]] << file if data["ref"]
  end
  refs.each do |(ref, lang), files|
    problems << %(ref "#{ref}" has two posts in "#{lang}": #{files.join(', ')}) if files.size > 1
  end
  post_refs = refs.keys.map(&:first)

  # Projects
  projects = read_json(File.join(SITE, "_data/projects.json"))
  schema_problems("projects.schema.json", projects).each { |p| report.call("src/_data/projects.json", p) }
  list = Array(projects["projects"])
  featured = list.count { |project| project["featured"] }
  report.call("src/_data/projects.json", "exactly one featured project required, found #{featured}") unless featured == 1
  list.each_with_index do |project, i|
    links = project["links"] || {}
    unless links["codeberg"] || links["github"] || links["team"]
      report.call("src/_data/projects.json", "projects[#{i}] needs links.codeberg, links.github or links.team")
    end
    if links["writeup"] && !post_refs.include?(links["writeup"])
      report.call("src/_data/projects.json", %(projects[#{i}] links.writeup "#{links['writeup']}" is not the ref of any post))
    end
  end

  # About
  about = read_json(File.join(SITE, "_data/about.json"))
  schema_problems("about.schema.json", about).each { |p| report.call("src/_data/about.json", p) }
  Array(about["skills"]).each_with_index do |skill, i|
    if skill["topic"] && !topics.key?(skill["topic"])
      report.call("src/_data/about.json", %(skills[#{i}] topic "#{skill['topic']}" is not a topic in src/_data/topics.json))
    end
  end

  # Strings
  strings = LANGUAGES.to_h { |lang| [lang, read_json(File.join(SITE, "_data/i18n/#{lang}.json"))] }
  strings.each do |lang, data|
    schema_problems("i18n.schema.json", data).each { |p| report.call("src/_data/i18n/#{lang}.json", p) }
  end
  LANGUAGES.permutation(2).each do |lang, other|
    (keys(strings[other]) - keys(strings[lang])).each do |key|
      report.call("src/_data/i18n/#{lang}.json", %(key "#{key}" missing (present in #{other}.json)))
    end
  end
  Array(about.dig("profile", "details")).each_with_index do |detail, i|
    unless strings["en"].dig("about", "details", detail["key"])
      report.call("src/_data/about.json", %(profile.details[#{i}] key "#{detail['key']}" has no string about.details.#{detail['key']}))
    end
  end

  problems
end

# Every Atom feed in _site/ parses and has entries (BLG-33).
def check_feeds
  feeds = Dir[File.join(ROOT, "_site/{,*/}feed.xml")] + Dir[File.join(ROOT, "_site/{,*/}feed/by_tag/*.xml")]
  return ["_site: no feeds found; run the build first"] if feeds.empty?

  feeds.sort.filter_map do |path|
    document = REXML::Document.new(File.read(path))
    entries = REXML::XPath.match(document, "//*[local-name()='entry']").size
    "#{relative(path)}: feed has no entries" if entries.zero?
  rescue REXML::ParseException => e
    "#{relative(path)}: not valid XML (#{e.message.lines.first.strip})"
  end
end

problems = ARGV.include?("--feeds") ? check_feeds : check_content
puts problems
exit(problems.empty? ? 0 : 1)
