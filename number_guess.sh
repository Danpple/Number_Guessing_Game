#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo "Enter your username:"
read USERNAME

PLAYER_USERNAME=$($PSQL "SELECT username FROM players WHERE username='$USERNAME'")
# if player doesn't exist
if [[ -z $PLAYER_USERNAME ]]; then
	INSERT_NEW_PLAYER=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME')")
  echo -e "\nWelcome, $(echo $USERNAME | sed -E 's/^ *| *$//g')! It looks like this is your first time here.\n"
else
  player_id=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME'")
  played_games=$($PSQL "SELECT SUM(game_played) FROM games WHERE player_id=$player_id")
  best_game=$($PSQL "SELECT MIN(best_game) FROM games WHERE player_id=$player_id")
  echo -e "\nWelcome back, $(echo $USERNAME | sed -E 's/^ *| *$//g')! You have played $(echo $played_games | sed -E 's/^ *| *$//g') games, and your best game took $(echo $best_game | sed -E 's/^ *| *$//g') guesses.\n"
fi

guess=-1
typeset -i num=0

echo -e "Guess the secret number between 1 and 1000:"

### Generate random number
(( answer = RANDOM % 1000 + 1 ))

### Play game
while (( guess != answer )); do
  if [[ ! $guess =~ [0-9] ]]
  then
    echo "That is not an integer, guess again:"
  fi
	num=num+1
	read guess
	if (( guess < answer )); then
		echo "It's higher than that, guess again:"
	elif (( guess > answer )); then
		echo "It's lower than that, guess again:"
	fi
done
echo "You guessed it in $num tries. The secret number was $answer. Nice job!"

### Save best game
PLAYER_IDS=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME'")
BEST_GAME=$($PSQL "INSERT INTO games(game_played, best_game, player_id) VALUES(1, $num, $PLAYER_IDS)")
