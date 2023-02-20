#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# clear the db
echo $($PSQL "TRUNCATE games, teams")

cat games.csv | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
if [[ $year != 'year' ]]
then

  # get the winner id
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner'")
  if [[ ! $WINNER_ID ]]
  then
    # Add winner to database if not exist
    INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$winner')")
    if [[ $INSERT_WINNER_RESULT == 'INSERT 0 1' ]]
    then
      # Redo query to get ID of the added team
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner'")
      echo "Added team '$winner' with ID: '$WINNER_ID'"
    fi
  fi

  # get the opponent id
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent'")
  if [[ ! $OPPONENT_ID ]]
  then
    # Add opponent to database if not exist
    INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$opponent')")
    if [[ $INSERT_OPPONENT_RESULT == 'INSERT 0 1' ]]
    then
      # Redo query to get ID of the added team
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent'")
      echo "Added team '$opponent' with ID: '$OPPONENT_ID'"
    fi
  fi

  # add the game --> since we truncate the db before no need for checks
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$year', '$round', '$WINNER_ID', '$OPPONENT_ID', '$winner_goals', '$opponent_goals')")
  if [[ $INSERT_OPPONENT_RESULT == 'INSERT 0 1' ]]
  then
    echo "Added game between '$winner' and '$opponent'"
  fi
fi
done
