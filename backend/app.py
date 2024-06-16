from flask import Flask, request, jsonify
from routes.dummy import dummy
from routes.employee_portal.get_cars import get_cars
import routes.employee_portal.get_branch_offers as get_branch_offers
from routes.employee_portal.get_customer_details import get_customer_details
from routes.book_portal.booking import booking
from routes.analytics_portal.analytics import analytics

app = Flask(__name__)

# Register blueprints
app.register_blueprint(dummy)
app.register_blueprint(get_cars)
app.register_blueprint(get_branch_offers.get_branch_offers)
app.register_blueprint(get_customer_details)
app.register_blueprint(booking)
app.register_blueprint(analytics)


@app.route("/")
def home():
    return "Hello World"
