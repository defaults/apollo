require 'nokogiri'

module Apollo
  module ContentEnhancements
    LANGUAGE_LABELS = {
      'bash' => 'Bash',
      'console' => 'Console',
      'css' => 'CSS',
      'diff' => 'Diff',
      'html' => 'HTML',
      'javascript' => 'JavaScript',
      'js' => 'JavaScript',
      'json' => 'JSON',
      'liquid' => 'Liquid',
      'markdown' => 'Markdown',
      'md' => 'Markdown',
      'python' => 'Python',
      'ruby' => 'Ruby',
      'rust' => 'Rust',
      'scss' => 'SCSS',
      'shell' => 'Shell',
      'sh' => 'Shell',
      'terminal' => 'Terminal',
      'typescript' => 'TypeScript',
      'ts' => 'TypeScript',
      'yaml' => 'YAML',
      'yml' => 'YAML'
    }.freeze

    module_function

    def enabled?(page, site_config, key)
      page_value = page.data[key] if page.respond_to?(:data) && page.data
      return page_value unless page_value.nil?

      apollo_config = site_config['apollo'] || {}
      feature_config = apollo_config['features'] || {}
      apollo_config[key] == true || feature_config[key] == true
    end

    def language_from_class(class_name)
      class_name.to_s.split.find { |value| value.start_with?('language-') }&.sub(/^language-/, '')
    end

    def language_label(language)
      LANGUAGE_LABELS.fetch(language, language.to_s.split(/[-_]/).map(&:capitalize).join(' '))
    end

    def class_xpath(class_name)
      "contains(concat(' ', normalize-space(@class), ' '), ' #{class_name} ')"
    end
  end
end

Jekyll::Hooks.register [:pages, :documents], :post_render do |page|
  next unless page.output_ext == '.html'
  next unless page.output

  site_config = page.respond_to?(:site) && page.site ? page.site.config : {}
  mermaid_enabled = Apollo::ContentEnhancements.enabled?(page, site_config, 'mermaid')
  doc = Nokogiri.const_defined?(:HTML5) ? Nokogiri::HTML5(page.output) : Nokogiri::HTML(page.output)
  modified = false

  doc.xpath("//*[local-name()='div' and #{Apollo::ContentEnhancements.class_xpath('highlighter-rouge')}]").each do |block|
    language = Apollo::ContentEnhancements.language_from_class(block['class'])
    next unless language

    code_node = block.at_xpath(".//*[local-name()='pre']/*[local-name()='code']")
    next unless code_node

    if language == 'mermaid' && mermaid_enabled
      mermaid_node = Nokogiri::XML::Node.new('pre', doc)
      mermaid_node['class'] = 'mermaid'
      mermaid_node.content = code_node.text
      block.replace(mermaid_node)
      modified = true
      next
    end

    next if block['class'].to_s.include?('code-block')

    block['class'] = "#{block['class']} code-block"
    block['data-language'] = language

    header = Nokogiri::XML::Node.new('div', doc)
    header['class'] = 'code-block-header'

    label = Nokogiri::XML::Node.new('span', doc)
    label['class'] = 'code-block-language'
    label.content = Apollo::ContentEnhancements.language_label(language)

    button = Nokogiri::XML::Node.new('button', doc)
    button['class'] = 'code-copy-button'
    button['type'] = 'button'
    button['aria-label'] = 'Copy code'
    button.content = 'Copy'

    header.add_child(label)
    header.add_child(button)
    block.prepend_child(header)
    modified = true
  end

  if mermaid_enabled
    doc.xpath("//*[local-name()='pre']/*[local-name()='code' and #{Apollo::ContentEnhancements.class_xpath('language-mermaid')}]").each do |code_node|
      pre_node = code_node.parent
      mermaid_node = Nokogiri::XML::Node.new('pre', doc)
      mermaid_node['class'] = 'mermaid'
      mermaid_node.content = code_node.text
      pre_node.replace(mermaid_node)
      modified = true
    end
  end

  page.output = doc.to_html if modified
end
