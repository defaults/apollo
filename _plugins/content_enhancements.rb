require 'nokogiri'
require 'uri'

module Apollo
  module ContentEnhancements
    DIRECT_VIDEO_EXTENSIONS = %w[.m4v .mov .mp4 .ogg .webm].freeze

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

    def supported_host?(host, domain)
      host == domain || host.end_with?(".#{domain}")
    end

    def direct_video_path?(path)
      DIRECT_VIDEO_EXTENSIONS.any? { |extension| path.to_s.downcase.end_with?(extension) }
    end

    def video_embed(url)
      value = url.to_s.strip
      return nil if value.empty?

      uri = URI.parse(value)
      if uri.scheme.nil? && uri.host.nil?
        return nil unless direct_video_path?(uri.path)

        return { type: 'video', src: value, title: 'Video' }
      end

      return nil unless %w[http https].include?(uri.scheme&.downcase)

      host = uri.host.to_s.downcase.sub(/^www\./, '')
      path = uri.path.to_s
      youtube_id =
        if host == 'youtu.be'
          path.split('/')[1]
        elsif supported_host?(host, 'youtube.com')
          if path.start_with?('/embed/', '/shorts/')
            path.split('/')[2]
          elsif path == '/watch'
            URI.decode_www_form(uri.query.to_s).to_h['v']
          end
        end

      if youtube_id&.match?(/\A[A-Za-z0-9_-]{6,64}\z/)
        return {
          type: 'iframe',
          src: "https://www.youtube-nocookie.com/embed/#{youtube_id}",
          title: 'YouTube video'
        }
      end

      vimeo_id =
        if host == 'vimeo.com' && path.match?(%r{\A/\d+/?\z})
          path.delete_prefix('/').delete_suffix('/')
        elsif host == 'player.vimeo.com' && path.match?(%r{\A/video/\d+/?\z})
          path.split('/')[2]
        end

      if vimeo_id
        return {
          type: 'iframe',
          src: "https://player.vimeo.com/video/#{vimeo_id}",
          title: 'Vimeo video'
        }
      end

      return { type: 'video', src: value, title: 'Video' } if direct_video_path?(path)

      nil
    rescue ArgumentError, URI::InvalidURIError
      nil
    end

    def replace_video_placeholder(node, doc)
      embed = video_embed(node['data-video-src'])
      return false unless embed

      title = node['data-video-title'].to_s.empty? ? embed[:title] : node['data-video-title']
      caption = node['data-video-caption']
      credit = node['data-video-credit']
      layout = node['data-video-layout']

      figure = Nokogiri::XML::Node.new('figure', doc)
      figure['class'] = ['apollo-video', layout].compact.reject(&:empty?).join(' ')

      frame = Nokogiri::XML::Node.new('div', doc)
      frame['class'] = 'apollo-video-frame'

      if embed[:type] == 'iframe'
        iframe = Nokogiri::XML::Node.new('iframe', doc)
        iframe['src'] = embed[:src]
        iframe['title'] = title
        iframe['loading'] = 'lazy'
        iframe['referrerpolicy'] = 'strict-origin-when-cross-origin'
        iframe['allow'] = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share'
        iframe['allowfullscreen'] = 'allowfullscreen'
        frame.add_child(iframe)
      else
        video = Nokogiri::XML::Node.new('video', doc)
        video['src'] = embed[:src]
        video['controls'] = 'controls'
        video['preload'] = 'metadata'
        video['title'] = title
        frame.add_child(video)
      end

      figure.add_child(frame)
      if caption || credit
        figcaption = Nokogiri::XML::Node.new('figcaption', doc)
        figcaption.add_child(Nokogiri::HTML.fragment(caption.to_s)) if caption
        if credit
          credit_node = Nokogiri::XML::Node.new('span', doc)
          credit_node['class'] = 'figure-credit'
          credit_node.add_child(Nokogiri::HTML.fragment(credit))
          figcaption.add_child(credit_node)
        end
        figure.add_child(figcaption)
      end

      node.replace(figure)
      true
    end

    def standalone_video_url(paragraph)
      children = paragraph.children.reject { |child| child.text? && child.text.strip.empty? }
      return nil unless children.size == 1

      child = children.first
      value = child.element? && child.name == 'a' ? child['href'] : child.text
      value if video_embed(value)
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

  doc.css('.apollo-video[data-video-src]').each do |node|
    modified = true if Apollo::ContentEnhancements.replace_video_placeholder(node, doc)
  end

  doc.xpath("//*[local-name()='article']//*[local-name()='p']").each do |paragraph|
    video_url = Apollo::ContentEnhancements.standalone_video_url(paragraph)
    next unless video_url

    placeholder = Nokogiri::XML::Node.new('div', doc)
    placeholder['class'] = 'apollo-video'
    placeholder['data-video-src'] = video_url
    paragraph.add_next_sibling(placeholder)
    modified = true if Apollo::ContentEnhancements.replace_video_placeholder(placeholder, doc)
    paragraph.remove
  end

  page.output = doc.to_html if modified
end
