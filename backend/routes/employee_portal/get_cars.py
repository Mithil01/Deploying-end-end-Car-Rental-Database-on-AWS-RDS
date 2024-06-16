from flask import Blueprint, request, jsonify
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

get_cars = Blueprint("get_cars", __name__)


@get_cars.route("/get_cars")
def get_cars_fn():
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()

        branch_id = request.args.get("branch_id")
        if branch_id is None:
            abort(400, "No branch ID provided")

        # Modify the query to use the branch_id variable
        query = "SELECT reg_no, make, model, car_category_name, availability FROM public.car WHERE branch_id = %s ORDER BY reg_no ASC"
        cursor.execute(query, (branch_id,))

        return cursor.fetchall()
    except (Exception, psycopg2.DatabaseError) as error:
        abort(500, f"Error: {error}")
