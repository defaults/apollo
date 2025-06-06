source "https://rubygems.org"

gem "jekyll", "~> 4.3.4"
gem "webrick", "~> 1.8.1"
gem "jekyll-feed", "~> 0.17.0"
gem "jekyll-seo-tag", "~> 2.8.0"
gem "jekyll-watch", "~> 2.2.1"
gem "sass-embedded", "~> 1.77.0"
gem "jekyll-sass-converter", "~> 3.0.0"

group :jekyll_plugins do
  gem "kramdown-parser-gfm"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.1", :platforms => [:mswin, :mingw, :x64_mingw]

# Lock `http_parser.rb` gem to `v0.6.x` on JRuby builds since newer versions of the gem
# do not have a Java counterpart.
gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby] 