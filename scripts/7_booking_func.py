import psycopg2
from datetime import date
import random

from validator_collection import none

# Database connection parameters
db_params = {
    "dbname": "car_rental",
    "user": "postgres",
    "password": "postgres",
    "host": "localhost",
    "port": "5432",
}

# script to insert booking details into the database

branch_content = {
    "branch_name": "Fowler, Stuart and Brock",
    "branch_sales_employees": [
        {"age": 24, "emp_id": 135, "firstname": "Robert", "lastname": "Bates"},
        {"age": 58, "emp_id": 136, "firstname": "Robert", "lastname": "Ford"},
        {"age": 45, "emp_id": 137, "firstname": "Brittney", "lastname": "Jones"},
        {"age": 40, "emp_id": 138, "firstname": "Christopher", "lastname": "Lang"},
        {"age": 25, "emp_id": 139, "firstname": "Denise", "lastname": "Cordova"},
        {"age": 30, "emp_id": 140, "firstname": "Larry", "lastname": "Garcia"},
        {"age": 55, "emp_id": 141, "firstname": "Paul", "lastname": "Moore"},
    ],
    "car_details": [
        {
            "availability": "Yes",
            "car_category_name": "Sedan",
            "cost_per_day": 80.0,
            "make": "Lexus",
            "model": "IS",
            "reg_no": "007 KLB",
            "seating_capacity": 5,
        },
        {
            "availability": "Yes",
            "car_category_name": "Van/Minivan",
            "cost_per_day": 120.0,
            "make": "GMC",
            "model": "Safari Cargo",
            "reg_no": "1-I8679",
            "seating_capacity": 8,
        },
        {
            "availability": "Yes",
            "car_category_name": "Pickup",
            "cost_per_day": 95.0,
            "make": "Dodge",
            "model": "Ram 2500 Quad Cab",
            "reg_no": "17R•854",
            "seating_capacity": 4,
        },
        {
            "availability": "Yes",
            "car_category_name": "SUV",
            "cost_per_day": 100.0,
            "make": "Honda",
            "model": "Passport",
            "reg_no": "18EC1",
            "seating_capacity": 7,
        },
        {
            "availability": "Yes",
            "car_category_name": "Sedan",
            "cost_per_day": 80.0,
            "make": "Lexus",
            "model": "GS",
            "reg_no": "1FX 911",
            "seating_capacity": 5,
        },
        {
            "availability": "Yes",
            "car_category_name": "Pickup",
            "cost_per_day": 95.0,
            "make": "Chevrolet",
            "model": "2500 Extended Cab",
            "reg_no": "1W CQ297",
            "seating_capacity": 4,
        },
        {
            "availability": "Yes",
            "car_category_name": "Van/Minivan",
            "cost_per_day": 120.0,
            "make": "Chevrolet",
            "model": "Express 3500 Cargo",
            "reg_no": "2OH6459",
            "seating_capacity": 8,
        },
        {
            "availability": "Yes",
            "car_category_name": "Van/Minivan",
            "cost_per_day": 120.0,
            "make": "Ford",
            "model": "Freestar Cargo",
            "reg_no": "325KXB",
            "seating_capacity": 8,
        },
        {
            "availability": "Yes",
            "car_category_name": "Pickup",
            "cost_per_day": 95.0,
            "make": "Ford",
            "model": "Ranger Regular Cab",
            "reg_no": "3JQ34",
            "seating_capacity": 4,
        },
        {
            "availability": "Yes",
            "car_category_name": "SUV",
            "cost_per_day": 100.0,
            "make": "BMW",
            "model": "X3",
            "reg_no": "406 DF0",
            "seating_capacity": 7,
        },
        {
            "availability": "Yes",
            "car_category_name": "Pickup",
            "cost_per_day": 95.0,
            "make": "Nissan",
            "model": "Titan King Cab",
            "reg_no": "456 UCS",
            "seating_capacity": 4,
        },
        {
            "availability": "Yes",
            "car_category_name": "Van/Minivan",
            "cost_per_day": 120.0,
            "make": "Dodge",
            "model": "Sprinter 2500 Cargo",
            "reg_no": "515 KYP",
            "seating_capacity": 8,
        },
        {
            "availability": "Yes",
            "car_category_name": "Coupe",
            "cost_per_day": 110.0,
            "make": "Volvo",
            "model": "C70",
            "reg_no": "51T 518",
            "seating_capacity": 2,
        },
        {
            "availability": "Yes",
            "car_category_name": "SUV",
            "cost_per_day": 100.0,
            "make": "Chevrolet",
            "model": "Suburban 2500",
            "reg_no": "541-PBB",
            "seating_capacity": 7,
        },
        {
            "availability": "Yes",
            "car_category_name": "Van/Minivan",
            "cost_per_day": 120.0,
            "make": "Chevrolet",
            "model": "G-Series 2500",
            "reg_no": "564 GQB",
            "seating_capacity": 8,
        },
        {
            "availability": "Yes",
            "car_category_name": "Van/Minivan",
            "cost_per_day": 120.0,
            "make": "Chevrolet",
            "model": "Venture Cargo",
            "reg_no": "5H440",
            "seating_capacity": 8,
        },
        {
            "availability": "Yes",
            "car_category_name": "SUV",
            "cost_per_day": 100.0,
            "make": "Lexus",
            "model": "LX",
            "reg_no": "5HYU 65",
            "seating_capacity": 7,
        },
        {
            "availability": "Yes",
            "car_category_name": "Sedan",
            "cost_per_day": 80.0,
            "make": "Genesis",
            "model": "G80",
            "reg_no": "654 QCY",
            "seating_capacity": 5,
        },
        {
            "availability": "Yes",
            "car_category_name": "Van/Minivan",
            "cost_per_day": 120.0,
            "make": "Nissan",
            "model": "Quest",
            "reg_no": "72AU100",
            "seating_capacity": 8,
        },
        {
            "availability": "Yes",
            "car_category_name": "Pickup",
            "cost_per_day": 95.0,
            "make": "Chevrolet",
            "model": "Silverado 1500 Regular Cab",
            "reg_no": "7AA X29",
            "seating_capacity": 4,
        },
        {
            "availability": "Yes",
            "car_category_name": "SUV",
            "cost_per_day": 100.0,
            "make": "HUMMER",
            "model": "H1",
            "reg_no": "8HN C26",
            "seating_capacity": 7,
        },
        {
            "availability": "Yes",
            "car_category_name": "Convertible",
            "cost_per_day": 150.0,
            "make": "Maserati",
            "model": "GranTurismo",
            "reg_no": "8P GR984",
            "seating_capacity": 2,
        },
        {
            "availability": "Yes",
            "car_category_name": "Coupe",
            "cost_per_day": 110.0,
            "make": "Mitsubishi",
            "model": "Mirage",
            "reg_no": "920 EFT",
            "seating_capacity": 2,
        },
        {
            "availability": "Yes",
            "car_category_name": "SUV",
            "cost_per_day": 100.0,
            "make": "Audi",
            "model": "Q3",
            "reg_no": "93-29222",
            "seating_capacity": 7,
        },
        {
            "availability": "Yes",
            "car_category_name": "Pickup",
            "cost_per_day": 95.0,
            "make": "GMC",
            "model": "Sierra 1500 Crew Cab",
            "reg_no": "9E474",
            "seating_capacity": 4,
        },
        {
            "availability": "Yes",
            "car_category_name": "Sedan",
            "cost_per_day": 80.0,
            "make": "Mitsubishi",
            "model": "Lancer",
            "reg_no": "AWT-206",
            "seating_capacity": 5,
        },
        {
            "availability": "Yes",
            "car_category_name": "Hatchback",
            "cost_per_day": 70.0,
            "make": "Nissan",
            "model": "Versa Note",
            "reg_no": "CK 3719",
            "seating_capacity": 4,
        },
        {
            "availability": "Yes",
            "car_category_name": "Wagon",
            "cost_per_day": 90.0,
            "make": "Ford",
            "model": "C-MAX Hybrid",
            "reg_no": "CN-9123",
            "seating_capacity": 6,
        },
        {
            "availability": "Yes",
            "car_category_name": "Pickup",
            "cost_per_day": 95.0,
            "make": "Chevrolet",
            "model": "3500 Extended Cab",
            "reg_no": "DO-9170",
            "seating_capacity": 4,
        },
        {
            "availability": "Yes",
            "car_category_name": "Coupe",
            "cost_per_day": 110.0,
            "make": "Acura",
            "model": "NSX",
            "reg_no": "DXR-5042",
            "seating_capacity": 2,
        },
        {
            "availability": "Yes",
            "car_category_name": "Pickup",
            "cost_per_day": 95.0,
            "make": "GMC",
            "model": "Canyon Crew Cab",
            "reg_no": "E08 7DD",
            "seating_capacity": 4,
        },
        {
            "availability": "Yes",
            "car_category_name": "SUV",
            "cost_per_day": 100.0,
            "make": "Mercedes-Benz",
            "model": "GLS",
            "reg_no": "FQ-3168",
            "seating_capacity": 7,
        },
        {
            "availability": "Yes",
            "car_category_name": "SUV",
            "cost_per_day": 100.0,
            "make": "Nissan",
            "model": "JUKE",
            "reg_no": "HQA 875",
            "seating_capacity": 7,
        },
        {
            "availability": "Yes",
            "car_category_name": "Sedan",
            "cost_per_day": 80.0,
            "make": "Volkswagen",
            "model": "Jetta",
            "reg_no": "HR 34042",
            "seating_capacity": 5,
        },
        {
            "availability": "Yes",
            "car_category_name": "Van/Minivan",
            "cost_per_day": 120.0,
            "make": "Ford",
            "model": "E150 Cargo",
            "reg_no": "HT3 0114",
            "seating_capacity": 8,
        },
        {
            "availability": "Yes",
            "car_category_name": "Pickup",
            "cost_per_day": 95.0,
            "make": "Chevrolet",
            "model": "1500 Extended Cab",
            "reg_no": "KDX 471",
            "seating_capacity": 4,
        },
        {
            "availability": "Yes",
            "car_category_name": "Coupe",
            "cost_per_day": 110.0,
            "make": "Audi",
            "model": "TT",
            "reg_no": "KEX 482",
            "seating_capacity": 2,
        },
        {
            "availability": "Yes",
            "car_category_name": "Sedan",
            "cost_per_day": 80.0,
            "make": "Chevrolet",
            "model": "Malibu",
            "reg_no": "LU4 1848",
            "seating_capacity": 5,
        },
        {
            "availability": "Yes",
            "car_category_name": "Van/Minivan",
            "cost_per_day": 120.0,
            "make": "GMC",
            "model": "Savana 2500 Passenger",
            "reg_no": "QFH H35",
            "seating_capacity": 8,
        },
        {
            "availability": "Yes",
            "car_category_name": "Sedan",
            "cost_per_day": 80.0,
            "make": "Kia",
            "model": "Forte",
            "reg_no": "TZ7 5706",
            "seating_capacity": 5,
        },
        {
            "availability": "Yes",
            "car_category_name": "Van/Minivan",
            "cost_per_day": 120.0,
            "make": "Kia",
            "model": "Sedona",
            "reg_no": "UDW-773",
            "seating_capacity": 8,
        },
        {
            "availability": "Yes",
            "car_category_name": "Sedan",
            "cost_per_day": 80.0,
            "make": "Honda",
            "model": "Civic",
            "reg_no": "W 913441",
            "seating_capacity": 5,
        },
        {
            "availability": "Yes",
            "car_category_name": "Sedan",
            "cost_per_day": 80.0,
            "make": "Volkswagen",
            "model": "Jetta",
            "reg_no": "Y69 9KA",
            "seating_capacity": 5,
        },
    ],
    "chauffer_details": [
        {
            "age": 49,
            "chauffeur_id": 10,
            "firstname": "Kevin",
            "lastname": "Edwards",
            "license_number": "74466",
        },
        {
            "age": 53,
            "chauffeur_id": 14,
            "firstname": "Paul",
            "lastname": "Mcconnell",
            "license_number": "31878",
        },
        {
            "age": 30,
            "chauffeur_id": 18,
            "firstname": "Luke",
            "lastname": "Cox",
            "license_number": "31223",
        },
        {
            "age": 52,
            "chauffeur_id": 19,
            "firstname": "Benjamin",
            "lastname": "Martinez",
            "license_number": "49949",
        },
        {
            "age": 55,
            "chauffeur_id": 25,
            "firstname": "Charles",
            "lastname": "Rogers",
            "license_number": "96108",
        },
        {
            "age": 21,
            "chauffeur_id": 28,
            "firstname": "Douglas",
            "lastname": "Carroll",
            "license_number": "35613",
        },
        {
            "age": 41,
            "chauffeur_id": 40,
            "firstname": "Elizabeth",
            "lastname": "Clark",
            "license_number": "69959",
        },
        {
            "age": 38,
            "chauffeur_id": 57,
            "firstname": "Lori",
            "lastname": "Rhodes",
            "license_number": "76943",
        },
        {
            "age": 23,
            "chauffeur_id": 65,
            "firstname": "Peter",
            "lastname": "Decker",
            "license_number": "50306",
        },
        {
            "age": 22,
            "chauffeur_id": 69,
            "firstname": "Patrick",
            "lastname": "Hernandez",
            "license_number": "47355",
        },
        {
            "age": 36,
            "chauffeur_id": 80,
            "firstname": "Joshua",
            "lastname": "Ramsey",
            "license_number": "86689",
        },
        {
            "age": 57,
            "chauffeur_id": 84,
            "firstname": "Patrick",
            "lastname": "Daniel",
            "license_number": "69999",
        },
        {
            "age": 28,
            "chauffeur_id": 86,
            "firstname": "Shaun",
            "lastname": "Obrien",
            "license_number": "92595",
        },
        {
            "age": 39,
            "chauffeur_id": 112,
            "firstname": "Tom",
            "lastname": "Villanueva",
            "license_number": "78815",
        },
    ],
    "insurance_details": [
        {
            "insurance_category": "category_1",
            "insurance_cost": 10.5,
            "insurance_description": "Comprehensive coverage",
        },
        {
            "insurance_category": "category_2",
            "insurance_cost": 15.25,
            "insurance_description": "Specialized coverage",
        },
        {
            "insurance_category": "category_3",
            "insurance_cost": 5.75,
            "insurance_description": "Basic coverage",
        },
    ],
}

