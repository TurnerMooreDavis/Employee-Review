require "./db_setup"

class DepartmentMigration < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :name
      t.references :company
    end
  end
end
