#!/bin/bash

PSQL='psql --username=freecodecamp --dbname=salon -t -c'

# echo $($PSQL "SELECT * FROM services")

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  
    read SERVICE_ID_SELECTED
    SELECTED_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ $SELECTED_SERVICE_NAME ]]
    then
      echo "What's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_ID ]]
      then
        echo "I don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
      fi
      FORMATED_SERVICE_NAME=$(echo $SELECTED_SERVICE_NAME | sed -E 's/^ *| *$//g')
      FORMATED_CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')
      echo "What time would you like your $FORMATED_SERVICE_NAME, $FORMATED_CUSTOMER_NAME?"
      read SERVICE_TIME
      INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      echo "I have put you down for a $FORMATED_SERVICE_NAME at $SERVICE_TIME, $FORMATED_CUSTOMER_NAME."
    else
      MAIN_MENU "I could not find that service. What would you like today?"
    fi
}

echo -e "\n~~~~~ Salon ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"
MAIN_MENU