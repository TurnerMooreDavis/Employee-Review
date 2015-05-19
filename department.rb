require "byebug"
require "./db_setup"
class Department < ActiveRecord::Base
has_many :employees
  def add_employee(employee)
    employees << employee
  end

  def number_of_employees
    self.employees.length
  end

  def paid_least
    number = 100000000
    person = nil
    self.employees.each do |emp|
      if number > emp.salary
        number = emp.salary
        person = emp
      end
    end
    return person
  end

  def alphabetize
    result = self.employees.sort {|x,y| x.name <=> y.name}
    return result
  end

  def above_average_salary
    average = self.total_dep_salaries/employees.length
    result = self.employees.select {|emp| emp.salary > average}
    return result
  end

  def name_is_palindrome
    result = employees.select {|emp| emp.name == emp.name.reverse}
    return result
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
