#!/bin/bash

# Function to generate random 8-character alphanumeric string
generate_random_credential() {
    local credential=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 8)
    echo "$credential"
}

# Step 1: Attempt to uninstall Squid
echo "Checking and uninstalling Squid if present..."
if sudo squid-uninstall; then
    echo "Squid proxy was installed and has been uninstalled."
else
    echo "Squid proxy is not installed, skipping uninstall."
fi

# Step 2: Install Squid proxy
echo "Installing Squid proxy..."
wget https://raw.githubusercontent.com/serverok/squid-proxy-installer/master/squid3-install.sh -O squid3-install.sh
sudo bash squid3-install.sh

# Step 3: Add a Squid user with a random username and password
echo "Adding a Squid user..."
username=$(generate_random_credential)
password=$username
echo -e "$password\n$password" | sudo squid-add-user "$username"

# Step 4: Store the username and password in a file
echo "Storing credentials in password.txt..."
echo "Username: $username" > password.txt
echo "Password: $password" >> password.txt

# Step 5: Display the credentials
echo "Displaying the created credentials:"
cat password.txt
