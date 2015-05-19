require "byebug"
require "./db_setup"
class Department < ActiveRecord::Base
  attr_reader :name, :employees
  def initialize(name)
    @name = name
    @employees = {}
  end

  def add_employee(employee)
    key = employee.name
    @employees[key] = employee
  end

  def total_dep_salaries
    total_salaries = 0
    @employees.each do |key, object|
      total_salaries += object.salary.to_f
    end
    return total_salaries
  end

  def give_raises (amount)
    eligible_employees = @employees.select {|name, emp| yield(emp)}
    eligible_employees.each do |name, emp|
      emp.salary += amount/eligible_employees.length
    end
  end


end
