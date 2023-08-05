#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

IFS="|" read GAME_PLAYED BEST_GAME <<< "$(echo $($PSQL "SELECT games_played, best_game FROM users WHERE username = '$USERNAME'"))"

if [[ -z $GAME_PLAYED || -z $BEST_GAME ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  # insert into users
  INSERT_INTO_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  echo -e "\nWelcome back, $USERNAME! You have played $GAME_PLAYED games, and your best game took $BEST_GAME guesses.
"
fi

SECRET=$((RANDOM % 1000 + 1))
GUESSED_TIME=0

GUESS_NUMBER() {
  if [[ $1 ]]
  then
    echo $1
  fi
  # echo $SECRET
  read NUMBER_GUESSED
  # if not a number
  if [[ ! $NUMBER_GUESSED =~ ^[0-9]+$ ]]
  then
    # guess again
​    GUESSED_TIME=$((GUESSED_TIME + 1))
​    GUESS_NUMBER "That is not an integer, guess again:"
  else
    # greater than the secret number
​    if [[ $NUMBER_GUESSED > $SECRET ]]
​    then
​      GUESSED_TIME=$((GUESSED_TIME + 1))
​      GUESS_NUMBER "It's lower than that, guess again:"
    # lower than the secret number
​    elif [[ $NUMBER_GUESSED < $SECRET ]]
​    then
​      GUESSED_TIME=$((GUESSED_TIME + 1))
​      GUESS_NUMBER "It's higher than that, guess again:"
    # bingoed
​    elif [[ $NUMBER_GUESSED == $SECRET ]]
​    then
​      GUESSED_TIME=$((GUESSED_TIME + 1))
​      echo "You guessed it in $GUESSED_TIME tries. The secret number was $SECRET. Nice job!"
​      UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME'")
      # seems a bug here
​      if [[ -z $BEST_GAME ]]
​      then
​        UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game = $GUESSED_TIME WHERE username = '$USERNAME'")
​      elif [[ $GUESSED_TIME < $BEST_GAME ]]
​      then
​        UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game = $GUESSED_TIME WHERE username = '$USERNAME'")
​      fi
​    fi
  fi
}

GUESS_NUMBER "Guess the secret number between 1 and 1000:"