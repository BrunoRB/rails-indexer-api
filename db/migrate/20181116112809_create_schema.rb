class CreateSchema < ActiveRecord::Migration[5.2]
  def change
    create_table :pages do |t|
      t.string :url, null: false, index: {unique: true}

      t.timestamps
    end

    create_table :indexeds do |t|
      t.belongs_to :pages, null: false, index: true, foreign_key: true
      t.string :c_type, null: false
      t.text :content, null: false

      t.timestamps
    end
  end
end
