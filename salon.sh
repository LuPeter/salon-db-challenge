#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"


MAIN_MENU () {
  if [[ $1 ]]
    then
      echo "$1"
    else
      echo -e "Welcome to My Salon, how can I help you?\n"
  fi

  echo "$($PSQL "select * from services")" | while read SERVICE_ID BAR SERIVCE_NAME;
  do
    echo "$SERVICE_ID) $SERIVCE_NAME"
  done
  
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED"  | sed -E 's/^ *| *$//g')
  
  if [[ -z $SERVICE_NAME ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'" | sed -E 's/^ *| *$//g')

      if [[ -z $CUSTOMER_NAME ]]
        then
          echo -e "I don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
            
          echo "$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")"
      fi

      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME

      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
      echo "$($PSQL "insert into appointments(customer_id, service_id, time) values('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")"

      echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU

