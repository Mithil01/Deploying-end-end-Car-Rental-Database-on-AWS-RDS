import psycopg2
from faker import Faker
import re

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

try:
    # Connect to the PostgreSQL database
    conn = psycopg2.connect(**db_params)
    cursor = conn.cursor()

    # Insert 10 rows into the "branch_details" table with random data
    for _ in range(10):
        branch_name = fake.company()
        address = fake.street_address()

        # Extract ZIP code from the address
        zipcode_match = re.search(r"\b\d{5}(?:-\d{4})?\b", address)
        zipcode = fake.postcode()

        cursor.execute(
            "INSERT INTO branch_details (branch_name, address, zipcode) VALUES (%s, %s, %s);",
            (branch_name, address, zipcode),
        )

    # Commit the changes and close the connection
    conn.commit()
    conn.close()

    print("Data inserted successfully.")

except (Exception, psycopg2.DatabaseError) as error:
    print("Error:", error)
