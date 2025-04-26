#!/bin/bash

# Variables for SSH and remote paths

SSH_USER="user"

SSH_HOST="10.5.5.100"

REMOTE_DOCKERFILE_PATH="/home/user/tomcat/Dockerfile"  # Adjust this to the correct path on the remote server

REMOTE_TOMCAT_USERS_PATH="/home/user/tomcat/tomcat-users.xml"  # Adjust this to the correct path on the remote server

WORDLIST_PATH="/home/user/wordlist.txt"  # Adjust this to the correct path on the remote server

REMOTE_WORK_DIR="/home/user/tomcat/"  # Adjust this to the working directory on the remote server

# SSH command prefix

SSH_CMD="ssh -o StrictHostKeyChecking=no ${SSH_USER}@${SSH_HOST}"

# Step 1: Retrieve the token value and generate a password on the remote server

TOKEN1=$(vmtoolsd --cmd "info-get guestinfo.token1")

TOKEN2=$(vmtoolsd --cmd "info-get guestinfo.token2")

ADMIN_PASS=$(shuf -n 1 ${WORDLIST_PATH})

# STEP 1a: Put token2 into a file and move it to the tomcat server

echo $TOKEN2 > TOKEN2.txt

scp -o "StrictHostKeyChecking=no" ./TOKEN2.txt $SSH_USER@$SSH_HOST:/home/user/

# Step 2: Replace placeholders in Dockerfile and tomcat-users.xml remotely

$SSH_CMD "sudo sed -i 's/##PASS##/${ADMIN_PASS}/g' ${REMOTE_DOCKERFILE_PATH}"

$SSH_CMD "sudo sed -i 's/##TOKEN1##/${TOKEN1}/g' ${REMOTE_DOCKERFILE_PATH}"

$SSH_CMD "sudo sed -i 's/##PASS##/${ADMIN_PASS}/g' ${REMOTE_TOMCAT_USERS_PATH}"

# Step 3: Build the Docker image on the remote server.  This will suppress stdout, but still show errors in the journal

$SSH_CMD "cd ${REMOTE_WORK_DIR} && sudo docker build -t tomcat . > /dev/null"

# Step 4: Stop and remove any existing container on the remote server

$SSH_CMD "sudo docker stop tomcat || true && sudo docker rm tomcat || true"

# Step 5: Run the Docker container on the remote server with Docker socket exposure. This will suppress stdout, but still show errors in the journal

$SSH_CMD "sudo docker run -d \

  --network host \

  --name tomcat \

  -v /var/run/docker.sock:/var/run/docker.sock \

  tomcat > /dev/null"

# Step 6: Output the admin password and token value

echo "Deployed on ${SSH_HOST}. Admin password: ${ADMIN_PASS}, Token1: ${TOKEN1}, Token2: ${TOKEN2}"

