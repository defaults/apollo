#!/usr/bin/env ruby
# Generate favicons and app icons from site name
# Usage: ruby scripts/generate-favicon.rb "Your Name"

require 'fileutils'

name = ARGV[0] || ENV['SITE_NAME'] || 'Apollo'
letter = name[0].upcase

# Base colors - Paper theme
bg_color = '#f0eee6'  # Paper ivory
text_color = '#1f1e1d'  # Paper slate

# Generate icon.svg (primary favicon, used by modern browsers)
svg_content = <<~SVG
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <rect width="100" height="100" fill="#{bg_color}"/>
  <text x="50" y="72" font-family="Georgia, serif" font-size="68" font-weight="700" fill="#{text_color}" text-anchor="middle">#{letter}</text>
</svg>
SVG

output_path = 'assets/images/icon.svg'
FileUtils.mkdir_p(File.dirname(output_path))
File.write(output_path, svg_content)

puts "✓ Generated #{output_path} with letter '#{letter}'"
