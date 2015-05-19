require "./db_setup"

class EmployeeMigration < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string :name
      t.decimal :salary, scale:2, precision:8
      t.string :email
      t.string :phone_number
      t.boolean  :satisfactory
    end
  end
end
