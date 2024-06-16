--> explanation for scripts

--> filling branch_details table

Step 1: connect to DB
Step 2: in this example, we have generated 10 branches. do a for loop to run 10 times.
Step 3: use faker package to get branch_name (fake.company()) , address (fake.street_address()) and zipcode ( fake.postcode()) ) 
step 4: insert into table using this line -> 
		cursor.execute(
            "INSERT INTO branch_details (branch_name, address, zipcode) VALUES (%s, %s, %s);",
            (branch_name, address, zipcode),
        )

--> filling chauffeur table:

Step 1: connect to DB
Step 2: get all the branch_id from branch_details table into a variable.
	# Function to retrieve existing branch IDs from the 'branch_details' table
	def get_branch_ids(cursor):
		cursor.execute("SELECT branch_id FROM branch_details;")
		return [row[0] for row in cursor.fetchall()]
	# Get existing branch IDs
		branch_ids = get_branch_ids(cursor)

 
Step 3: inside a loop 
for _ in range(120):
  firstname = fake.first_name()
        lastname = fake.last_name()
        dateofbirth = fake.date_of_birth(minimum_age=21, maximum_age=60)
        license_number = fake.unique.random_int(min=10000, max=99999, step=1)
        branch_id = random.choice(branch_ids)

        cursor.execute(
            "INSERT INTO chauffeur (firstname, lastname, dateofbirth, license_number, branch_id) VALUES (%s, %s, %s, %s, %s);",
            (firstname, lastname, dateofbirth, license_number, branch_id),
        )

Step 4 : This will insert 120 chauffeurs in the chauffeur table.

--> Filling employee_details table:

Step 1: connect to DB
Step 2: get all the branch_id from branch_details table into a variable.
Step 3: loop through each branch and fill employee details using faker. 
# Populate the "employee_details" table with the specified department distribution
    for branch_id in branch_ids:
        # Assign employees to departments based on the specified distribution
        department_counts = {
            "HR": random.randint(1, 2),
            "Finance": random.randint(1, 2),
            "IT": 1,
            "Sales": random.randint(5, 10),
            "Maintenance": random.randint(5, 10),
            "Security": random.randint(2, 4),
        }

        for department, count in department_counts.items():
            for _ in range(count):
                first_name = fake.first_name()
                last_name = fake.last_name()
                dateofbirth = fake.date_of_birth(minimum_age=21,             maximum_age=60)

                cursor.execute(
                    "INSERT INTO employee_details (first_name, last_name, branch_id, dateofbirth, department) VALUES (%s, %s, %s, %s, %s);",
                    (first_name, last_name, branch_id, dateofbirth, department),
                )

Step 4: the age column in employee_details is automatically calculated from date_of_birth using a trigger.

--> Filling car_category table:

Step 1: connect to Db
Step 2: make up different car categories with details of car seating capacity and cost of rent per day.
these car categories are picked up from faker_vehichles package.
# Sample car category names and their corresponding details
car_categories = [
    ("Sedan", 5, 80.0),
    ("SUV", 7, 100.0),
    ("Van/Minivan", 8, 120.0),
    ("Hatchback", 4, 70.0),
    ("Wagon", 6, 90.0),
    ("Convertible", 2, 150.0),
    ("Coupe", 2, 110.0),
    ("Pickup", 4, 95.0),
]

Step 3: loop through the array and fill the table:
# Populate the "car_category" table with the specified data
    for category, seating_capacity, cost_per_day in car_categories:
        late_fee_per_hour = cost_per_day * 0.2  # Set late fee to 20% of cost per day

        cursor.execute(
            "INSERT INTO car_category (car_category_name, seating_capacity, cost_per_day, late_fee_per_hour) VALUES (%s, %s, %s, %s);",
            (category, seating_capacity, cost_per_day, late_fee_per_hour),
        )

--> Filling car table:

