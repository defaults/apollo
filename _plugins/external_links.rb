require 'nokogiri'

Jekyll::Hooks.register [:pages, :documents], :post_render do |page|
  # Only process HTML output
  next unless page.output_ext == '.html'
  next unless page.output
  
  doc = Nokogiri.const_defined?(:HTML5) ? Nokogiri::HTML5(page.output) : Nokogiri::HTML(page.output)
  modified = false

  # Find all links except those in nav/header
  doc.css('a').each do |link|
    # Skip if link is in nav or header
    next if link.ancestors('nav').any? || link.ancestors('header').any?
    
    href = link['href']
    next unless href

    # Check if link is external (doesn't start with / or #)
    if !href.start_with?('/') && !href.start_with?('#') && !href.start_with?('mailto:')
      link['target'] = '_blank'
      link['rel'] = 'noopener noreferrer'
      modified = true
    end
  end

  page.output = doc.to_html if modified
end
