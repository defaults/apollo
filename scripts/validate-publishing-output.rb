#!/usr/bin/env ruby
# frozen_string_literal: true

require "rexml/document"

site_dir = ARGV[0] || File.join(Dir.pwd, "build", "site")
failures = []

def read_file(site_dir, relative_path, failures)
  path = File.join(site_dir, relative_path)
  unless File.file?(path)
    failures << "Missing #{relative_path}"
    return nil
  end

  File.read(path)
end

def assert_contains(content, pattern, message, failures)
  return if content && content.match?(pattern)

  failures << message
end

root_feed = read_file(site_dir, "feed.xml", failures)
essays_feed = read_file(site_dir, File.join("essays", "feed.xml"), failures)
essays_index = read_file(site_dir, File.join("essays", "index.html"), failures)
rich_demo = read_file(site_dir, File.join("essays", "rich-content-demo", "index.html"), failures)
fallback_demo = read_file(site_dir, File.join("essays", "social-fallback-demo", "index.html"), failures)
robots = read_file(site_dir, "robots.txt", failures)

read_file(site_dir, "sitemap.xml", failures)
read_file(site_dir, "llms.txt", failures)

if root_feed
  begin
    REXML::Document.new(root_feed)
  rescue REXML::ParseException => e
    failures << "feed.xml is not valid XML: #{e.message.lines.first&.strip}"
  end

  assert_contains(root_feed, %r{<feed xmlns="http://www\.w3\.org/2005/Atom"}, "feed.xml is not an Atom feed", failures)
  assert_contains(root_feed, %r{<link href="[^"]+/feed\.xml" rel="self" type="application/atom\+xml"}, "feed.xml missing self link", failures)
  assert_contains(root_feed, %r{<entry}, "feed.xml has no entries", failures)
end

if essays_feed
  begin
    REXML::Document.new(essays_feed)
  rescue REXML::ParseException => e
    failures << "essays/feed.xml is not valid XML: #{e.message.lines.first&.strip}"
  end

  assert_contains(essays_feed, %r{<feed xmlns="http://www\.w3\.org/2005/Atom"}, "essays/feed.xml is not an Atom feed", failures)
end

if essays_index
  assert_contains(essays_index, %r{href="[^"]*/essays/feed\.xml"}, "essays index missing visible collection feed link", failures)
  assert_contains(essays_index, %r{rel="alternate"[^>]+application/atom\+xml|application/atom\+xml[^>]+rel="alternate"}, "essays index missing alternate feed metadata", failures)
end

[["rich-content-demo", rich_demo], ["social-fallback-demo", fallback_demo]].each do |slug, html|
  next unless html

  assert_contains(html, %r{<link rel="canonical" href="https?://[^"]+"}, "#{slug} missing canonical URL", failures)
  assert_contains(html, %r{<meta property="og:image" content="https?://[^"]+"}, "#{slug} missing absolute og:image", failures)
  assert_contains(html, %r{<meta name="twitter:card" content="summary_large_image"}, "#{slug} missing large Twitter card", failures)
  assert_contains(html, %r{<meta name="twitter:image" content="https?://[^"]+"}, "#{slug} missing absolute twitter:image", failures)
end

if robots
  assert_contains(robots, %r{Sitemap: https?://[^/]+/sitemap\.xml}, "robots.txt missing absolute sitemap URL", failures)
end

if failures.empty?
  puts "Publishing validation passed for #{site_dir}"
else
  warn "Publishing validation failed:"
  failures.each { |failure| warn "- #{failure}" }
  exit 1
end
