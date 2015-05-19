require "./db_setup"

class ReviewMigration < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.text :review
      t.text :parsed_text
    end
  end
end
