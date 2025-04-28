#!/bin/bash

FLAG1="{flag} $(shuf -n 1 wordlist.txt)-$(shuf -n 1 wordlist.txt)-$(hexdump -n 2 -e '4/1 "%02x"' /dev/urandom)"
FLAG2="{flag} $(shuf -n 1 wordlist.txt)-$(shuf -n 1 wordlist.txt)-$(hexdump -n 2 -e '4/1 "%02x"' /dev/urandom)"
ADMIN_PASS=$(shuf -n 1 wordlist.txt)

# STEP 1a: Put FLAG2 into a file

echo $FLAG2 > FLAG2.txt

# Step 2: Replace placeholders in Dockerfile and tomcat-users.xml

sudo sed -i "s/##PASS##/${ADMIN_PASS}/g" Dockerfile

sudo sed -i "s/##FLAG1##/${FLAG1}/g" Dockerfile

sudo sed -i "s/##PASS##/${ADMIN_PASS}/g" tomcat-users.xml

# Step 3: Build the Docker image.  This will suppress stdout, but still show errors in the journal

sudo docker build -t tomcat . > /dev/null

# Step 4: Stop and remove any existing container

sudo docker stop tomcat || true && sudo docker rm tomcat || true

# Step 5: Run the Docker container on the remote server with Docker socket exposure. This will suppress stdout, but still show errors in the journal

sudo docker run -d \

--network host \

--name tomcat \

-v /var/run/docker.sock:/var/run/docker.sock \

tomcat > /dev/null

# Step 6: Output the admin password and FLAG value

echo "Deployed. Admin password: ${ADMIN_PASS}, FLAG1: ${FLAG1}, FLAG2: ${FLAG2}" > current_flags.txt

