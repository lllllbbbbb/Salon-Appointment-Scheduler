#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e '\n~~~~~ MY SALON ~~~~~\n'

SERVICE_MENU(){
  # get available services
  SERVICES_LIST="$($PSQL "SELECT service_id, name FROM services")"
    # display services
      echo -e "\nWelcome to My Salon, how can I help you?"
      echo "$SERVICES_LIST" | while read SERVICE_ID_SELECTED SERVICE_NAME
    do
      echo "$SERVICE_ID_SELECTED) $SERVICE_NAME" | sed 's/ |//'
    done
    read SERVICE_ID_SELECTED
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | sed 's/ //')      
    # if input is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
      then
      # send back to menu
        SERVICE_MENU "I could not find that service. What would you like today?"
      else
        # get customer info
          echo -e "\nWhat's your phone number?"
          read CUSTOMER_PHONE
          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        # if customer doesnt exist
      if [[ -z $CUSTOMER_NAME ]]
        then
        # get new customer name
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
        # insert new customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        fi
        # get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        # insert time of appointment
        echo -e "\n What time would you like your $SERVICE_NAME, $CUSTOMER_NAME ?"
        read SERVICE_TIME
        INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
        # confirmation of appointment
        echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  }

SERVICE_MENU
