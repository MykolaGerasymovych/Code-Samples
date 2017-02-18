# Mini-project #6 - Blackjack

import simplegui
import random

# load card sprite - 936x384 - source: jfitz.com
CARD_SIZE = (72, 96)
CARD_CENTER = (36, 48)
card_images = simplegui.load_image("http://storage.googleapis.com/codeskulptor-assets/cards_jfitz.png")

CARD_BACK_SIZE = (72, 96)
CARD_BACK_CENTER = (36, 48)
card_back = simplegui.load_image("http://storage.googleapis.com/codeskulptor-assets/card_jfitz_back.png")    

# initialize some useful global variables
in_play = False
outcome = ""
action = ""
score = 0

# define globals for cards
SUITS = ('C', 'S', 'H', 'D')
RANKS = ('A', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K')
VALUES = {'A':1, '2':2, '3':3, '4':4, '5':5, '6':6, '7':7, '8':8, '9':9, 'T':10, 'J':10, 'Q':10, 'K':10}


# define card class
class Card:
    def __init__(self, suit, rank):
        if (suit in SUITS) and (rank in RANKS):
            self.suit = suit
            self.rank = rank
        else:
            self.suit = None
            self.rank = None
            print "Invalid card: ", suit, rank

    def __str__(self):
        return self.suit + self.rank

    def get_suit(self):
        return self.suit

    def get_rank(self):
        return self.rank

    def draw(self, canvas, pos):
        card_loc = (CARD_CENTER[0] + CARD_SIZE[0] * RANKS.index(self.rank), 
                    CARD_CENTER[1] + CARD_SIZE[1] * SUITS.index(self.suit))
        canvas.draw_image(card_images, card_loc, CARD_SIZE, [pos[0] + CARD_CENTER[0], pos[1] + CARD_CENTER[1]], CARD_SIZE)
        
# define hand class
class Hand:
    def __init__(self):
        self.hand = []

    def __str__(self):
        hand_content = ""
        for i in range(len(self.hand)):
            hand_content += " " + str(self.hand[i])    
        return "hand contains" + str(hand_content)
        
    def add_card(self, card):
        self.hand.append(card)

    def get_value(self):
        # count aces as 1, if the hand has an ace, then add 10 to hand value if it doesn't bust
        # compute the value of the hand
        self.hand_value = 0
        for card in self.hand:
            self.hand_value += VALUES[card.rank]
        for card in self.hand:    
            if card.rank == 'A':
                if self.hand_value <= 11:
                    self.hand_value += 10                
        return self.hand_value
   
    def draw(self, canvas, pos):
        for card in self.hand:
            card.draw(canvas, [pos[0] + self.hand.index(card) * (CARD_SIZE[0] + 30), pos[1] + CARD_SIZE[1]])
    
# define deck class 
class Deck:
    def __init__(self):
        self.deck = []
        for s in SUITS:
            for r in RANKS:
                self.deck.append(Card(s, r))

    def shuffle(self):
        # shuffle the deck 
        return random.shuffle(self.deck)

    def deal_card(self):
        # deal a card object from the deck
        dealed = self.deck[-1]
        self.deck.pop()
        return dealed
    
    def __str__(self):
        # return a string representing the deck
        deck_content = ""
        for i in range(len(self.deck)):
            deck_content += " " + str(self.deck[i])
        return "Deck contains" + deck_content


#define event handlers for buttons
def deal():
    global action, outcome, in_play, player_hand, dealer_hand, deck, score
    
    # your code goes here
    deck = Deck()
    deck.shuffle()
    player_hand = Hand()
    dealer_hand = Hand()
    
    player_hand.add_card(deck.deal_card())
    dealer_hand.add_card(deck.deal_card())
    player_hand.add_card(deck.deal_card())
    dealer_hand.add_card(deck.deal_card())
    
    if in_play == True:
        outcome = "You lost the round."
        score -= 1
        action = "Hit or stand?"
    else:
        in_play = True
        action = "Hit or stand?"
        outcome = ""
    
    return action, outcome, player_hand, dealer_hand, in_play, deck, score

def hit():
    global action, outcome, in_play, score, player_hand, deck
    # if the hand is in play, hit the player
    if in_play == True:
        outcome = ""
        player_hand.add_card(deck.deal_card())    
   
    # if busted, assign a message to outcome, update in_play and score
        if player_hand.get_value() > 21:
            outcome = "You went bust and lose."
            action = "New Deal?"
            in_play = False
            score -= 1
        else:
            action = "Hit or stand?"
    return action, outcome, in_play, score, player_hand, deck

def stand():
    global action, outcome, in_play, score, player_hand, dealer_hand, deck
   
    # if hand is in play, repeatedly hit dealer until his hand has value 17 or more
    if in_play == True:
        while dealer_hand.get_value() <= 17:
            dealer_hand.add_card(deck.deal_card())
    # assign a message to outcome, update in_play and score
        if dealer_hand.get_value() > 21:
            outcome = "You win!"
            action = "New deal?"
            in_play = False
            score += 1
        else:
            if dealer_hand.get_value() < player_hand.get_value():
                outcome = "You win!" 
                action = "New deal?"
                in_play = False
                score += 1
            else:
                outcome = "You lose."
                action = "New Deal?"
                in_play = False
                score -= 1
    return action, outcome, in_play, score, player_hand, dealer_hand, deck

# draw handler    
def draw(canvas):
    # test to make sure that card.draw works, replace with your code below
    player_hand.draw(canvas, [65, 300])
    dealer_hand.draw(canvas, [65, 100])
    if in_play == True:
        card_back_loc = (CARD_BACK_CENTER[0], CARD_BACK_CENTER[1])
        canvas.draw_image(card_back, card_back_loc, CARD_BACK_SIZE, [101, 244], CARD_BACK_SIZE)
    canvas.draw_text(outcome, [240, 185], 30, "White")
    canvas.draw_text(action, [240, 380], 30, "White")
    canvas.draw_text("Dealer", [70, 185], 30, "White")
    canvas.draw_text("Player", [70, 380], 30, "White")
    canvas.draw_text("Blackjack", [120, 90], 40, "Aqua")
    canvas.draw_text("Score: " + str(score), [400, 90], 30, "White")


# initialization frame
frame = simplegui.create_frame("Blackjack", 600, 600)
frame.set_canvas_background("Green")

#create buttons and canvas callback
frame.add_button("Deal", deal, 200)
frame.add_button("Hit",  hit, 200)
frame.add_button("Stand", stand, 200)
frame.set_draw_handler(draw)


# get things rolling
deal()
frame.start()


# remember to review the gradic rubric