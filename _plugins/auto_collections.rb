module Apollo
  class AutoCollections < Jekyll::Generator
    priority :high

    def generate(site)
      # Determine content directory (usually 'content' or 'examples/content')
      content_dir = site.config['collections_dir'] || 'content'
      base_path = File.join(site.source, content_dir)

      return unless File.directory?(base_path)

      # Find all directories starting with _ (Jekyll collection convention)
      Dir.glob(File.join(base_path, '_*')).each do |entry|
        next unless File.directory?(entry)
        
        # Extract collection name (e.g., _projects -> projects)
        collection_name = File.basename(entry).sub(/^_/, '')
        
        # Skip if already defined in _config.yml
        next if site.config['collections'].key?(collection_name)

        # 1. Register the collection
        site.config['collections'][collection_name] = {
          'output' => true,
          'permalink' => "/#{collection_name}/:slug/"
        }

        # 2. Set default layout to 'essay' if not already set
        site.config['defaults'] ||= []
        has_default = site.config['defaults'].any? { |d| d['scope']['type'] == collection_name }
        
        unless has_default
          site.config['defaults'] << {
            "scope" => { "path" => "", "type" => collection_name },
            "values" => { "layout" => "essay" }
          }
        end

        # 3. Initialize the collection object so Jekyll picks it up
        collection = Jekyll::Collection.new(site, collection_name)
        site.collections[collection_name] = collection
        
        # Jekyll 4.x: Read the collection content immediately
        collection.read if collection.respond_to?(:read)
      end
    end
  end
end
