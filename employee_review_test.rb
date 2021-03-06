require 'minitest/autorun'
require 'minitest/pride'
require "./db_setup"
require "./employee.rb"
require "./department.rb"
require "./company.rb"
require "./company_migration.rb"
require "./employee_migration.rb"
require "./department_migration.rb"

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)
ActiveRecord::Migration.verbose = false
class ReviewTest < Minitest::Test


  def setup
    DepartmentMigration.migrate(:up)
    EmployeeMigration.migrate(:up)
    CompanyMigration.migrate(:up)
  end

  def teardown
    DepartmentMigration.migrate(:down)
    EmployeeMigration.migrate(:down)
    CompanyMigration.migrate(:down)
  end

  def test_classes_exist
    assert Employee
    assert Department
  end

  def test_classes_have_names
    assert_equal "engineering", Department.create(name: "engineering").name
    assert_equal "Ryan", Employee.create(name:"Ryan").name
  end

  def test_employee_inputs
    assert Employee.create(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
  end

  def test_add_employee_to_department
    fred = Employee.create(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    eng = Department.create(name: "engineering")
    eng.add_employee(fred)
    assert eng.employees
  end

  def test_departments_have_employees
    fred = Employee.create(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    eng = Department.create(name: "engineering")
    eng.add_employee(fred)
    assert_equal "Freddy", eng.employees.first.name
  end

  def test_retrieve_info
    fred = Employee.create(email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000, name: "Freddy")
    mary = Employee.create(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    eng = Department.create(name: "engineering")
    assert_equal "Freddy", fred.name
    assert_equal 70000, mary.salary
    assert_equal "engineering", eng.name
  end

  def test_total_salaries
    fred = Employee.create(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    mary = Employee.create(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    eng = Department.create(name: "engineering")
    eng.add_employee(fred)
    eng.add_employee(mary)
    assert_equal fred.salary+mary.salary, eng.total_dep_salaries
    assert_equal 125000, eng.total_dep_salaries

  end

  def test_add_review
    mary = Employee.create(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    mary.add_review("this is some review text")
    assert_equal "this is some review text", mary.review
  end

  def test_employee_satisfactory?
    mary = Employee.create(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    mary.is_satisfactory(true)
    assert mary.satisfactory
    fred = Employee.create(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    fred.is_satisfactory(false)
    refute fred.satisfactory
  end

  def test_give_single_raise
    mary = Employee.create(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    mary.give_raise(7000)
    assert_equal 77000, mary.salary
  end

  def test_give_department_raise_based_on_satisfactory
    fred = Employee.create(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    mary = Employee.create(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    jordan = Employee.create(name: "Jordan", email: "jordan@gmail.com", phone_number: 919-434-5602, salary: 60000)
    eng = Department.create(name: "engineering")
    eng.add_employee(jordan)
    jordan.is_satisfactory(true)
    eng.add_employee(fred)
    fred.is_satisfactory(false)
    eng.add_employee(mary)
    mary.is_satisfactory(true)
    eng.give_raises(50000) do |emp|
      emp.satisfactory == true
    end
    assert_equal 95000, mary.salary
    assert_equal 85000, jordan.salary
  end

  def test_give_department_raise_based_on_criteria
    fred = Employee.create(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    mary = Employee.create(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    jordan = Employee.create(name: "Jordan", email: "jordan@gmail.com", phone_number: 919-434-5602, salary: 60000)
    eng = Department.create(name: "engineering")
    eng.add_employee(jordan)
    jordan.is_satisfactory(true)
    eng.add_employee(fred)
    fred.is_satisfactory(false)
    eng.add_employee(mary)
    mary.is_satisfactory(true)
    eng.give_raises (50000) do |emp|
      emp.name == "Freddy"
    end
    assert_equal 105000, fred.salary
  end

  def test_analyze_can_calculate_sentance_score
    fred = Employee.create(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    fred.add_review("NEGATIVE REVIEW 1:

    Zeke is a very positive person and encourages those around him, but he has not encourage done well technically this year encourage.  There are two areas in which Zeke has room for improvement.  First, when communicating verbally (and sometimes in writing), he has a tendency to use more words than are required.  This conversational style does put people at ease, which is valuable, but it often makes the meaning difficult to isolate, and can cause confusion.

    Second, when discussing new requirements with project managers, less of the information is retained by Zeke long-term than is expected.  This has a few negative consequences: 1) time is spent developing features that are not useful and need to be re-run, 2) bugs are introduced in the code and not caught because the tests lack the same information, and 3) clients are told that certain features are complete when they are inadequate.  This communication limitation could be the fault of project management, but given that other developers appear to retain more information, this is worth discussing further.")
    assert_equal -2, fred.analyze(fred.review)
  end
  #
  def test_calculate_score_for_whole_review
    fred = Employee.create(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    fred.add_review("NEGATIVE REVIEW 1:

    Zeke is a very positive person and encourages those around him, but he has not encourage done well technically this year encourage.  There are two areas in which Zeke has room for improvement.  First, when communicating verbally (and sometimes in writing), he has a tendency to use more words than are required.  This conversational style does put people at ease, which is valuable, but it often makes the meaning difficult to isolate, and can cause confusion.

    Second, when discussing new requirements with project managers, less of the information is retained by Zeke long-term than is expected.  This has a few negative consequences: 1) time is spent developing features that are not useful and need to be re-run, 2) bugs are introduced in the code and not caught because the tests lack the same information, and 3) clients are told that certain features are complete when they are inadequate.  This communication limitation could be the fault of project management, but given that other developers appear to retain more information, this is worth discussing further.")
    assert_equal -2, fred.calculate_score {|sentance| fred.analyze(sentance)}
    mary = Employee.create(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    mary.add_review("Xavier is a huge asset to SciMed and is a pleasure to work with.  He quickly knocks out tasks assigned to him, implements code that rarely needs to be revisited, and is always willing to help others despite his heavy workload.  When Xavier leaves on vacation, everyone wishes he didn't have to go

    Last year, the only concerns with Xavier performance were around ownership.  In the past twelve months, he has successfully taken full ownership of both Acme and Bricks, Inc.  Aside from some false starts with estimates on Acme, clients are happy with his work and responsiveness, which is everything that his managers could ask for.")
    assert_equal 6, mary.calculate_score {|sentance| mary.analyze(sentance)}

  end

  def test_calculate_score_can_use_other_methods
    fred = Employee.create(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    fred.add_review("NEGATIVE REVIEW 1:

    Zeke is a very positive person and encourages those around him, but he has not encourage done well technically this year encourage.  There are two areas in which Zeke has room for improvement.  First, when communicating verbally (and sometimes in writing), he has a tendency to use more words than are required.  This conversational style does put people at ease, which is valuable, but it often makes the meaning difficult to isolate, and can cause confusion.

    Second, when discussing new requirements with project managers, less of the information is retained by Zeke long-term than is expected.  This has a few negative consequences: 1) time is spent developing features that are not useful and need to be re-run, 2) bugs are introduced in the code and not caught because the tests lack the same information, and 3) clients are told that certain features are complete when they are inadequate.  This communication limitation could be the fault of project management, but given that other developers appear to retain more information, this is worth discussing further.")
    assert_equal 1, fred.calculate_score {|sentance| 1}
  end

  def test_total_number_of_employees_in_a_department
    fred = Employee.create(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    mary = Employee.create(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    eng = Department.create(name: "engineering")
    eng.add_employee(fred)
    eng.add_employee(mary)
    assert_equal 2, eng.number_of_employees
  end

  def test_employee_who_is_paid_least
    fred = Employee.create(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    mary = Employee.create(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    eng = Department.create(name: "engineering")
    eng.add_employee(fred)
    eng.add_employee(mary)
    assert_equal fred, eng.paid_least
  end

  def test_employees_ordered_by_name
    fred = Employee.create(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    mary = Employee.create(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    jordan = Employee.create(name: "Jordan", email: "jordan@gmail.com", phone_number: 919-434-5602, salary: 60000)
    eng = Department.create(name: "engineering")
    eng.add_employee(jordan)
    eng.add_employee(fred)
    eng.add_employee(mary)
    assert_equal [fred,jordan,mary], eng.alphabetize
  end

  def test_return_higher_than_average_salaries
    fred = Employee.create(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    mary = Employee.create(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    jordan = Employee.create(name: "Jordan", email: "jordan@gmail.com", phone_number: 919-434-5602, salary: 60000)
    bob = Employee.create(name: "bob", email: "bob@gmail.com", phone_number: 919-234-3661, salary: 70000)
    eng = Department.create(name: "engineering")
    eng.add_employee(jordan)
    eng.add_employee(fred)
    eng.add_employee(mary)
    eng.add_employee(bob)
    assert_equal [mary,bob], eng.above_average_salary
  end

  def test_name_palindrome
    fred = Employee.create(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    mary = Employee.create(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    jordan = Employee.create(name: "Jordan", email: "jordan@gmail.com", phone_number: 919-434-5602, salary: 60000)
    bob = Employee.create(name: "bob", email: "bob@gmail.com", phone_number: 919-234-3661, salary: 70000)
    eng = Department.create(name: "engineering")
    eng.add_employee(jordan)
    eng.add_employee(fred)
    eng.add_employee(mary)
    eng.add_employee(bob)
    assert_equal [bob], eng.name_is_palindrome
  end

  def test_compare_department_numbers
    fred = Employee.create(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    mary = Employee.create(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    jordan = Employee.create(name: "Jordan", email: "jordan@gmail.com", phone_number: 919-434-5602, salary: 60000)
    bob = Employee.create(name: "bob", email: "bob@gmail.com", phone_number: 919-234-3661, salary: 70000)
    eng = Department.create(name: "engineering")
    hr = Department.create(name: "hr")
    marketing = Department.create(name: "marketing")
    fun = Company.create(name: "FunCity")
    eng.add_employee(jordan)
    eng.add_employee(fred)
    hr.add_employee(mary)
    marketing.add_employee(bob)
    fun.add_department(eng)
    fun.add_department(hr)
    fun.add_department(marketing)
    assert_equal eng, fun.most_employees
  end

  def 









end
