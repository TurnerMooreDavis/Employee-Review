require "./db_setup"

class DepartmentMigration < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :name
      t.integer :employee_id
    end
  end
end
