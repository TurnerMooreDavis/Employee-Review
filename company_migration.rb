require "./db_setup"

class CompanyMigration < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
    end
  end
end
