import os
import random

score_tally = {"user": 0, "cpu":0, "tie":0} # Dict of the score
possible_moves = ['rock', 'paper', 'scissors']
win_logic = {"rock":["scissors","crushes"], "paper":["rock","covers"], "scissors":["paper","cut"]} # winner:[loser,action(like rock crushes scissors)]

def clear():
	os.system("clear")

games = 0 # doesn't really do anything other than it doesn't clear the screen/show score at the first go

print("Welcome to Rock Paper Scissors.")
print('Type "quit" to exit!')

while True: # Runs in a loop until the game is quit by the user
    games += 1
    if games > 1:
        clear()
        print("Your Score: %i | CPU Score: %i | Ties: %i"%(score_tally['user'],score_tally['cpu'],score_tally['tie']))

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
print()
print("Goodbye! Thanks for playing.")