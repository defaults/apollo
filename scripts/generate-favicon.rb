#!/usr/bin/env ruby
# Generate a simple letter-based favicon from site name
# Usage: ruby scripts/generate-favicon.rb "Vikash Kumar"

require 'fileutils'

name = ARGV[0] || ENV['SITE_NAME'] || 'Apollo'
letter = name[0].upcase

svg_content = <<~SVG
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <rect width="100" height="100" fill="#FFFCF0"/>
  <text x="50" y="70" font-family="Georgia, serif" font-size="60" font-weight="700" fill="#100F0F" text-anchor="middle">#{letter}</text>
</svg>
SVG

output_path = 'assets/images/icon.svg'
FileUtils.mkdir_p(File.dirname(output_path))
File.write(output_path, svg_content)

puts "Generated favicon with letter '#{letter}' -> #{output_path}"

