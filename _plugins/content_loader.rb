module Jekyll
  class ContentLoader < Jekyll::Generator
    safe true
    priority :high

    def generate(site)
      content_dir = File.join(site.source, 'content')
      
      # Only load from content directory if it exists
      if Dir.exist?(content_dir)
        # Clear existing posts and pages to avoid duplicates
        site.posts.docs.clear
        site.pages.clear
        
        load_content_from_directory(site, content_dir)
      end
    end

    private

    def load_content_from_directory(site, content_dir)
      # Load all markdown files recursively from content directory
      Dir.glob(File.join(content_dir, '**', '*.md')).each do |file_path|
        process_content_file(site, file_path, content_dir)
      end
      
      # Sort posts by date (most recent first)
      site.posts.docs.sort_by! { |doc| doc.date }.reverse! if site.posts.docs.any?
    end
    
    def process_content_file(site, file_path, content_dir)
      # Get relative path from content directory
      relative_path = Pathname.new(file_path).relative_path_from(Pathname.new(content_dir)).to_s
      
      # Determine if this should be a post or page based on file location
      if relative_path.start_with?('blog/')
        # Files in blog/ directory become posts
        create_post(site, file_path)
      else
        # All other files become pages with URL based on file structure
        create_page(site, file_path, content_dir)
      end
    end
    
    def create_post(site, file_path)
      # Create a blog post
      doc = Jekyll::Document.new(file_path, {
        site: site,
        collection: site.posts
      })
      
      doc.read
      site.posts.docs << doc
    end
    
    def create_page(site, file_path, content_dir)
      # Create a page with URL based on file structure
      relative_path = Pathname.new(file_path).relative_path_from(Pathname.new(content_dir)).to_s
      
      # Get directory and filename
      dir_path = File.dirname(relative_path)
      filename = File.basename(file_path)
      
      # Create page
      page = Jekyll::Page.new(site, content_dir, dir_path == '.' ? '' : dir_path, filename)
      site.pages << page
    end
  end
end 