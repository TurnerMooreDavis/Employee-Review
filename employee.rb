class Employee
  attr_reader :name, :salary
  def initialize(name:, email:"", phone_number: 000-000-0000, salary: 0)
    @name = name
    @salary = salary
  end
end
