require 'minitest/autorun'
require 'minitest/pride'
require "./db_setup"
require "./employee.rb"
require "./department.rb"
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
  end

  def teardown
    DepartmentMigration.migrate(:down)
    EmployeeMigration.migrate(:down)
  end

  def test_classes_exist
    assert Employee
    assert Department
  end

  def test_classes_have_names
    assert_equal "engineering", Department.new("engineering").name
    assert_equal "Ryan", Employee.new(name:"Ryan").name
  end

  def test_employee_inputs
    assert Employee.new(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
  end

  def test_add_employee_to_department
    fred = Employee.new(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    eng = Department.new("engineering")
    eng.add_employee(fred)
    assert eng.employees
  end

  def test_departments_have_employees
    fred = Employee.new(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    eng = Department.new("engineering")
    eng.add_employee(fred)
    assert eng.employees.include?("Freddy")
  end

  def test_retrieve_info
    fred = Employee.new(email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000, name: "Freddy")
    mary = Employee.new(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    eng = Department.new("engineering")
    assert_equal "Freddy", fred.name
    assert_equal 70000, mary.salary
    assert_equal "engineering", eng.name
  end

  def test_total_salaries
    fred = Employee.new(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    mary = Employee.new(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    eng = Department.new("engineering")
    eng.add_employee(fred)
    eng.add_employee(mary)
    assert_equal fred.salary+mary.salary, eng.total_dep_salaries
    assert_equal 125000, eng.total_dep_salaries

  end

  def test_add_review
    mary = Employee.new(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    mary.add_review("this is some review text")
    assert mary.reviews.include?("this is some review text")
  end

  def test_employee_satisfactory?
    mary = Employee.new(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    mary.is_satisfactory(true)
    assert mary.satisfactory
    fred = Employee.new(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    fred.is_satisfactory(false)
    refute fred.satisfactory
  end

  def test_give_single_raise
    mary = Employee.new(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    mary.give_raise(7000)
    assert_equal 77000, mary.salary
  end

  def test_give_department_raise_based_on_satisfactory
    fred = Employee.new(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    mary = Employee.new(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    jordan = Employee.new(name: "Jordan", email: "jordan@gmail.com", phone_number: 919-434-5602, salary: 60000)
    eng = Department.new("engineering")
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
    fred = Employee.new(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    mary = Employee.new(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    jordan = Employee.new(name: "Jordan", email: "jordan@gmail.com", phone_number: 919-434-5602, salary: 60000)
    eng = Department.new("engineering")
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

  def test_review_can_parse_text
    fred = Employee.new(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    fred.add_review("NEGATIVE REVIEW 1:

    Zeke is a very positive person and encourages those around him, but he has not done well technically this year.  There are two areas in which Zeke has room for improvement.  First, when communicating verbally (and sometimes in writing), he has a tendency to use more words than are required.  This conversational style does put people at ease, which is valuable, but it often makes the meaning difficult to isolate, and can cause confusion.

    Second, when discussing new requirements with project managers, less of the information is retained by Zeke long-term than is expected.  This has a few negative consequences: 1) time is spent developing features that are not useful and need to be re-run, 2) bugs are introduced in the code and not caught because the tests lack the same information, and 3) clients are told that certain features are complete when they are inadequate.  This communication limitation could be the fault of project management, but given that other developers appear to retain more information, this is worth discussing further.")
    fred.parse_review
    assert fred.parse_review
  end

  def test_review_can_return_sentances
    fred = Employee.new(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    fred.add_review("NEGATIVE REVIEW 1:

    Zeke is a very positive person and encourages those around him, but he has not done well technically this year.  There are two areas in which Zeke has room for improvement.  First, when communicating verbally (and sometimes in writing), he has a tendency to use more words than are required.  This conversational style does put people at ease, which is valuable, but it often makes the meaning difficult to isolate, and can cause confusion.

    Second, when discussing new requirements with project managers, less of the information is retained by Zeke long-term than is expected.  This has a few negative consequences: 1) time is spent developing features that are not useful and need to be re-run, 2) bugs are introduced in the code and not caught because the tests lack the same information, and 3) clients are told that certain features are complete when they are inadequate.  This communication limitation could be the fault of project management, but given that other developers appear to retain more information, this is worth discussing further.")
    fred.parse_review
    assert_equal 9, fred.parsed.length
  end

  def test_analyze_can_calculate_sentance_score
    fred = Employee.new(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    fred.add_review("NEGATIVE REVIEW 1:

    Zeke is a very positive person and encourages those around him, but he has not encourage done well technically this year encourage.  There are two areas in which Zeke has room for improvement.  First, when communicating verbally (and sometimes in writing), he has a tendency to use more words than are required.  This conversational style does put people at ease, which is valuable, but it often makes the meaning difficult to isolate, and can cause confusion.

    Second, when discussing new requirements with project managers, less of the information is retained by Zeke long-term than is expected.  This has a few negative consequences: 1) time is spent developing features that are not useful and need to be re-run, 2) bugs are introduced in the code and not caught because the tests lack the same information, and 3) clients are told that certain features are complete when they are inadequate.  This communication limitation could be the fault of project management, but given that other developers appear to retain more information, this is worth discussing further.")
    fred.parse_review
    assert_equal -2, fred.analyze(fred.parsed[7])
    assert_equal 1, fred.analyze(fred.parsed[5])
  end
  #
  def test_calculate_score_for_whole_review
    fred = Employee.new(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    fred.add_review("NEGATIVE REVIEW 1:

    Zeke is a very positive person and encourages those around him, but he has not encourage done well technically this year encourage.  There are two areas in which Zeke has room for improvement.  First, when communicating verbally (and sometimes in writing), he has a tendency to use more words than are required.  This conversational style does put people at ease, which is valuable, but it often makes the meaning difficult to isolate, and can cause confusion.

    Second, when discussing new requirements with project managers, less of the information is retained by Zeke long-term than is expected.  This has a few negative consequences: 1) time is spent developing features that are not useful and need to be re-run, 2) bugs are introduced in the code and not caught because the tests lack the same information, and 3) clients are told that certain features are complete when they are inadequate.  This communication limitation could be the fault of project management, but given that other developers appear to retain more information, this is worth discussing further.")
    fred.parse_review
    assert_equal -1, fred.calculate_score {|sentance| fred.analyze(sentance)}
    mary = Employee.new(name: "Mary", email: "mary@gmail.com", phone_number: 919-234-3662, salary: 70000)
    mary.add_review("Xavier is a huge asset to SciMed and is a pleasure to work with.  He quickly knocks out tasks assigned to him, implements code that rarely needs to be revisited, and is always willing to help others despite his heavy workload.  When Xavier leaves on vacation, everyone wishes he didn't have to go

    Last year, the only concerns with Xavier performance were around ownership.  In the past twelve months, he has successfully taken full ownership of both Acme and Bricks, Inc.  Aside from some false starts with estimates on Acme, clients are happy with his work and responsiveness, which is everything that his managers could ask for.")
    mary.parse_review
    assert_equal 6, mary.calculate_score {|sentance| mary.analyze(sentance)}

  end

  def test_calculate_score_can_use_other_methods
    fred = Employee.new(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    fred.add_review("NEGATIVE REVIEW 1:

    Zeke is a very positive person and encourages those around him, but he has not encourage done well technically this year encourage.  There are two areas in which Zeke has room for improvement.  First, when communicating verbally (and sometimes in writing), he has a tendency to use more words than are required.  This conversational style does put people at ease, which is valuable, but it often makes the meaning difficult to isolate, and can cause confusion.

    Second, when discussing new requirements with project managers, less of the information is retained by Zeke long-term than is expected.  This has a few negative consequences: 1) time is spent developing features that are not useful and need to be re-run, 2) bugs are introduced in the code and not caught because the tests lack the same information, and 3) clients are told that certain features are complete when they are inadequate.  This communication limitation could be the fault of project management, but given that other developers appear to retain more information, this is worth discussing further.")
    fred.parse_review
    assert_equal 9, fred.calculate_score {|sentance| 1}
  end

  def test_analyze_can_learn_new_words
    fred = Employee.new(name: "Freddy", email: "freddy@gmail.com", phone_number: 919-434-5612, salary: 55000)
    fred.add_review("NEGATIVE REVIEW 1:

    Zeke is a very positive person and encourages those around him, but he has not encourage done well technically this year encourage.  There are two areas in which Zeke has room for improvement.  First, when communicating verbally (and sometimes in writing), he has a tendency to use more words than are required.  This conversational style does put people at ease, which is valuable, but it often makes the meaning difficult to isolate, and can cause confusion.

    Second, when discussing new requirements with project managers, less of the information is retained by Zeke long-term than is expected.  This has a few negative consequences: 1) time is spent developing features that are not useful and need to be re-run, 2) bugs are introduced in the code and not caught because the tests lack the same information, and 3) clients are told that certain features are complete when they are inadequate.  This communication limitation could be the fault of project management, but given that other developers appear to retain more information, this is worth discussing further.")
    fred.parse_review
    assert_equal -2, fred.analyze(fred.parsed[7])

    fred.add_trigger_word(word:"bugs",positive:false)
    assert_equal -3, fred.analyze(fred.parsed[7])

    fred.add_trigger_word(word:"complete",positive:true)
    assert_equal -2, fred.analyze(fred.parsed[7])
  end














end