Step 1: connect to DB
Step 2: get all the branch_id from branch_details table into a variable.
Step 3: use faker_vehicle to get car details and insert it into car table. In each branch we add between 30 to 50 cars randomly. 
for branch_id in branch_ids:
        for _ in range(random.randint(30, 50)):
            temp_car = fake.vehicle_object()
            # print(temp_car["Category"])
            reg_no = fake.license_plate()
            car_category_name = temp_car["Category"].split(",")[0]
            insurance_policy = f"POL-{random.randint(1000, 9999)}"  # Generate a random insurance policy number
            model = temp_car["Model"]
            make = temp_car["Make"]
            fuel_type = random.choice(fuel_types)
            transmission = random.choice(transmissions)
            color = fake.color_name()
            mileage = round(random.uniform(5000, 50000), 2)
            purchase_date = fake.date_this_decade()
            availability = "Yes"

            cursor.execute(
                "INSERT INTO car (reg_no, car_category_name, insurance_policy, model, make, fuel_type, transmission, color, mileage, branch_id, purchase_date, availability) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);",
                (
                    reg_no,
                    car_category_name,
                    insurance_policy,
                    model,
                    make,
                    fuel_type,
                    transmission,
                    color,
                    mileage,
                    branch_id,
                    purchase_date,
                    availability,
                ),
            )


Step 4: there are a total of 408 cars in the car table.

--> Filling customer table:

Step 1: connect to DB
Step 2: use faker to generate customer details:
  firstname = fake.first_name()
        lastname = fake.last_name()
        email = fake.email()
        phone = generate_phone_number()
        address = fake.street_address()
        city = fake.city()
        zipcode = fake.zipcode()
        dateofbirth = fake.date_of_birth(minimum_age=18, maximum_age=70)
        license_number = fake.unique.random_int(min=10000, max=999999, step=1)
        emergency_contact_name = fake.name()
        emergency_contact_number = generate_phone_number()

