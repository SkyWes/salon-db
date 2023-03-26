#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU() {
if [[ $1 ]]
then
  echo -e "\n$1"
else
echo -e "\nWelcome to My Salon, how can I help you?\n"
fi
# select service
SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
echo  "$SERVICES" | while read ID BAR NAME
do
  echo "$ID) $(echo $NAME | sed -E 's/^ *| *$//g')"
done
read SERVICE_ID_SELECTED
}

APPOINTMENT_MENU(){
# if not a number
if [[ ! $1 =~ ^[0-5]$ ]]
then
# send to main menu
MAIN_MENU "I could not find that service. What would you like today?"
else
echo -e "\n$1"
fi
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
# get customer info
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_NAME ]]
then
# get new customer name
 echo -e "\nI don't have a record for that phone number, what's your name?"
 read CUSTOMER_NAME
 # insert new customer
 INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
fi
# get service name
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

FORMAT_NAME=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')
FORMAT_SERVICE=$(echo $SERVICE_NAME | sed -E 's/^ *| *$//g')

echo -e "What time would you like your $FORMAT_SERVICE, $FORMAT_NAME?"
read SERVICE_TIME

# get customer id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
# set appointment
SET_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
# format results
FORMAT_TIME=$(echo $SERVICE_TIME | sed -E 's/^ *| *$//g')

echo -e "\nI have put you down for a $FORMAT_SERVICE at $FORMAT_TIME, $FORMAT_NAME."
}

MAIN_MENU
APPOINTMENT_MENU $SERVICE_ID_SELECTED
