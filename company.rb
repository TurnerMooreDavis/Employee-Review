require "./db_setup"

class Company < ActiveRecord::Base
has_many :departments

  def add_department(department)
    departments << department
  end

  def most_employees
    number = 0
    department = nil
    self.departments.each do |dep|
      if number < dep.employees.count
        number = dep.employees.count
        department = dep
      end
    end
    return department
  end
end
