#!/bin/bash

This script is executed on the EC2 instance upon launch.
It automates the entire application deployment process.
Exit immediately if a command exits with a non-zero status.
set -e

--- 1. Pass Stage Parameter & Load Config ---
The 'stage' variable is injected by Terraform's templatefile function.
echo "Starting deployment for stage: ${stage}"

Check if the stage is 'dev' or 'prod' and load the corresponding config file.
Since the files are currently empty, this is just for demonstration purposes.
if [ "stage"=="dev"];thenecho"Loadingdevconfiguration..."#Placeholderforacommandthatwouldusethedev_configfile.#Forexample:source/config/dev_configelif["{stage}" == "prod" ]; then
echo "Loading prod configuration..."
# Placeholder for a command that would use the prod_config file.
# For example: source /config/prod_config
else
echo "Unknown stage '${stage}'. Using default behavior."
fi

--- 2. Install Dependencies ---
Update the package list and install necessary dependencies:
- openjdk-21-jdk: The required Java version.
- maven: To build the Java application.
- git: To clone the GitHub repository.
echo "Updating packages and installing Java 21, Git, and Maven..."
sudo apt-get update -y
sudo apt-get install -y openjdk-21-jdk maven git

--- 3. Clone Repository and Build Application ---
echo "Cloning repository from GitHub..."
git clone https://www.google.com/search?q=https://github.com/Trainings-TechEazy/test-repo-for-devops.git

echo "Building the application with Maven..."
cd test-repo-for-devops
mvn clean package

--- 4. Run the Application in the Background ---
Use 'nohup' and '&' to run the application in the background and
to prevent it from stopping when the user data script finishes.
echo "Starting the application..."
nohup java -jar target/techeazy-devops-0.0.1-SNAPSHOT.jar > /dev/null 2>&1 &

--- 5. Test if App is Reachable ---
Note: The assignment says port 80, but your Terraform security group
opens port 9090. The application will be running on port 9090.
echo "Testing if the application is reachable on port 9090..."
ATTEMPTS=0
MAX_ATTEMPTS=12 # Wait up to 60 seconds (12 * 5 seconds)
while [ $ATTEMPTS -lt MAX_ATTEMPTS];doHTTP_STATUS=(curl -s -o /dev/null -w "%{http_code}" http://localhost:9090)
if [ "$HTTP_STATUS" == "200" ]; then
echo "Application is up and running!"
break
else
echo "App not yet reachable (status: HTTP_STATUS).Retryingin5seconds..."sleep5ATTEMPTS=((ATTEMPTS + 1))
fi
done

if [ $ATTEMPTS -eq $MAX_ATTEMPTS ]; then
echo "ERROR: Application did not become reachable within the timeout period."
fi

--- 6. Schedule Instance Shutdown for Cost Savings ---
This command schedules the instance to shut down 30 minutes from now.
echo "Scheduling instance to shut down in 30 minutes to save costs."
sudo shutdown -h +30

echo "Deployment complete!"
