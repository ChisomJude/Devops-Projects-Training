#!/bin/bash

# Define file paths
CSV_FILE="employees.csv"
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"

# Ensure secure directory exists
mkdir -p /var/secure
chmod 700 /var/secure

# Function to log messages
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Read CSV and process entries
while IFS=',' read -r fullname username group sudo; do
    # Skip header row
    if [[ "$fullname" == "Fullname" ]]; then
        continue
    fi
    
    # Check and create group if it does not exist
    if ! getent group "$group" >/dev/null; then
        groupadd "$group"
        log_action "Group $group created."
    fi

    # Check if user exists
    if id "$username" &>/dev/null; then
        log_action "User $username already exists. Skipping."
        continue
    fi

    # Create user with home directory and bash shell
    useradd -m -s /bin/bash -g "$group" "$username"
    log_action "User $username created and added to group $group."

    # Generate a random password
    password=$(openssl rand -base64 12)
    echo "$username:$password" | chpasswd
    log_action "Password set for user $username."
    
    # Store password securely
    echo "$username:$password" >> "$PASSWORD_FILE"
    chmod 600 "$PASSWORD_FILE"

    # Grant sudo rights if required
    if [[ "$sudo" == "true" ]]; then
        usermod -aG sudo "$username"
        log_action "Sudo access granted for $username."
    fi

done < "$CSV_FILE"

log_action "User creation process completed successfully."
