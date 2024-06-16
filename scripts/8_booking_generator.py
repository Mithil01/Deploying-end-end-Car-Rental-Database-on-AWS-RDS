from datetime import datetime, timedelta
import json
from math import pi
import random
import re
import time

import requests


# send post request function
def run_post_request(booking_details):
    # URL and Headers
    url = "http://127.0.0.1:5000/booking"
    headers = {"Content-Type": "application/json"}
    response = requests.post(url, headers=headers, data=json.dumps(booking_details))
    return response


for branch_id in range(50, 51):
    print("<------------------------------------>")
    print(f"Branch ID: {branch_id}")
    print("<------------------------------------>")

    # get branch content
    # URL for the GET request
    url = "http://127.0.0.1:5000/get_branch_offers"

    # Parameters for the GET request
    params = {"branch_id": branch_id}

    # Sending the GET request
    branch_content = requests.get(url, params=params).json()

    for _ in range(0, 300):
        time.sleep(0.3)
        # get counts of all the lists
        branch_sales_employees_count = len(branch_content["branch_sales_employees"])
        car_details_count = len(branch_content["car_details"])
        chauffer_details_count = len(branch_content["chauffer_details"])
        insurance_details_count = len(branch_content["insurance_details"])

        # generate dates
        today = datetime.now().date()
        random_days = random.randint(0, 50)
        pickup_date = today + timedelta(days=random_days)
        dropoff_date = pickup_date + timedelta(days=random.randint(1, 10))

        # modify dates
        pickup_date = pickup_date.strftime("%Y-%m-%d")
        dropoff_date = dropoff_date.strftime("%Y-%m-%d")

        # select chauffeur
        chauffeur_id = random.randint(0, 1)
        if chauffeur_id == 0:
            chauffeur_id = None
        else:
            chauffeur_id = branch_content["chauffer_details"][
                random.randint(0, chauffer_details_count - 1)
            ]["chauffeur_id"]

        # make booking details
        booking_details = {
            "booking_date": "2020-12-04",
            "pick_up_date": pickup_date,
            "return_date": dropoff_date,
            "customer_id": random.randint(101, 300),
            "pick_up_location": branch_id,
            "return_location": branch_id,
            "emp_id": branch_content["branch_sales_employees"][
                random.randint(0, branch_sales_employees_count - 1)
            ]["emp_id"],
            "chauffeur_id": chauffeur_id,
            "insurance_category": branch_content["insurance_details"][
                random.randint(0, insurance_details_count - 1)
            ]["insurance_category"],
            "car_reg_no": branch_content["car_details"][
                random.randint(0, car_details_count - 1)
            ]["reg_no"],
        }

        print(json.dumps(booking_details, indent=4))
        output = run_post_request(booking_details)
        print(output)
        print("====================================")
