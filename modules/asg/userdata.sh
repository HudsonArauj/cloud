# #!/bin/bash

# # Updating and installing required packages...
# sudo apt-get update
# sudo apt-get install -y python3-pip python3-venv git authbind awscli

# # Cloning the repository...
# git clone https://github.com/victorlga/simple_python_crud.git /home/ubuntu/simple_python_crud
# sudo chown -R ubuntu:ubuntu ~/simple_python_crud
# cd /home/ubuntu/simple_python_crud

# # Setting up Python virtual environment...
# python3 -m venv env
# source env/bin/activate
# pip install -r requirements.txt

# # Exporting environment variables...
# export DB_HOST=${db_host}
# export INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# # Creating log stream...
# aws logs create-log-stream --log-group-name "/my-fastapi-app/logs" --log-stream-name "$INSTANCE_ID" --region us-east-1

# # Setting up authbind for port 80...
# sudo touch /etc/authbind/byport/80
# sudo chmod 500 /etc/authbind/byport/80
# sudo chown ubuntu /etc/authbind/byport/80

# # Starting the application...
# authbind --deep uvicorn main:app --host 0.0.0.0 --port 80
