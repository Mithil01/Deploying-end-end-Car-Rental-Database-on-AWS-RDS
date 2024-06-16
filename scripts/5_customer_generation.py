import psycopg2
from faker import Faker

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


# Function to generate random phone numbers
def generate_phone_number():
    return fake.phone_number()


try:
    # Connect to the PostgreSQL database
    conn = psycopg2.connect(**db_params)
    cursor = conn.cursor()

    # Populate the "customer" table with random data
    for _ in range(100):
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
        )

    # Commit the changes and close the connection
    conn.commit()
    conn.close()

    print("Data inserted successfully.")

except (Exception, psycopg2.DatabaseError) as error:
    print("Error:", error)