step 3: run a loop 200 times( we are creating 200 customers) and insert into table.
cursor.execute(
            "INSERT INTO customer (firstname, lastname, email, phone, address, city, zipcode, dateofbirth, license_number, emergency_contact_name, emergency_contact_number) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);",
            (
                firstname,
                lastname,
                email,
                phone,
                address,
                city,
                zipcode,
                dateofbirth,
                license_number,
                emergency_contact_name,
                emergency_contact_number,
            ),

--> Filling membership_details

Step 1: connect to DB
Step 2: get all the customer_id
# Get customer IDs from the "customer" table
    customer_ids = get_customer_ids(cursor)
 Get a list of customer IDs from the "customer" table
def get_customer_ids(cursor):
    cursor.execute("SELECT customer_id FROM customer;")
    return [row[0] for row in cursor.fetchall()]

step 3: get membership types
# Define membership types
    membership_types = ["bronze", "gold", "platinum", "silver", "no_membership"]
 
This table was manually filled. It gives details about the discount rates for each type of membership.
Step 4: loop through each customer and fill the table:
# Populate the "membership_details" table for each customer
    for customer_id in customer_ids:
        membership_type = random.choice(membership_types)
        join_date = fake.date_between(start_date="-2y", end_date="today")
        if membership_type == "no_membership":
            end_date = None
        else:
            end_date = join_date + timedelta(days=3 * 365)  # Join date plus 3 years

        cursor.execute(
            "INSERT INTO membership_details (customer_id, join_date, end_date, membership_type) VALUES (%s, %s, %s, %s);",
            (customer_id, join_date, end_date, membership_type),
        )

--> Filling booking_details table:

CREATE TRIGGER validate_booking_trigger BEFORE INSERT ON public.booking_details FOR EACH ROW EXECUTE FUNCTION public.validate_booking();

The validate_booking_trigger in the database is a trigger associated with the booking_details table. It is executed before a new booking is inserted (a BEFORE INSERT trigger). This trigger calls a function, validate_booking(), which is designed to perform certain checks and validations on the booking data being inserted.
Validation checks include:
•	Check if pick_up date is today or in the future.
•	Check if return date is not before pick_up date.
•	Check if the car that is being booked is present at the pick_up location.
•	Check if car is available. ( car_availabity describles if the car is in drivable conditions. When car gets into an unexpected accident and is no more in drivable condition till maintenance is done, the column will be changed to “no”).
•	Check if the employee who is  booking  is from the “sales” department and if they are employed in that pick_up branch.
Additional script to make sure car booking dates don’t collide. (written in python script) .
•	Before booking a car we get details of its current booking and we check if the new booking dates are feasible.
query = (
            "select pick_up_date,return_date from booking_details where car_reg_no = %s"
        )
old_booking_details = cursor.fetchall()
for booking in old_booking_details:
            if not (new_pickup_date > booking[1] or new_dropoff_date < booking[0]):
                response = jsonify({"error": "Cannot book car for the given dates"})
                response.status_code = (
                    400  # You can set to whatever error status you need
                )
                return response
•	Using these validators, we can insert into the bookings_details table.
query = """
        INSERT INTO booking_details (booking_date, pick_up_date, return_date, customer_id, pick_up_location, return_location, emp_id, chauffeur_id, insurance_category, car_reg_no)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        RETURNING *;  
        """
        cursor.execute(
            query,
            (
                booking_details["booking_date"],
                booking_details["pick_up_date"],
                booking_details["return_date"],
                booking_details["customer_id"],
                booking_details["pick_up_location"],
                booking_details["return_location"],
                booking_details["emp_id"],
                booking_details["chauffeur_id"],
                booking_details["insurance_category"],
                booking_details["car_reg_no"],
            ),
        )

--> Filling billing_details table.

•	CREATE TRIGGER fill_billing_details_trigger AFTER INSERT ON public.booking_details FOR EACH ROW EXECUTE FUNCTION public.fill_billing_details();

•	The fill_billing_details_trigger in the database is a trigger associated with the booking_details table. This trigger is executed after a new booking record is inserted (an AFTER INSERT trigger). It calls the fill_billing_details() function, which is designed to calculate and insert billing details for the new booking.

•	This function performs several calculations such as:


•	Calculate car_rent_cost
SELECT (NEW.return_date - NEW.pick_up_date) * cc.cost_per_day
INTO STRICT car_rent_cost
FROM car_category cc
WHERE cc.car_category_name = (SELECT car_category_name FROM car WHERE reg_no = NEW.car_reg_no);
	
•	Calculate insurance cost
SELECT (NEW.return_date - NEW.pick_up_date) * booking_insurance.cost_per_day
into strict insurance_cost
from booking_insurance
where booking_insurance.insurance_category = new.insurance_category;

•	Calculate chauffeur cost
if new.chauffeur_id is NULL then
  	chauffeur_cost:=0;
else
 	chauffeur_cost := (NEW.return_date - NEW.pick_up_date) * 75;
end if;
•	(75 units of money per day is standard for any chauffeur)

•	Check customer membership for discount
SELECT mc.discount_rate
INTO STRICT discount_rate
FROM customer c
LEFT JOIN membership_details md ON c.customer_id = md.customer_id
LEFT JOIN Membership_category mc ON md.membership_type = mc.membership_type
WHERE c.customer_id = NEW.customer_id;
	
•	Calculate car_rent_after_discount
car_rent_after_discount := car_rent_cost - (discount_rate * 0.01 * car_rent_cost);
	
•	Calculate booking cost
booking_cost :=car_rent_after_discount + insurance_cost + chauffeur_cost;

•	Calculate tax_amt
tax_amt := 0.1 * booking_cost;


•	Calculate total_amount
total_amount := booking_cost + tax_amt;
•	Insert data into the "billing_details" table
INSERT INTO billing_details (booking_id, total_amount, booking_cost, tax_amt,car_rent_cost,chauffeur_cost,insurance_cost,car_rent_after_discount,discount_rate)
VALUES (NEW.booking_id, total_amount, booking_cost,
tax_amt,car_rent_cost,chauffeur_cost,insurance_cost,car_rent_after_discount,discount_rate);

--> Filling deleted_booking_details table (automatically filled):

•	CREATE TRIGGER copy_to_deleted_booking_trigger AFTER DELETE ON public.booking_details FOR EACH ROW EXECUTE FUNCTION public.copy_to_deleted_booking();

•	The copy_to_deleted_booking_trigger is a database trigger associated with the booking_details table. This trigger is activated after a booking record is deleted (an AFTER DELETE trigger). Its purpose is to maintain a record of deleted bookings for archival or tracking purposes. When a booking is deleted from the booking_details table, this trigger calls a function (public.copy_to_deleted_booking()) that copies the deleted booking details into another table, deleted_booking_details. This ensures that a historical record of all bookings, including those that were canceled or removed, is kept for future reference or analysis.

•	Copy the row to deleted_booking_details
INSERT INTO deleted_booking_details (booking_id, booking_date, pick_up_date, return_date, customer_id, pick_up_location, return_location, emp_id, chauffeur_id, insurance_category, car_reg_no)
SELECT OLD.booking_id, OLD.booking_date, OLD.pick_up_date, OLD.return_date, OLD.customer_id, OLD.pick_up_location, OLD.return_location, OLD.emp_id, OLD.chauffeur_id, OLD.insurance_category, OLD.car_reg_no;


•	Delete the row from booking_details
DELETE FROM booking_details WHERE booking_id = OLD.booking_id;
