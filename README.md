# Employee-Review



##Description
  Employee-Review is designed to create digital profiles for each employee, assign them to a department and then give raises.  It can also read reviews, give them a score based on word selection.  Built in is the ability to use blocks to decide how to allocate raises and how to grade reviews

##How to Use Employee-Review

* First, `require` `"employee.rb"` and `"department.rb"`

* To create a new employee, simply type `Employee.new` with required paramenters of `name` and `salary` and optional parameters of `phone_number` and `email`.
* Create a department with  `Department.new` wand a single required parameter, `name`

* on the employee object you can  `add_review`,`give_raise`, `parse_review`. The `calculate_score` method can also be called, but requires a block that returns a single integer.  The `analyze` method can be used if no other options are available.

* on the department object you can `add_employee`, `total_department_salaries` and `give_raises` which requires a block that can return a list of eligible employees.

##Challenges

The most challenging aspect of this project was grappling with the blocks and lambda and getting them to work in a variety of situations.  I had to revisit and scrap a good amount of my work part way through, in order to construct `calculate_score` the way I wanted; with the ability to take in any block that spat out a number.  Second to that, figuring out how to grade the reviews was difficult because I could not decide on a formula that worked for me, so in the end I decided to use a simple one and write my other methods in such a way that it could be replaced later with a better analyze method!
