from flask import Flask, render_template, request, jsonify, redirect, url_for
import requests

app = Flask(__name__)


@app.route("/")
def home():
    return render_template("index.html")


@app.route("/create-booking", methods=["GET", "POST"])
def create_booking():
    if request.method == "POST":
        print("=====================================")
        # Extract data from form and send POST request
        data = {
            "booking_date": request.form["booking_date"],
            "pick_up_date": request.form["pick_up_date"],
            "return_date": request.form["return_date"],
            "customer_id": request.form["customer_id"],
            "pick_up_location": request.form["pick_up_location"],
            "return_location": request.form["return_location"],
            "emp_id": request.form["emp_id"],
            "chauffeur_id": request.form["chauffeur_id"],
            "insurance_category": request.form["insurance_category"],
            "car_reg_no": request.form["car_reg_no"],
        }

        response = requests.post("http://127.0.0.1:5000/booking", json=data)
        # Check if response is valid and render a template with the data
        print(response)
        # return jsonify(response.json())  # or redirect to a success page
        if response.ok:
            return render_template(
                "booking_response.html", booking_data=response.json()
            )
        else:
            return response.text, 500
    print("oits getting here")
    return render_template("create_booking.html")


@app.route("/view-booking", methods=["GET", "POST"])
def view_booking():
    if request.method == "POST":
        booking_id = request.form["booking_id"]
        response = requests.get(
            f"http://127.0.0.1:5000/analytics/bookings/{booking_id}"
        )

        booking_data = response.json()
        print(booking_data)
        if response.ok:
            return render_template("booking_details.html", booking_data=response.json())
        else:
            return "Error fetching details", 500
    return render_template("view_booking.html")


if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True, port=5001)
