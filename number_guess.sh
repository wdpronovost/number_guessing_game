#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAIN_MENU () {
    if [[ ! $1 ]]
    then
        # start game, ask for username
        echo "Enter your username:"
        read USERNAME

        # check db for username
        USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
        if [[ -z $USERNAME_RESULT ]]
        then
            # if username doesn't exist, welcome first time
            INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
            echo "Welcome, $USERNAME! It looks like this is your first time here."
            GAMES_PLAYED=0
            # START_GAME
        else
            # if username exists, display welcome with stats
            GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
            BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")

            # TODO: add sed to remove spaces
            echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
        fi

        # start game
        # generate random number
        SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
        GAME_OVER=false
        NUMBER_OF_GUESSES=0

        echo -e "\nGuess the secret number between 1 and 1000:"
        read CURRENT_GUESS

        # game play loop
        while [[ $GAME_OVER != 'true' ]]
        do
            # if guess is not a number
            if [[ ! $CURRENT_GUESS =~ ^[0-9]+$ ]]
            then
                echo -e "\nThat is not an integer, guess again:"
                read CURRENT_GUESS

            # compare guess to random number
            # if guess equals the secret number
            elif [[ $CURRENT_GUESS == $SECRET_NUMBER ]]
            then
                NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES+1 ))
                # update database
                # if best_game is NULL or NUMBER_OF_GUESSES is better, update best_game
                if [[ $NUMBER_OF_GUESSES < $BEST_GAME || -z $BEST_GAME ]]
                then
                    UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username='$USERNAME'")
                fi
                # increment the games played
                GAMES_PLAYED=$(( GAMES_PLAYED+1 ))
                UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE username='$USERNAME'")

                # display winning message
                echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

                # set GAME_OVER=true
                GAME_OVER=true

            # if the guess is high, display 'lower' message and get new guess
            elif [[ $CURRENT_GUESS > $SECRET_NUMBER ]]
            then
                NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES+1 ))
                echo -e "\nIt's lower than that, guess again:"
                read CURRENT_GUESS
            else
            # only other option, guess was too low. display 'higher' message and get new guess
                NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES+1 ))
                echo -e "\nIt's higher than that, guess again:"
                read CURRENT_GUESS
            fi
        done
    else

        echo "Please check out FreeCodeCamp.org!"

    fi
}

MAIN_MENU
