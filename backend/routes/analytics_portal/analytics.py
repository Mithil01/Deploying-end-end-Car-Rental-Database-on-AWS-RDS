from math import e
import re
from flask import Blueprint, request, jsonify
import psycopg2
from flask import abort
from pyrsistent import b


# Database connection parameters
db_params = {
    "dbname": "car_rental",
    "user": "postgres",
    "password": "postgres",
    "host": "localhost",
    "port": "5432",
}


analytics = Blueprint("analytics", __name__)


@analytics.route("/analytics/bookings", methods=["GET"])
def get_detailed_bookings():
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()

        # query
        query = """
            SELECT bd.booking_id, bd.booking_date, bd.pick_up_date, bd.return_date, 
       c.firstname as customer_firstname, c.lastname as customer_lastname, 
       e.first_name as employee_firstname, e.last_name as employee_lastname, 
       ch.firstname as chauffeur_firstname, ch.lastname as chauffeur_lastname, 
       car.model, car.make, bi.total_amount
FROM booking_details bd
JOIN customer c ON bd.customer_id = c.customer_id
JOIN employee_details e ON bd.emp_id = e.emp_id
LEFT JOIN chauffeur ch ON bd.chauffeur_id = ch.chauffeur_id
JOIN car ON bd.car_reg_no = car.reg_no
JOIN billing_details bi ON bd.booking_id = bi.booking_id;
        """

        cursor.execute(query)
        bookings = cursor.fetchall()
        bookings = [
            {
                "booking_id": booking[0],
                "booking_date": booking[1],
                "pick_up_date": booking[2],
                "return_date": booking[3],
                "customer_firstname": booking[4],
                "customer_lastname": booking[5],
                "employee_firstname": booking[6],
                "employee_lastname": booking[7],
                "chauffeur_firstname": booking[8],
                "chauffeur_lastname": booking[9],
                "model": booking[10],
                "make": booking[11],
                "total_amount": booking[12],
            }
            for booking in bookings
        ]
        return jsonify(bookings)

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        abort(500, f"Error: {error}")


@analytics.route("/analytics/bookings/<booking_id>", methods=["GET"])
def get_booking(booking_id):
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()

        # validate booking_id
        if not booking_id.isdigit():
            abort(400, "Invalid booking ID")

        # query
        query = """
            SELECT bd.booking_id, bd.booking_date, bd.pick_up_date, bd.return_date, 
       c.firstname as customer_firstname, c.lastname as customer_lastname, 
       e.first_name as employee_firstname, e.last_name as employee_lastname, 
       ch.firstname as chauffeur_firstname, ch.lastname as chauffeur_lastname, 
       car.model, car.make, bi.total_amount
FROM booking_details bd
JOIN customer c ON bd.customer_id = c.customer_id
JOIN employee_details e ON bd.emp_id = e.emp_id
LEFT JOIN chauffeur ch ON bd.chauffeur_id = ch.chauffeur_id
JOIN car ON bd.car_reg_no = car.reg_no
JOIN billing_details bi ON bd.booking_id = bi.booking_id
where bd.booking_id = %s;"""

        cursor.execute(query, (booking_id,))
        booking = cursor.fetchone()
        booking = {
            "booking_id": booking[0],
            "booking_date": booking[1],
            "pick_up_date": booking[2],
            "return_date": booking[3],
            "customer_firstname": booking[4],
            "customer_lastname": booking[5],
            "employee_firstname": booking[6],
            "employee_lastname": booking[7],
            "chauffeur_firstname": booking[8],
            "chauffeur_lastname": booking[9],
            "model": booking[10],
            "make": booking[11],
            "total_amount": booking[12],
        }
        return jsonify(booking)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        abort(500, f"Error: {error}")


# Aggregate Function to Analyze Revenue by Car Category:
@analytics.route("/analytics/car_category", methods=["GET"])
def get_car_category_revenue():
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()

        # query
        query = """
            SELECT 
    cc.car_category_name, 
    ROUND(SUM(bi.total_amount)::numeric, 2) as total_revenue
FROM 
    billing_details bi
JOIN 
    booking_details bk ON bi.booking_id = bk.booking_id
JOIN 
    car ON bk.car_reg_no = car.reg_no
JOIN 
    car_category cc ON car.car_category_name = cc.car_category_name
GROUP BY 
    cc.car_category_name
ORDER BY 
    total_revenue DESC; 
    """

        cursor.execute(query)
        car_category_revenue = cursor.fetchall()
        car_category_revenue = [
            {"car_category_name": category[0], "total_revenue": category[1]}
            for category in car_category_revenue
        ]
        return jsonify(car_category_revenue)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        abort(500, f"Error: {error}")


