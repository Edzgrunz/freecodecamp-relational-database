#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
JOINED_QUERY="SELECT * FROM elements JOIN properties USING(atomic_number) JOIN types USING(type_id)"

if [[ $1 ]] # ATOMIC_NUMBER, SYMBOL OR NAME
then
  if [[ $1 =~ ^[0-9]*$ ]]
  then
    ELEMENT=$($PSQL "$JOINED_QUERY WHERE atomic_number = $1")
  else
    ELEMENT=$($PSQL "$JOINED_QUERY WHERE name = '$1' OR symbol = '$1'")
  fi

  if [[ $ELEMENT ]]
  then
    echo "$ELEMENT" | while IFS='|' read TYPE_ID ATOMIC_NUMBER SYMBOL NAME ATOMIC_MASS MELTING BOILING TYPE
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
    done
  else
    echo "I could not find that element in the database."
  fi
else
  echo "Please provide an element as an argument."
fi