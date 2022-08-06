from os import system, name
import os 
import random

game_type = ''
games_played = 0
users_name = os.environ.get('USER', os.environ.get('USERNAME'))
"""
Score works like this:
x: "game type", "score": {"user": <int>, "cpu":<int>, "tie":<int>} # Dict of the score
"""
final_score = []

def print_tally():
    global final_score
    print("Final_score")
    clear()
    if not final_score: # Don't show it if it's empty
        print("There is no scoreboard yet. Go play a game first, then come back!")
    else:
        print("Here is the scoreboard.")
        print(final_score)
        # OUTPUT LOOKS LIKE THIS
        # [{1: 'RPS', 'score': {'user': 1, 'cpu': 1, 'tie': 1}},
        # {2: 'RPS', 'score': {'user': 2, 'cpu': 4, 'tie': 8}}]
        print("Your Score: %i | CPU Score: %i | Ties: %i | Type 'quit' to exit"%(score_tally['user'],score_tally['cpu'],score_tally['tie']))
        print("Games Played: %s"%final_score.len())
        


    input("\nPress the Enter key to continue...")


def add_tally(scoreboard): # This adds the final games core to the overall scoreboard of games
    global games_played
    global final_score
    global game_type
    
    final_score.append({games_played:game_type,"score":scoreboard});
    


def clear():
    if name == 'nt':
        os.system("cls") 
    else:
        os.system("clear")

def rps(): # Plays Rock Paper Scissors
    global games_played
    global game_type
    games_played += 1 # advances global games played
    game_type = "RPS"

    score_tally = {"user": 0, "cpu":0, "tie":0} # Dict of the score
    possible_moves = ['rock', 'paper', 'scissors']
    win_logic = {"rock":["scissors","crushes"], "paper":["rock","covers"], "scissors":["paper","cut"]} # winner:[loser,action(like rock crushes scissors)]

    games = 0 # doesn't really do anything other than it doesn't clear the screen/show score at the first go

    clear()
    print("Welcome to Rock Paper Scissors. This is overall game %s"%games_played)
    print('Type "quit" to exit!')

    while True: # Runs in a loop until the game is quit by the user
        games += 1
        if games > 1:
            clear()
            print("This is game #%s"%games_played)
            print("Your Score: %i | CPU Score: %i | Ties: %i | Type 'quit' to exit"%(score_tally['user'],score_tally['cpu'],score_tally['tie']))

        user_move = input('Enter "rock", "paper", or "scissors": ').lower()
        
        cpu_move = random.choice(possible_moves) # Chooses a random move from the list
        
        if user_move not in possible_moves:
            if user_move == "quit" or user_move == "exit":
                break
            else: 
                print("Invalid input. Please retry")
                input("\nPress the Enter key to continue...")
                
        else:
            print("\nYour Move: %s | CPU Move: %s" %(user_move.capitalize(), cpu_move.capitalize()))
            # Compares the CPU vs User choices
            if user_move == cpu_move:
                print("It's a tie!")
                score_tally['tie']+=1
                input("\nPress the Enter key to continue...")

            else:
                
                if cpu_move in win_logic[user_move]:
                    score_tally['user']+=1
                    print("You won! %s %s %s."%(user_move.capitalize(), win_logic[user_move][1], cpu_move))
                    input("\nPress the Enter key to continue...")
                    
                else:
                    score_tally['cpu']+=1
                    print("CPU won! %s %s %s."%(cpu_move.capitalize(), win_logic[cpu_move][1], user_move))
                    input("\nPress the Enter key to continue...")
            
    clear()
    
    if score_tally['user'] > score_tally['cpu']:
        print("You win!")
    elif score_tally['user'] < score_tally['cpu']:
        print("CPU wins!")
    else:
        print("Nobody wins! It's a tie.")

    print("\nYour Score: %i | CPU Score: %i | Ties: %i"%(score_tally['user'],score_tally['cpu'],score_tally['tie']))

    add_tally(score_tally) # adds it to the global scoreboard
        

    
def rpsls():
    game = "rpsls"
    print("RPSLS called")
    print(game)
    



while True:
    clear()

    print("Welcome, %s!\n"%users_name)
    print("These are the choices.")
    print("1 - Play 'Rock, Paper, Scissors'")
    print("2 - Play 'Rock, Paper, Scissors, Lizard, Spock'")
    print("3 - View the scoreboard")
    print("4 - Quit")

    choice = input("\nEnter your choice: ")
    if choice == "1":
        rps()
        
    elif choice == "2":
        rpsls()
    elif choice == "3":
        print_tally()
    elif choice == "quit" or choice == "exit" or choice == "4":
        break
    else:
        print("Invalid input. Please retry")
        input("\nPress the Enter key to continue...")

clear()