import json
import psycopg2
from faker import Faker
from faker_vehicle import VehicleProvider

fake = Faker()
fake.add_provider(VehicleProvider)
import random

# Database connection parameters
db_params = {
    "dbname": "car_rental",
    "user": "postgres",
    "password": "postgres",
    "host": "localhost",
    "port": "5432",
}

# Sample car category names


# Sample data for fuel types and transmissions
fuel_types = ["Gasoline", "Diesel", "Electric", "Hybrid"]
transmissions = ["Automatic", "Manual", "Semi-Automatic"]


# Function to retrieve existing branch IDs from the 'branch_details' table
def get_branch_ids(cursor):
    cursor.execute("SELECT branch_id FROM branch_details;")
    return [row[0] for row in cursor.fetchall()]


try:
    # Connect to the PostgreSQL database
    conn = psycopg2.connect(**db_params)
    cursor = conn.cursor()

    # Get existing branch IDs
    branch_ids = get_branch_ids(cursor)

    # Populate the "car" table with the specified data
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

    # Commit the changes and close the connection
    conn.commit()
    conn.close()

    print("Data inserted successfully.")

except (Exception, psycopg2.DatabaseError) as error:
    print("Error:", error)
