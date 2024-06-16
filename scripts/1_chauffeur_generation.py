import psycopg2
from faker import Faker
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


# Function to retrieve existing branch IDs from the 'branch_details' table
def get_branch_ids(cursor):
    cursor.execute("SELECT branch_id FROM branch_details;")
    return [row for row in cursor.fetchall()]


try:
    # Connect to the PostgreSQL database
    conn = psycopg2.connect(**db_params)
    cursor = conn.cursor()

    # Get existing branch IDs
    branch_ids = get_branch_ids(cursor)

    # Insert approximately 120 rows into the "chauffeur" table with random data
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

    # Commit the changes and close the connection
    conn.commit()
    conn.close()

    print("Data inserted successfully.")

except (Exception, psycopg2.DatabaseError) as error:
    print("Error:", error)
