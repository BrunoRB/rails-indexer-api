class IndexedResource < JSONAPI::Resource
  # http://jsonapi-resources.com/v0.9/guide/resources.html#Immutable-Resources
  immutable

  attributes :c_type, :content, :url
  relationship :pages, to: :one, foreign_key: "pages_id", class_name: 'Page'#, always_include_linkage_data: true

  def url
    @model.pages.url
  end
end