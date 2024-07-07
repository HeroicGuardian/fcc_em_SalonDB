#! /bin/bash

# Print title text
echo -e "\n======== Fuadibolagodo Salon ========\n"

# Define PostgreSQL command setup variable
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Find the list of the salon's services in the database, and store it in a variable
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

# Define the MENU() fuction
MENU()
{
  # Print menu sendback text
  echo -e "\n$1\n"

  # Display list of services using previously defined variable
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done
  
  # Capture the user's choice of service
  read SERVICE_ID_SELECTED

  # Find the user's service ID of choice in the database and enter the result into a variable
  SERVICE_AVAILABILITY=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # If the variable is empty, the service does not exist, and so the user is sent back to the list of services
  # If the variable in not empty, the service does exist, and so processes continue as usual
  if [[ -z $SERVICE_AVAILABILITY ]]
  then
    # Send the user back to the list of services with a clarifying message
    MENU "Please type the corresponding number of the service you would like."
  else
    # Get the user's phone number and look for it in the database
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    PHONE_IN_DATABASE=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    
    # If the user's phone number is not found in the database, that means the user is a new customer
    # If the user's phone number is found in the database, that means the user is a previous cumtomer of the salon
    if [[ -z $PHONE_IN_DATABASE ]]
    then
      # Collect the user's name and insert their phone number and name into the database
      echo -e "\nIt seems like you're a new customer. What's your name?"
      read CUSTOMER_NAME
      ENTER_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    else
      # Find the user's name in the database
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi

    # Find the user's customer ID in the database
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # Collect the user's input as to which time they would like to book their appointment, and enter the appointment into the database
    echo -e "\nWhat time would you like to book your appointment for?"
    read SERVICE_TIME
    ENTER_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
    
    # Find the name of the user's service of choice in the database, and pipe it into a 'sed' command to remove any extra spaces at the beginning or end
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    
    # Give the user a confirmation message
    echo -e "\nI have put you down for a $(echo "$SERVICE_NAME" | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $(echo "$CUSTOMER_NAME" | sed -E 's/^ *| *$//g')."
  fi
}

# Start the menu process, and give the user a welcome message
MENU "You deserve only the best. What would you like?"
