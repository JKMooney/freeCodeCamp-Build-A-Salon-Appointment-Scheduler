#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Name of business
echo -e "\n~~~~~ MY SALON ~~~~~\n"

# MAIN_MENU function
MAIN_MENU() {
  if [[ $1 ]]
  then
  echo -e "\n$1"
  fi

# welcome message
echo -e "Welcome to My Salon, how can I help you?\n"
# get services
SERVICE_OPTIONS=$($PSQL "SELECT service_id, name FROM services")
# list services
echo "$SERVICE_OPTIONS" | while read SERVICE_ID BAR NAME
do
echo "$SERVICE_ID) $NAME"
done
# read service choice
read SERVICE_ID_SELECTED
# if the service selected is not a number
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
# send to main menu
MAIN_MENU "I could not find that service. What would you like today?"
else
# ask phone number
echo -e "What's your phone number?"
# read phone number
read CUSTOMER_PHONE
# get customer name
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
# get service name
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
# if customer name does not exist
if [[ -z $CUSTOMER_NAME ]]
then
# get customer phone
echo "I don't have a record for that phone number, what's your name?"
# get customer name
read CUSTOMER_NAME
# insert the phone and name into db
INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi
# What time would you like your <service>, <name>?
echo "What time would you like your $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *\ *$//g')?"
# read the time
read SERVICE_TIME
# get customer id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
# insert a new appointment into the db with the service_id and time
INSERT_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
# I have put you down for a <service> at <time>, <name>.
echo "I have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -E 's/^ *\ *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
fi
}


MAIN_MENU