# Finding Cars with High Mileage for Maintenance Check:
@analytics.route("/analytics/high_mileage_cars", methods=["GET"])
def get_high_mileage_cars():
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()

        # Query to find cars with high mileage
        query = """
            SELECT car.reg_no, car.model, car.make, car.mileage
FROM car
WHERE car.mileage > (SELECT AVG(mileage) FROM car) + (SELECT STDDEV(mileage) FROM car)
order by car.mileage desc;
        """

        cursor.execute(query)
        high_mileage_cars = cursor.fetchall()
        high_mileage_cars = [
            {"reg_no": car[0], "model": car[1], "make": car[2], "mileage": car[3]}
            for car in high_mileage_cars
        ]
        return jsonify(high_mileage_cars)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        abort(500, f"Error: {error}")


# Employee Performance Analysis Based on Number of Handled Bookings:
@analytics.route("/analytics/employee_bookings", methods=["GET"])
def get_employee_bookings():
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()

        # SQL query
        query = """
            SELECT 
                e.emp_id, 
                e.first_name, 
                e.last_name, 
                COUNT(bd.booking_id) as handled_bookings
            FROM 
                employee_details e
            JOIN 
                booking_details bd ON e.emp_id = bd.emp_id
            GROUP BY 
                e.emp_id
            ORDER BY 
                handled_bookings DESC;
        """

        cursor.execute(query)
        employee_bookings = cursor.fetchall()
        employee_bookings = [
            {
                "emp_id": emp[0],
                "first_name": emp[1],
                "last_name": emp[2],
                "handled_bookings": emp[3],
            }
            for emp in employee_bookings
        ]
        return jsonify(employee_bookings)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        abort(500, f"Error: {error}")


# Average Rental Duration and Cost by Car Category:
@analytics.route("/analytics/car_category_avg", methods=["GET"])
def get_car_category_average():
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()

        # SQL query
        query = """
            SELECT 
                cc.car_category_name, 
                ROUND(AVG(bd.return_date - bd.pick_up_date)::NUMERIC, 2) AS average_rental_duration, 
                ROUND(AVG(bi.total_amount)::NUMERIC, 2) AS average_rental_cost
            FROM 
                booking_details bd
            JOIN 
                car ON bd.car_reg_no = car.reg_no
            JOIN 
                car_category cc ON car.car_category_name = cc.car_category_name
            JOIN 
                billing_details bi ON bd.booking_id = bi.booking_id
            GROUP BY 
                cc.car_category_name;
        """

        cursor.execute(query)
        car_category_avg = cursor.fetchall()
        car_category_avg = [
            {
                "car_category_name": cat[0],
                "average_rental_duration": cat[1],
                "average_rental_cost": cat[2],
            }
            for cat in car_category_avg
        ]
        return jsonify(car_category_avg)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        abort(500, f"Error: {error}")


# most popular fuel type for each age group based on the number of bookings.
@analytics.route("/analytics/popular_fuel_by_age", methods=["GET"])
def get_popular_fuel_by_age():
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()

        # SQL query
        query = """
            SELECT 
                age, 
                fuel_type, 
                total_bookings
            FROM (
                SELECT 
                    c.age, 
                    car.fuel_type, 
                    COUNT(*) as total_bookings,
                    ROW_NUMBER() OVER (PARTITION BY c.age ORDER BY COUNT(*) DESC) as rn
                FROM 
                    booking_details bd
                JOIN 
                    customer c ON bd.customer_id = c.customer_id
                JOIN 
                    car ON bd.car_reg_no = car.reg_no
                GROUP BY 
                    c.age, car.fuel_type
            ) as subquery
            WHERE 
                rn = 1
            ORDER BY 
                age;
        """

        cursor.execute(query)
        popular_fuel_by_age = cursor.fetchall()
        popular_fuel_by_age = [
            {"age": row[0], "fuel_type": row[1], "total_bookings": row[2]}
            for row in popular_fuel_by_age
        ]
        return jsonify(popular_fuel_by_age)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        abort(500, f"Error: {error}")


# Analysis of Chauffeur Utilization:
@analytics.route("/analytics/chauffeur_stats", methods=["GET"])
def get_chauffeur_stats():
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()

        # SQL query
        query = """
            SELECT 
                ch.chauffeur_id, 
                ch.firstname, 
                ch.lastname, 
                COUNT(bd.booking_id) AS total_drives, 
                ROUND(AVG(bi.total_amount)::NUMERIC, 2) AS average_earning_per_trip
            FROM 
                chauffeur ch
            JOIN 
                booking_details bd ON ch.chauffeur_id = bd.chauffeur_id
            JOIN 
                billing_details bi ON bd.booking_id = bi.booking_id
            GROUP BY 
                ch.chauffeur_id
            HAVING 
                COUNT(bd.booking_id) > 0
            ORDER BY 
                total_drives DESC, 
                average_earning_per_trip DESC;
        """

        cursor.execute(query)
        chauffeur_stats = cursor.fetchall()
        chauffeur_stats = [
            {
                "chauffeur_id": row[0],
                "firstname": row[1],
                "lastname": row[2],
                "total_drives": row[3],
                "average_earning_per_trip": row[4],
            }
            for row in chauffeur_stats
        ]
        return jsonify(chauffeur_stats)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        abort(500, f"Error: {error}")


