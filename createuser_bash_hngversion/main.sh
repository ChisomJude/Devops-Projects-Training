#!/bin/bash

# intialise the  variables  to be used,you have to create this file or point your viariable to the path you created for it
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_password.txt"
USERS_FILE="/home/chisom/createuser/users.txt"

if [ ! -f $USERS_FILE ]; then
  echo "$USERS_FILE Not Found"
else
  echo "Great! File Exist"
fi

while IFS=";" read -r username groups; do
  # Create groups if they don't exist
  for group in ${groups//, / }; do
    if ! getent group "$group" >/dev/null 2>&1; then
      sudo groupadd "$group"
    else
      echo "Group '$group' already exists"
    fi
  done

  # Create the user and assign the groups
  sudo useradd -m -G "$groups" "$username"
  
  # Check if user was created successfully
  if id "$username" &>/dev/null; then
    echo "$username created and added to $groups" >> "$LOG_FILE"
  else
    echo "Failed to create user $username" >> "$LOG_FILE"
  fi
done <"$USERS_FILE"
