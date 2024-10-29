#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"




echo "Enter your username: "


read USERNAME

if [[ ${#USERNAME} -gt 22 ]]
then
  echo "Your username is too long! Please use up to 22 characters."
fi

# Query the database for the user
USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 9999)")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  GAMES_PLAYED=0
  BEST_GAME=9999
 
else
  IFS="|" read USER_ID GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

fi

# begin game
RANDOM_NUMBER=$((RANDOM % 1000 + 1))
echo $RANDOM_NUMBER

echo "Guess the secret number between 1 and 1000:"
GUESS_COUNT=0

while true
do
  read GUESS
 
  GUESS_COUNT=$((GUESS_COUNT + 1))
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -lt $RANDOM_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -gt $RANDOM_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  else
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
    NEW_BEST_GAME=$((GUESS_COUNT < BEST_GAME ? GUESS_COUNT : BEST_GAME))
    UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1, best_game = $NEW_BEST_GAME WHERE user_id = $USER_ID;")
    break
  
  fi

done






