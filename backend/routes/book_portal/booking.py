from flask import Blueprint, request, jsonify
import psycopg2
from flask import abort
from datetime import date

# Database connection parameters
db_params = {
    "dbname": "car_rental",
    "user": "postgres",
    "password": "postgres",
    "host": "localhost",
    "port": "5432",
}

booking = Blueprint("booking", __name__)


@booking.route("/booking", methods=["POST"])
def booking_fn():
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()

        # Retrieve the JSON body from the POST request
        booking_details = request.get_json()

        # check the car availability
        new_pickup_date = booking_details["pick_up_date"]
        new_dropoff_date = booking_details["return_date"]

        year_str, month_str, day_str = new_pickup_date.split("-")
        new_pickup_date = date(int(year_str), int(month_str), int(day_str))
        year_str, month_str, day_str = new_dropoff_date.split("-")
        new_dropoff_date = date(int(year_str), int(month_str), int(day_str))

        query = (
            "select pick_up_date,return_date from booking_details where car_reg_no = %s"
        )
        cursor.execute(query, (booking_details["car_reg_no"],))
        old_booking_details = cursor.fetchall()
        print(booking_details)
        for booking in old_booking_details:
            if not (new_pickup_date > booking[1] or new_dropoff_date < booking[0]):
                response = jsonify({"error": "Cannot book car for the given dates"})
                response.status_code = (
                    400  # You can set to whatever error status you need
                )
                return response

        #  can be booked in the given dates

        # check if pickup_location and return_location are same
        if booking_details["pick_up_location"] != booking_details["return_location"]:
            response = jsonify(
                {
                    "error": "CAnnot return car in a different location. This feature will be added in the future"
                }
            )
            response.status_code = 400  # You can set to whatever error status you need
            return response

        # Insert the new booking into the 'booking_details' table
        query = """
        INSERT INTO booking_details (booking_date, pick_up_date, return_date, customer_id, pick_up_location, return_location, emp_id, chauffeur_id, insurance_category, car_reg_no)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        RETURNING *;  -- Retrieve the newly inserted row
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

        # Fetch the newly inserted row
        booking_confirmation = cursor.fetchone()
        booking_id = booking_confirmation[0]

        # get billing details
        billing_query = """ select total_amount,booking_cost,insurance_cost,chauffeur_cost,car_rent_cost,discount_rate , car_rent_after_discount,tax_amt from billing_details where booking_id = %s  """
        cursor.execute(billing_query, (booking_id,))
        billing_details = cursor.fetchall()
        billing_details_dict = []
        for billing in billing_details:
            billing_dict = {
                "billing_id": booking_id,
                "total_amount": billing[0],
                "booking_cost": billing[1],
                "insurance_cost": billing[2],
                "chauffeur_cost": billing[3],
                "car_rent_cost": billing[4],
                "discount_rate": billing[5],
                "car_rent_after_discount": billing[6],
                "tax_amt": billing[7],
            }
            billing_details_dict.append(billing_dict)

        # Commit the changes and close the connection
        conn.commit()
        conn.close()

        return jsonify(billing_details_dict)  # Return the newly inserted row as JSON
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        abort(500, f"Error: {error}")


@booking.route("/booking/<booking_id>")
def get_booking_details(booking_id):
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()

        if not booking_id.isdigit():
            abort(400, "Invalid booking ID")

        booking_details_query = """
            SELECT booking_id, booking_date, pick_up_date, return_date, customer_id, pick_up_location, return_location, emp_id, chauffeur_id, insurance_category, car_reg_no
            FROM booking_details
            WHERE booking_id = %s
        """
        cursor.execute(booking_details_query, (booking_id,))
        booking_details = cursor.fetchall()
        booking_details = [
            {
                "booking_id": booking[0],
                "booking_date": booking[1],
                "pick_up_date": booking[2],
                "return_date": booking[3],
                "customer_id": booking[4],
                "pick_up_location": booking[5],
                "return_location": booking[6],
                "emp_id": booking[7],
                "chauffeur_id": booking[8],
                "insurance_category": booking[9],
                "car_reg_no": booking[10],
            }
            for booking in booking_details
        ]

        # get billing details
        billing_query = """ select total_amount,booking_cost,insurance_cost,chauffeur_cost,car_rent_cost,discount_rate , car_rent_after_discount,tax_amt from billing_details where booking_id = %s  """
        cursor.execute(billing_query, (booking_id,))
        billing_details = cursor.fetchall()
        billing_details_dict = []
        for billing in billing_details:
            billing_dict = {
                "billing_id": booking_id,
                "total_amount": billing[0],
                "booking_cost": billing[1],
                "insurance_cost": billing[2],
                "chauffeur_cost": billing[3],
                "car_rent_cost": billing[4],
                "discount_rate": billing[5],
                "car_rent_after_discount": billing[6],
                "tax_amt": billing[7],
            }
            billing_details_dict.append(billing_dict)

        # Commit the changes and close the connection
        conn.commit()
        conn.close()

        return jsonify(booking_details, billing_details_dict)
    except (Exception, psycopg2.DatabaseError) as error:
        abort(500, f"Error: {error}")


@booking.route("/booking/<booking_id>", methods=["delete"])
def delete_booking(booking_id):
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()

        if not booking_id.isdigit():
            abort(400, "Invalid booking ID")

        # Delete the booking
        delete_booking_query = "DELETE FROM booking_details WHERE booking_id = %s"
        cursor.execute(delete_booking_query, (booking_id,))

        # Commit the changes and close the connection
        conn.commit()
        conn.close()

        return jsonify({"message": "Booking deleted successfully"})
    except (Exception, psycopg2.DatabaseError) as error:
        abort(500, f"Error: {error}")
