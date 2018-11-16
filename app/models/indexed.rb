class Indexed < ApplicationRecord
  belongs_to :pages, foreign_key: "pages_id", class_name: 'Page'

  validates :c_type, presence: true
  validates :content, presence: true
  validates :pages_id, presence: true
end
