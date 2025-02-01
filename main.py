# import packages
from art import logo, vs
from game_data import data
from random import randint

# TODO 1: to pick the random personnel to compare.
# TODO 2: check who has more followers.
# TODO 3: need to random generate again if the name in B is the same as A


def rng():
    """
    This function generate the random person by generating random number and return object in a list
    """
    num = randint(0, len(data)-1)
    party = data[num]['follower_count']
    string = f"Party B: {data[num]['name']},a {data[num]['description']}, from {data[num]['country']}"
    name = data[num]['name']
    return [party, string, name]


def check(ticker, party1, party2):
    """
    This is to check whether user guess A or B has more follower.
    """
    if ticker == 'A':
        return party1 > party2
    elif ticker == "B":
        return party1 < party2


def regen(name1, name2):
    """
    This will prevent B from generate the same party as A
    """
    while not name1[2] != name2[2]:
        name2 = rng()
    return name2


player1 = rng()
score = 0

while True:
    print("Party A" + player1[1][7:])
    print(vs)
    player2 = rng()
    player2 = regen(player1, player2)
    print(player2[1])

    checker = input("Who has more followers? Type 'A' or 'B': ").upper()

    output = check(checker, player1[0], player2[0])

    if output:
        score += 1
        player1 = player2
        print(f"Your current score is {score}")
    else:
        print(logo)
        print(f"Sorry, that's wrong. Final score: {score}")
        break
