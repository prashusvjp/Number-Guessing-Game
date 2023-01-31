#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guessing_game -t --no-align -c"

echo "Enter your username:"
read USERNAME

#check user exists
GET_USER_DATA="$($PSQL "select username,count(*),min(number_of_guesses) from users inner join games using(user_id) 
where username='$USERNAME' group by user_id")"
if [[ -z $GET_USER_DATA ]]
then
  INSERT_DATA_RESULT="$($PSQL "insert into users(username) values('$USERNAME');")"
  if [[ $INSERT_DATA_RESULT == "INSERT 0 1" ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  fi
else
  echo $GET_USER_DATA | sed 's/|/ /g' | while read USERNAME GAME_COUNT BEST_GUESS
  do
    echo "Welcome back, $USERNAME! You have played $GAME_COUNT games, and your best game took $BEST_GUESS guesses."
  done  
fi

SECRET_NUMBER=$(($RANDOM % 1000 + 1))
NUMBER_OF_GUESSES=0
END=0
while [[ $END == 0 ]]
do
  
  if [[ $NUMBER_OF_GUESSES == 0 ]]
  then
    echo "Guess the secret number between 1 and 1000:"
  fi
  read GUESS

  (( NUMBER_OF_GUESSES++ ))

  if [[ ! $GUESS =~ ([0-9]+) ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  if [[ $GUESS == $SECRET_NUMBER ]]
  then
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    USER_ID="$($PSQL "select user_id from users where username='$USERNAME';")"
    INSERT_DATA_RESULT=$($PSQL "insert into games(user_id,number_of_guesses) values($USER_ID, $NUMBER_OF_GUESSES);")
    if [[ $INSERT_DATA_RESULT == "INSERT 0 1" ]]
    then
      END=1
    fi
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi
done


