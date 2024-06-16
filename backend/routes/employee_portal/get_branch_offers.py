from calendar import c
from flask import Blueprint, request, jsonify
import psycopg2
from flask import abort
from requests import get

# Database connection parameters
db_params = {
    "dbname": "car_rental",
    "user": "postgres",
    "password": "postgres",
    "host": "localhost",
    "port": "5432",
}

get_branch_offers = Blueprint("get_branch_offers", __name__)


@get_branch_offers.route("/get_branch_offers")
def get_branch_offers_fn():
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()

        # get branch id from request
        branch_id = request.args.get("branch_id")
        if branch_id is None:
            abort(400, "No branch ID provided")

        # get list of sales employess from branch
        sales_employee_query = "SELECT * FROM public.employee_details where branch_id = %s and department = 'Sales'"
        cursor.execute(sales_employee_query, (branch_id,))
        sales_employee_details = cursor.fetchall()
        sales_employee_details_dict = []
        for employee in sales_employee_details:
            employee_dict = {
                "emp_id": employee[0],
                "firstname": employee[1],
                "lastname": employee[2],
                "age": employee[5],
            }
            sales_employee_details_dict.append(employee_dict)

        # get cras from the branch
        car_deatils_query = """SELECT car.reg_no, car.make, car.model, car.car_category_name, car.availability ,car_ca.seating_capacity,car_ca.cost_per_day
FROM car as car , car_category as car_ca
WHERE car.branch_id = %s and car.car_category_name = car_ca.car_category_name
ORDER BY car.reg_no ASC"""
        cursor.execute(car_deatils_query, (branch_id,))
        car_details = cursor.fetchall()
        car_details_dict = []
        for car in car_details:
            car_dict = {
                "reg_no": car[0],
                "make": car[1],
                "model": car[2],
                "car_category_name": car[3],
                "availability": car[4],
                "seating_capacity": car[5],
                "cost_per_day": car[6],
            }
            car_details_dict.append(car_dict)

        # get details of branch
        branch_details_query = (
            "SELECT branch_name FROM public.branch_details WHERE branch_id = %s"
        )
        cursor.execute(branch_details_query, (branch_id,))
        branch_name = cursor.fetchone()[0]

        # get chauffer details
        chauffer_details_query = "SELECT chauffeur_id,firstname,lastname,age,license_number FROM public.chauffeur WHERE branch_id = %s"
        cursor.execute(chauffer_details_query, (branch_id,))
        chauffer_details = cursor.fetchall()
        chauffer_details_dict = []
        for chauffeur in chauffer_details:
            chauffer_dict = {
                "chauffeur_id": chauffeur[0],
                "firstname": chauffeur[1],
                "lastname": chauffeur[2],
                "age": chauffeur[3],
                "license_number": chauffeur[4],
            }
            chauffer_details_dict.append(chauffer_dict)

        # get insurance details
        insurance_query = (
            "SELECT * FROM public.booking_insurance ORDER BY insurance_category ASC "
        )
        cursor.execute(insurance_query)
        insurance_details = cursor.fetchall()
        insurance_details_dict = []
        for insurance in insurance_details:
            insurance_dict = {
                "insurance_category": insurance[0],
                "insurance_description": insurance[1],
                "insurance_cost": insurance[2],
            }
            insurance_details_dict.append(insurance_dict)

        output = {
            "branch_name": branch_name,
            "branch_sales_employees": sales_employee_details_dict,
            "car_details": car_details_dict,
            "chauffer_details": chauffer_details_dict,
            "insurance_details": insurance_details_dict,
        }
        conn.commit()
        cursor.close()
        return output
    except (Exception, psycopg2.DatabaseError) as error:
        abort(500, f"Error: {error}")
