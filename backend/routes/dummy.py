import re
from flask import Blueprint, request, jsonify
import psycopg2
from datetime import date


dummy = Blueprint("first", __name__)

# Database connection parameters
db_params = {
    "dbname": "car_rental",
    "user": "postgres",
    "password": "postgres",
    "host": "localhost",
    "port": "5432",
}


# Function to retrieve existing branch IDs from the 'branch_details' table
def get_query_data(cursor, query):
    # cursor.execute("SELECT branch_id FROM branch_details;")
    cursor.execute(query)
    return [row[0] for row in cursor.fetchall()]


@dummy.route("/dummy")
def first():
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()

        # Access the request body
        # query = request.get_data(as_text=True)

        car_reg_no = request.headers.get("id")
        new_pickup_date = request.headers.get("newPickup")
        new_dropoff_date = request.headers.get("newDropoff")
        year_str, month_str, day_str = new_pickup_date.split("-")
        new_pickup_date = date(int(year_str), int(month_str), int(day_str))
        year_str, month_str, day_str = new_dropoff_date.split("-")
        new_dropoff_date = date(int(year_str), int(month_str), int(day_str))

        query = (
            "select pick_up_date,return_date from booking_details where car_reg_no = %s"
        )
        cursor.execute(query, (car_reg_no,))
        booking_details = cursor.fetchall()

        # trying out

        for booking in booking_details:
            pickup_date = booking[0]
            return_date = booking[1]

            if not (new_pickup_date > booking[1] or new_dropoff_date < booking[0]):
                response = jsonify({"error": "Cannot book car for the given dates"})
                response.status_code = (
                    400  # You can set to whatever error status you need
                )
                return response

        # trying out

        # return get_query_data(cursor, query)
        return booking_details
    except (Exception, psycopg2.DatabaseError) as error:
        return ("Error:", error)
