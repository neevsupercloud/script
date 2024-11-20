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

# Step 3: Generate random username and password
username=$(generate_random_credential)
password=$username

# Step 4: Add the user directly to the Squid password file
echo "Adding the user to the Squid password file..."
sudo apt-get install -y apache2-utils  # Install htpasswd utility
sudo htpasswd -b -c /etc/squid/passwd "$username" "$password"

# Step 5: Update Squid configuration to use the password file if necessary
echo "Ensuring Squid is configured to use the password file..."
if ! grep -q "auth_param basic program /usr/lib/squid3/basic_ncsa_auth /etc/squid/passwd" /etc/squid/squid.conf; then
    echo "auth_param basic program /usr/lib/squid3/basic_ncsa_auth /etc/squid/passwd" | sudo tee -a /etc/squid/squid.conf
    echo "auth_param basic children 5" | sudo tee -a /etc/squid/squid.conf
    echo "auth_param basic realm Squid proxy-caching web server" | sudo tee -a /etc/squid/squid.conf
    echo "auth_param basic credentialsttl 2 hours" | sudo tee -a /etc/squid/squid.conf
    echo "auth_param basic casesensitive off" | sudo tee -a /etc/squid/squid.conf
    echo "acl ncsa_users proxy_auth REQUIRED" | sudo tee -a /etc/squid/squid.conf
    echo "http_access allow ncsa_users" | sudo tee -a /etc/squid/squid.conf
    sudo systemctl restart squid
fi

# Step 6: Store the credentials in a file
echo "Storing credentials in password.txt..."
echo "Username: $username" > password.txt
echo "Password: $password" >> password.txt

# Step 7: Display the credentials
echo "Displaying the created credentials:"
cat password.txt
