module Apollo
  class FeedCollectionsNormalizer < Jekyll::Generator
    safe true
    priority :high

    def generate(site)
      feed_config = site.config["feed"] ||= {}
      collections = feed_config["collections"]

      names = case collections
              when Hash
                collections.keys
              when Array
                collections
              else
                []
              end

      names = names.map(&:to_s).uniq

      if names.empty?
        names =
          if site.collections.key?("essays")
            ["essays"]
          elsif site.collections.key?("posts")
            ["posts"]
          else
            []
          end
      end

      feed_config["apollo_collections"] = names
      site.data["apollo_feed_entries"] = names.flat_map do |name|
        collection = site.collections[name]
        collection ? collection.docs : []
      end
    end
  end
end