# Branch Performance Analysis:
@analytics.route("/analytics/branch_info", methods=["GET"])
def get_branch_info():
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()

        # SQL query
        query = """
            SELECT 
    br.branch_name, 
    COUNT(DISTINCT car.reg_no) AS number_of_cars,
    COUNT(DISTINCT CASE WHEN emp.department = 'HR' THEN emp.emp_id ELSE NULL END) AS hr_employees,
    COUNT(DISTINCT CASE WHEN emp.department = 'Finance' THEN emp.emp_id ELSE NULL END) AS finance_employees,
    COUNT(DISTINCT CASE WHEN emp.department = 'IT' THEN emp.emp_id ELSE NULL END) AS it_employees,
    COUNT(DISTINCT CASE WHEN emp.department = 'Sales' THEN emp.emp_id ELSE NULL END) AS sales_employees,
    COUNT(DISTINCT bd.booking_id) AS number_of_bookings,
    round(SUM(bi.total_amount)::numeric,2) AS total_revenue
FROM 
    branch_details br
LEFT JOIN 
    car ON br.branch_id = car.branch_id
LEFT JOIN 
    employee_details emp ON br.branch_id = emp.branch_id
LEFT JOIN 
    booking_details bd ON br.branch_id = bd.pick_up_location
LEFT JOIN 
    billing_details bi ON bd.booking_id = bi.booking_id
GROUP BY 
    br.branch_name;

                
        """

        cursor.execute(query)
        branch_info = cursor.fetchall()
        branch_info = [
            {
                "branch_name": row[0],
                "number_of_cars": row[1],
                "hr_employees": row[2],
                "finance_employees": row[3],
                "it_employees": row[4],
                "sales_employees": row[5],
                "number_of_bookings": row[6],
                "total_revenue": row[7],
            }
            for row in branch_info
        ]
        return jsonify(branch_info)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        abort(500, f"Error: {error}")


#  get the details of the car with the given registration number.
@analytics.route("/analytics/car_details", methods=["GET"])
def get_car_details():
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()

        reg_no = request.args.get("reg_no")
        print(reg_no)

        # SQL query
        query = """
           SELECT 
    car.reg_no, 
    car.model, 
    car.make, 
    COUNT(bd.booking_id) AS times_rented, 
    round(SUM(bi.total_amount)::numeric,2) AS total_revenue_generated, 
    round(AVG(bd.return_date - bd.pick_up_date)::numeric,2) AS average_rental_duration, 
    br.branch_name AS branch_name
FROM 
    car
LEFT JOIN 
    booking_details bd ON car.reg_no = bd.car_reg_no
LEFT JOIN 
    billing_details bi ON bd.booking_id = bi.booking_id
LEFT JOIN 
    branch_details br ON car.branch_id = br.branch_id
WHERE 
    car.reg_no = %s
GROUP BY 
    car.reg_no, br.branch_name;

        """

        # Executing the query
        cursor.execute(query, (reg_no,))
        car_details = cursor.fetchone()
        if car_details:
            result = {
                "reg_no": car_details[0],
                "model": car_details[1],
                "make": car_details[2],
                "times_rented": car_details[3],
                "total_revenue_generated": car_details[4],
                "average_rental_duration": car_details[5],
                "branch_name": car_details[6],
            }
            return jsonify(result)
        else:
            return jsonify({"error": "Car not found"}), 404
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        abort(500, f"Error: {error}")


# get membership statistics.
@analytics.route("/analytics/membership_stats", methods=["GET"])
def get_membership_stats():
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()

        # SQL query
        query = """
            SELECT 
                md.membership_type, 
                COUNT(DISTINCT c.customer_id) AS number_of_customers,
                SUM(bi.total_amount) AS total_revenue
            FROM 
                membership_details md
            JOIN 
                customer c ON md.customer_id = c.customer_id
            LEFT JOIN 
                booking_details bd ON c.customer_id = bd.customer_id
            LEFT JOIN 
                billing_details bi ON bd.booking_id = bi.booking_id
            GROUP BY 
                md.membership_type;
        """

        cursor.execute(query)
        membership_stats = cursor.fetchall()
        membership_stats = [
            {
                "membership_type": row[0],
                "number_of_customers": row[1],
                "total_revenue": row[2] if row[2] is not None else 0,
            }
            for row in membership_stats
        ]
        return jsonify(membership_stats)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        abort(500, f"Error: {error}")
