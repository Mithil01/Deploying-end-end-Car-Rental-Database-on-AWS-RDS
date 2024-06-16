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

# Sample data for departments
departments = ["HR", "Finance", "IT", "Sales", "Maintenance", "Security"]


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
                dateofbirth = fake.date_of_birth(minimum_age=21, maximum_age=60)

                cursor.execute(
                    "INSERT INTO employee_details (first_name, last_name, branch_id, dateofbirth, department) VALUES (%s, %s, %s, %s, %s);",
                    (first_name, last_name, branch_id, dateofbirth, department),
                )

    # Commit the changes and close the connection
    conn.commit()
    conn.close()

    print("Data inserted successfully.")

except (Exception, psycopg2.DatabaseError) as error:
    print("Error:", error)