temp_customer = random.randint(101, 300)



def insert_booking(
    booking_date,
    pick_up_date,
    return_date,
    customer_id,
    pick_up_location,
    return_location,
    emp_id,
    chauffeur_id,
    insurance_category,
    car_reg_no,
):
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()

        # Insert data into the "booking_details" table
        cursor.execute(
            "INSERT INTO booking_details (booking_date, pick_up_date, return_date, customer_id, pick_up_location, return_location, emp_id, chauffeur_id, insurance_category, car_reg_no) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s);",
            (
                booking_date,
                pick_up_date,
                return_date,
                customer_id,
                pick_up_location,
                return_location,
                emp_id,
                chauffeur_id,
                insurance_category,
                car_reg_no,
            ),
        )

        # Commit the changes and close the connection
        conn.commit()
        conn.close()

        print("Booking data inserted successfully.")

    except (Exception, psycopg2.DatabaseError) as error:
        print("Error:", error)


insert_booking(
    booking_date="2023-11-20",
    pick_up_date="2023-11-20",
    return_date="2023-11-25",
    customer_id=103,
    pick_up_location=47,
    return_location=42,
    emp_id=137,
    chauffeur_id=3,
    insurance_category="category_1",
    car_reg_no="007 KLB",
)


# trigger checking
# -- booking date is today
# -- pick up date is either today or in the future
# -- car is available
# -- car's branch matches pick-up location
# -- employee's branch matches pick-up location
# -- emplyee's department must be sales


# billing details
# -- car rent cost is no of days car is booked * car's daily rate
# -- insurance cost is insurance category's daily rate * no of days car is booked
# -- if chauffeur not assigned , chauffer cost is 0
# -- if chauffeur assigned , chauffer cost is chauffeur's daily rate (which is 75 for all chauffeurs) * no of days car is booked
# -- if customer has a membership, membership discount is applied to car rent cost
# --  booking cost is car_rent_after_discount + insurance_cost + chauffeur_cost
# -- tax amt is 10% of booking cost
# -- total cost is booking cost + tax amt
