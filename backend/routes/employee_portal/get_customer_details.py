from flask import Blueprint, g, request, jsonify
import psycopg2
from flask import abort

# Database connection parameters
db_params = {
    "dbname": "car_rental",
    "user": "postgres",
    "password": "postgres",
    "host": "localhost",
    "port": "5432",
}


get_customer_details = Blueprint("get_customer_details", __name__)


@get_customer_details.route("/get_customer_details/<customer_id>")
def get_customer_details_fn(customer_id):
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()

        if not customer_id.isdigit():
            abort(400, "Invalid customer ID")

        customer_details_query = """
            SELECT cus.firstname, cus.lastname, cus.phone, mem_det.membership_type, mem_cat.discount_rate
            FROM customer AS cus, membership_details AS mem_det, membership_category AS mem_cat
            WHERE cus.customer_id = %s AND cus.customer_id = mem_det.customer_id AND mem_cat.membership_type = mem_det.membership_type
        """
        cursor.execute(customer_details_query, (customer_id,))
        customer_details = cursor.fetchall()
        customer_details = [
            {
                "firstname": customer[0],
                "lastname": customer[1],
                "phone": customer[2],
                "membership_type": customer[3],
                "discount_rate": customer[4],
            }
            for customer in customer_details
        ]

        conn.commit()
        cursor.close()

        return customer_details
    except (Exception, psycopg2.DatabaseError) as error:
        abort(500, f"Error: {error}")
