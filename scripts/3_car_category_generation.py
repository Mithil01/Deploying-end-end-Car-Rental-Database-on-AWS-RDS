import psycopg2

# Database connection parameters
db_params = {
    "dbname": "car_rental",
    "user": "postgres",
    "password": "postgres",
    "host": "localhost",
    "port": "5432",
}

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

try:
    # Connect to the PostgreSQL database
    conn = psycopg2.connect(**db_params)
    cursor = conn.cursor()

    # Populate the "car_category" table with the specified data
    for category, seating_capacity, cost_per_day in car_categories:
        late_fee_per_hour = cost_per_day * 0.2  # Set late fee to 20% of cost per day

        cursor.execute(
            "INSERT INTO car_category (car_category_name, seating_capacity, cost_per_day, late_fee_per_hour) VALUES (%s, %s, %s, %s);",
            (category, seating_capacity, cost_per_day, late_fee_per_hour),
        )

    # Commit the changes and close the connection
    conn.commit()
    conn.close()

    print("Data inserted successfully.")

except (Exception, psycopg2.DatabaseError) as error:
    print("Error:", error)
