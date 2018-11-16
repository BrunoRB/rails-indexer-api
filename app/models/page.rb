class Page < ApplicationRecord
  validates :url, presence: true
  validates :url, format: { with: URI.regexp }
end
