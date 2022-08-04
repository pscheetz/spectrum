import os
import time
import random

score_tally = {"user": 0, "cpu":0, "tie":0} # Dict of the score
possible_moves = ['rock', 'paper', 'scissors']

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

    user_move = input('Enter "rock", "paper", or "scissors": ')
    
    cpu_move = random.choice(possible_moves) # Chooses a random move from the list
    
    if user_move not in possible_moves:
        if user_move == "quit" or user_move == "exit":
            break
        else: 
            print("Invalid input. Please retry")
    else:
        print("\nYour Move: %s | CPU Move: %s" %(user_move, cpu_move))
    # Compares the CPU vs User choices
    if user_move == cpu_move:
        print("It's a tie!")
        score_tally['tie']+=1
        time.sleep(2)

    else:
        if user_move == "rock" and cpu_move == "scissors": # User wins
            print("You win - rock crushes scissors")
            score_tally['user']+=1
        if user_move == "rock" and cpu_move == "paper": # CPU wins
            print("CPU wins - paper covers rock")
            score_tally['cpu']+=1              

        if user_move == "paper" and cpu_move == "rock": # User wins
            print("You win - paper covers rock")
            score_tally['user']+=1
        if user_move == "paper" and cpu_move == "scissors": # CPU wins
            print("CPU wins - scissors cut paper")
            score_tally['cpu']+=1    
            
        if user_move == "scissors" and cpu_move == "paper": # User wins
            print("You win - scissors cut paper")
            score_tally['user']+=1
        if user_move == "scissors" and cpu_move == "rock": # CPU wins
            print("CPU wins - rock crushes scissors")
            score_tally['cpu']+=1          
            
        time.sleep(2)
    
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