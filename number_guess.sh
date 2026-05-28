#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=0

echo "Enter your username:"
read USERNAME

USER_DATA=$($PSQL "
SELECT games_played, best_game
FROM number_guessing_game
WHERE username='$USERNAME'
")

USER_DATA=$($PSQL "SELECT games_played, best_game FROM number_guessing_game WHERE username='$USERNAME'")
if [[ -z $USER_DATA ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."

  INSERT_USER=$($PSQL "INSERT INTO number_guessing_game(username, games_played) VALUES('$USERNAME', 0)")
else
  IFS="|" read GAMES_PLAYED BEST_GAME <<< $USER_DATA

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"

while true
do
  read GUESS

  ((NUMBER_OF_GUESSES++))

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  else
    break
  fi
done

UPDATE_GAMES=$($PSQL "UPDATE number_guessing_game SET games_played = games_played + 1 WHERE username='$USERNAME'")

UPDATE_BEST_GAME=$($PSQL "UPDATE number_guessing_game SET best_game = $NUMBER_OF_GUESSES WHERE username='$USERNAME' AND (best_game IS NULL OR $NUMBER_OF_GUESSES < best_game)")


echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"