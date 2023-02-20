#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_NUMBER=$(($RANDOM % 1001))
NUMBER_OF_GUESSES=0

# -- USER INPUT -----------------------------------------------------------------

echo 'Enter your username:' 
read USERNAME

PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE name='$USERNAME'")

if [[ -z $PLAYER_ID && $USERNAME ]]
then
  INSERT_RESULT=$($PSQL "INSERT INTO players(name) VALUES('$USERNAME')")
  PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE name='$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES=$($PSQL "SELECT COUNT(*), MIN(number_of_guesses) FROM games JOIN players USING(player_id) WHERE player_id = $PLAYER_ID")
  echo $GAMES | while IFS='|' read GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# -- GAME LOOP -----------------------------------------------------------------

GAME(){
  echo $1
  read SECRET_NUMBER
  (( NUMBER_OF_GUESSES++ ))

  if [[ $SECRET_NUMBER =~ ^[0-9]*$ ]]
    then
    if(( $SECRET_NUMBER < $RANDOM_NUMBER ))
      then
      GAME "It's higher than that, guess again:"
    elif (( $SECRET_NUMBER > $RANDOM_NUMBER ))
      then
      GAME "It's lower than that, guess again:"
    else
      INSERT_RESULT=$($PSQL "INSERT INTO games(player_id, number_of_guesses) VALUES($PLAYER_ID, $NUMBER_OF_GUESSES)")
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
    fi
  else
    GAME "That is not an integer, guess again:"
  fi
}

# -- STARTS GAME -----------------------------------------------------------------

if [[ $PLAYER_ID ]]
then
  GAME "Guess the secret number between 1 and 1000:"
else
  echo "Sorry something went wrong. Ending game."
fi