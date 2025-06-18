module Jekyll
  class ContentLoader < Jekyll::Generator
    safe true
    priority :high

    def generate(site)
      # Check if content directory exists and user wants local content
      content_source = site.config.dig('content', 'source') || 'local'
      content_dir = File.join(site.source, 'content')
      
      if content_source == 'local' && Dir.exist?(content_dir)
        load_content_from_directory(site, content_dir)
      end
      
      # Load user pages from content/pages if they exist
      pages_dir = File.join(content_dir, 'pages')
      if Dir.exist?(pages_dir)
        load_pages_from_directory(site, pages_dir)
      end
    end

    private

    def load_content_from_directory(site, content_dir)
      posts_dir = File.join(content_dir, 'posts')
      return unless Dir.exist?(posts_dir)

      # Clear existing posts if we're using content directory
      site.posts.docs.clear

      # Load posts from content directory
      Dir.glob(File.join(posts_dir, '*.md')).each do |post_path|
        # Create a new post document using Jekyll's standard method
        relative_path = Pathname.new(post_path).relative_path_from(Pathname.new(site.source)).to_s
        
        # Create document with proper initialization
        doc = Jekyll::Document.new(post_path, {
          site: site,
          collection: site.posts
        })
        
        # Read and process the document
        doc.read
        
        # Add to posts collection
        site.posts.docs << doc
      end
      
      # Sort posts by date (most recent first)
      site.posts.docs.sort_by! { |doc| doc.date }.reverse!
    end

    def load_pages_from_directory(site, pages_dir)
      Dir.glob(File.join(pages_dir, '*.md')).each do |page_path|
        # Skip if page already exists in _pages
        page_name = File.basename(page_path)
        existing_page = site.pages.find { |p| File.basename(p.path) == page_name }
        next if existing_page

        # Get relative path from site source
        relative_dir = Pathname.new(File.dirname(page_path)).relative_path_from(Pathname.new(site.source)).to_s
        
        # Create new page using Jekyll's Page class
        page = Jekyll::Page.new(site, site.source, relative_dir, page_name)
        site.pages << page
      end
    end
  end
end 