# Car Rental Database Project

## Project Overview
This project is aimed at building a comprehensive car rental management system that leverages a cloud-based approach using AWS services. It includes functionalities such as managing car rentals, handling customer data, and processing transactions securely and efficiently.

## Technologies Used
- **AWS RDS PostgreSQL**: Cloud relational database service for storing all rental, customer, and transaction data.
- **Python/Flask**: Backend API development for business logic and database interactions.
- **HTML/CSS/JavaScript**: Frontend development for the user interface.
- **AWS CodePipeline**: Continuous integration and continuous deployment.
- **AWS CodeBuild and CodeDeploy**: Building and deploying the application.
- **Git**: Source code management.

## Project Structure
- **backend/**: Server-side code written in Flask, handling API requests and database interaction.
- **frontend/**: Client-side code including HTML, CSS, and JavaScript.
- **scripts/**: Scripts for database schema and initial data loading.
- **deploy_scripts/**: Contains deployment scripts and AWS configuration files.
- **README.md**: This documentation file.
- **appspec.yml**: AWS CodeDeploy specifications.
- **buildspec.yml**: AWS CodeBuild specifications for build commands.
- **pipeline.yml**: Definitions for AWS CodePipeline setup.
- **template.yml, templateparameters.json**: AWS CloudFormation templates for resource provisioning.

## File Metadata
- **appspec.yml**: Manages application deployments on AWS EC2/On-premise servers via AWS CodeDeploy.
- **buildspec.yml**: Contains build instructions for AWS CodeBuild.
- **create.sql**: SQL scripts to initialize the database schema in AWS RDS PostgreSQL.
- **load.sql**: SQL scripts for pre-loading the database with necessary initial data.
- **pipeline.yml**: Configuration for the CI/CD pipeline facilitating automated builds and deployments.
- **template.yml & templateparameters.json**: Templates for setting up AWS infrastructure using CloudFormation.

## Implementation Guide

### Setting Up the Environment
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/car_rental.git
   cd car_rental

2. **Automated Deployment**:
   - Commit and push your changes to the designated branch (e.g., `dev`) in your repository.
   - The AWS CodePipeline configured in `pipeline.yml` will automatically trigger, building and deploying your application:
     - `buildspec.yml` will handle the build process.
     - `appspec.yml` will specify the deployment actions on AWS.

3. **Configure AWS RDS PostgreSQL**:
   - Once the deployment is successful and the infrastructure is ready, access your AWS RDS instance.
   - Use the `scripts/create.sql` and `scripts/load.sql` files to set up your database schema and load initial data. These scripts can be run from an SQL client connected to your RDS instance.

4. **Configure the Backend**:
   - Ensure the backend environment variables are set correctly to connect to the RDS instance.
   - If needed, make adjustments directly in the AWS environment or through environment configuration files.

5. **Set Up the Frontend**:
   - After the backend is configured and running, proceed to set up the frontend.
   - Ensure that the frontend is properly pointing to the correct backend endpoints.
   - Test the frontend functionality to ensure it interacts correctly with the backend.

