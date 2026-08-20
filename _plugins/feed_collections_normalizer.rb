module Apollo
  class FeedCollectionsNormalizer < Jekyll::Generator
    safe true
    priority :high

    def generate(site)
      feed_config = site.config["feed"] ||= {}
      collections = feed_config["collections"]

      collection_config = case collections
                          when Hash
                            collections
                          when Array
                            collections.each_with_object({}) do |name, memo|
                              memo[name.to_s] = default_collection_feed(name)
                            end
                          else
                            {}
                          end

      names = collection_config.keys.map(&:to_s).uniq

      if names.empty?
        names =
          if site.collections.key?("essays")
            ["essays"]
          elsif site.collections.key?("posts")
            ["posts"]
          else
            []
          end

        names.each do |name|
          collection_config[name] = default_collection_feed(name)
        end
      end

      feed_config["collections"] = collection_config
      feed_config["apollo_collections"] = names
      site.data["apollo_feed_entries"] = names.flat_map do |name|
        collection = site.collections[name]
        collection ? collection.docs : []
      end
    end

    private

    def default_collection_feed(name)
      { "path" => "/#{name}/feed.xml" }
    end
  end
end
