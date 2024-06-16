import psycopg2
from faker import Faker
from datetime import datetime, timedelta
import random

# Database connection parameters
db_params = {
    "dbname": "car_rental",
    "user": "postgres",
    "password": "postgres",
    "host": "localhost",
    "port": "5432",
}

# Create a Faker instance
fake = Faker()


# Get a list of customer IDs from the "customer" table
def get_customer_ids(cursor):
    cursor.execute("SELECT customer_id FROM customer;")
    return [row[0] for row in cursor.fetchall()]


try:
    # Connect to the PostgreSQL database
    conn = psycopg2.connect(**db_params)
    cursor = conn.cursor()

    # Full up the booking_insurance table
    cursor.execute(
    """INSERT INTO booking_insurance (insurance_category, insurance_details, cost_per_day) VALUES 
    ('category_1', 'Basic insurance package', 15.00),
    ('category_2', 'Comprehensive insurance package', 30.00),
    ('category_3', 'Premium insurance package', 45.00);""")

    # Get customer IDs from the "customer" table
    customer_ids = get_customer_ids(cursor)
    membership_dict = {
    "bronze": 0.05,
    "gold": 0.15,
    "platinum": 0.25,
    "silver": 0.1,
    "no_membership": 0
    }
    for membership_type, discount_rate in membership_dict.items():
        cursor.execute(
            "INSERT INTO membership_category (membership_type, discount_rate) VALUES (%s, %s);",
            (membership_type, discount_rate)
        )
    # Define membership types
    membership_types = ["bronze", "gold", "platinum", "silver", "no_membership"]

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

    # Commit the changes and close the connection
    conn.commit()
    conn.close()

    print("Data inserted successfully.")

except (Exception, psycopg2.DatabaseError) as error:
    print("Error:", error)
