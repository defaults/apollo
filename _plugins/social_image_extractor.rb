module Jekyll
  class SocialImageExtractor < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      default_image = site.config["logo"]

      process_docs(site.posts.docs, site, default_image)
      process_docs(site.pages, site, default_image)
    end

    private

    def process_docs(docs, site, default_image)
      Array(docs).each do |doc|
        next if doc.data.key?("image") && doc.data["image"]

        image_from_content = extract_first_image(doc.content)
        if image_from_content
          doc.data["image"] = image_from_content
        elsif default_image
          doc.data["image"] = default_image
        end
      end
    end

    # Very small heuristic to find the first Markdown or HTML image
    def extract_first_image(content)
      return nil if content.nil? || content.empty?

      # Markdown image: ![alt](url)
      md_match = content.match(/!\[[^\]]*\]\(([^\)\s]+)(?:\s+"[^"]*")?\)/)
      return md_match[1] if md_match

      # HTML image: <img src="...">
      html_match = content.match(/<img\s+[^>]*src=["']([^"'>\s]+)["'][^>]*>/i)
      return html_match[1] if html_match

      nil
    end
  end
end



