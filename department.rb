require "byebug"
require "./db_setup"
class Department < ActiveRecord::Base
has_many :employees
  def add_employee(employee)
    employees << employee
  end

  def total_dep_salaries
    total_salaries = 0
    self.employees.each do |emp|
      total_salaries += emp.salary.to_f
    end
    return total_salaries
  end

  def give_raises (amount)
    eligible_employees = self.employees.select {|emp| yield(emp)}
    eligible_employees.each do |emp|
      emp.salary += amount/eligible_employees.length
    end
  end


end
