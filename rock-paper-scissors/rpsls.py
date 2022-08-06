import os
import random
from os import system, name

score_tally = {"user": 0, "cpu":0, "tie":0} # Dict of the score
possible_moves = ['rock', 'paper', 'scissors', 'lizard', 'spock']

# winner:[loser,action(like rock crushes scissors)]. The nested dictionary allows for multiple losers
win_logic = {"rock":{"scissors":"(as it always has) crushes", "lizard":"crushes"},
             "paper":{"rock":"covers", "spock":"disproves"},
             "scissors":{"paper":"cuts", "lizard":"decapitates"},
             "lizard":{"spock":"poisons", "paper":"eats"},
             "spock":{"scissors":"smashes", "rock":"vaporizes"} } 

def clear():
    if name == 'nt':
        print("Windows :(")
     #os.system("cls") 
    else:
        print("Not Windows")

games = 0 # doesn't really do anything other than it doesn't clear the screen/show score at the first go

clear()
print("Welcome to Rock Paper Scissors Lizard Spock.")
print('Type "quit" to exit!')

while True: # Runs in a loop until the game is quit by the user
    games += 1
    if games > 1:
        clear()
        print("Your Score: %i | CPU Score: %i | Ties: %i | Type 'quit' to exit"%(score_tally['user'],score_tally['cpu'],score_tally['tie']))

    user_move = input('Enter "rock", "paper", "scissors", "lizard", or "spock": ').lower()
    
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
                print("You won! %s %s %s."%(user_move.capitalize(), win_logic[user_move][cpu_move], cpu_move))
                input("\nPress the Enter key to continue...")
                
            else:
                score_tally['cpu']+=1
                print("CPU won! %s %s %s."%(cpu_move.capitalize(), win_logic[cpu_move][user_move], user_move))
                input("\nPress the Enter key to continue...")
    
clear() # End game
   
if score_tally['user'] > score_tally['cpu']:
    print("You win!")
elif score_tally['user'] < score_tally['cpu']:
    print("CPU wins!")
else:
    print("Nobody wins! It's a tie.")

print("\nYour Score: %i | CPU Score: %i | Ties: %i"%(score_tally['user'],score_tally['cpu'],score_tally['tie']))
print()
print("Goodbye! Thanks for playing.")