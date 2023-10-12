require "net/http"
require "nokogiri"
require "open-uri"
require "sinatra"

get "/:publication_name/:article_slug" do
  publication_name = params[:publication_name]
  article_slug = params[:article_slug]
  url = "https://#{publication_name}.substack.com/p/#{article_slug}"
  cached_fetch(url)
end

def cached_fetch(url)
  content = settings.cache.get(url)

  unless content
    content = fetch_metadata_and_render(url)
    settings.cache.set(url, content, 3600)
  end

  content
end

def fetch_metadata_and_render(url)
  uri = URI(url)
  response = Net::HTTP.get_response(uri)
  page = Nokogiri::HTML(response.body) if response.is_a?(Net::HTTPSuccess)
  meta_tags = page.css("meta")

  twitter_card_properties = [
    "twitter:card",
    "twitter:site",
    "twitter:creator",
    "twitter:title",
    "twitter:description",
    "twitter:image",
    "twitter:image:alt"
  ]

  meta_data = meta_tags.each_with_object({}) do |meta, hash|
    property = meta.attr("property") || meta.attr("name")
    content = meta.attr("content")

    if property && content && twitter_card_properties.include?(property)
      hash[property] = content
    end
  end

  erb :index, locals: {meta_data: meta_data, url: url}
end
