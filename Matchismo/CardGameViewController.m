//
//  CardGameViewController.m
//  Matchismo
//
//  Created by Dean Williams on 16/01/2014.
//  Copyright (c) 2014 Dean Williams. All rights reserved.
//

#import "CardGameViewController.h"
#import "Deck.h"
#import "PlayingCardDeck.h"
#import "Card.h"
#import "CardMatchingGame.h"

@interface CardGameViewController ()
@property (nonatomic, strong) CardMatchingGame *game;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *flipDescription;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSelector;
@property (strong, nonatomic) NSMutableArray *flipHistory;
@property (weak, nonatomic) IBOutlet UISlider *historySlider;
@end

@implementation CardGameViewController

- (NSMutableArray *)flipHistory
{
    if (!_flipHistory) {
        _flipHistory = [NSMutableArray array];
    }
    return _flipHistory;
}

- (CardMatchingGame *)game
{
    if (!_game) {
        _game = [[CardMatchingGame alloc] initWithCardCount:[self.cardButtons count]
                                                  usingDeck:[self createDeck]];
        [self touchGameTypeButton:self.modeSelector];
    }
    return _game;
}

- (Deck *)createDeck
{
    return [[PlayingCardDeck alloc] init];
}

- (IBAction)changeSlider:(UISlider *)sender {
    long sliderValue;
    sliderValue = lroundf(self.historySlider.value);
    [self.historySlider setValue:sliderValue animated:NO];
    if ([self.flipHistory count]) {
        self.flipDescription.alpha =
        (sliderValue + 1 < [self.flipHistory count]) ? 0.6 : 1.0;
        self.flipDescription.text =
        [self.flipHistory objectAtIndex:sliderValue];
    }
}

- (IBAction)touchDealButton {
    self.game = nil;
    self.modeSelector.enabled = YES;
    self.flipHistory = nil;
    [self updateUI];
}

- (IBAction)touchCardButton:(UIButton *)sender
{
    if (self.modeSelector.enabled == YES) {
        self.modeSelector.enabled = NO;
    }
    NSUInteger cardIndex = [self.cardButtons indexOfObject:sender];
    [self.game chooseCardAtIndex:cardIndex];
    [self updateUI];
}

- (IBAction)touchGameTypeButton:(UISegmentedControl *)sender {
    self.game.maxMatchingCards =
    [[sender titleForSegmentAtIndex:sender.selectedSegmentIndex] integerValue];
}

- (void)updateUI
{
    for (UIButton *cardButton in self.cardButtons) {
        NSUInteger cardIndex = [self.cardButtons indexOfObject:cardButton];
        Card *card = [self.game cardAtIndex:cardIndex];
        [cardButton setTitle:[self titleForCard:card]
                    forState:UIControlStateNormal];
        [cardButton setBackgroundImage:[self backgroundImageForCard:card]
                              forState:UIControlStateNormal];
        cardButton.enabled = !card.matched;
    }
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %ld", (long)self.game.score];
    
    if (self.game) {
        NSString *description = @"";
        
        if ([self.game.lastChosenCards count]) {
            NSMutableArray *cardContents = [NSMutableArray array];
            for (Card *card in self.game.lastChosenCards) {
                [cardContents addObject:card.contents];
            }
            description = [cardContents componentsJoinedByString:@" "];
        }
        
        if (self.game.lastScore > 0) {
            description = [NSString stringWithFormat:@"Matched %@ for %ld points.", description, (long)self.game.lastScore];
        } else if (self.game.lastScore < 0) {
            
            description = [NSString stringWithFormat:@"%@ don’t match! %ld point penalty!", description, -(long)self.game.lastScore];
        }
        
        self.flipDescription.text = description;
        self.flipDescription.alpha = 1;
        
        if (![description isEqualToString:@""]
            && ![[self.flipHistory lastObject] isEqualToString:description]) {
            [self.flipHistory addObject:description];
            [self setSliderRange];
        }
    }
}

- (void)setSliderRange
{
    NSUInteger maxValue = [self.flipHistory count] - 1;
    self.historySlider.maximumValue = maxValue;
    [self.historySlider setValue:maxValue animated:YES];
}

- (NSString *)titleForCard:(Card *)card
{
    return card.isChosen ? card.contents : @"";
}

- (UIImage *)backgroundImageForCard:(Card *) card
{
    return [UIImage imageNamed:card.isChosen ? @"cardfront" : @"cardback"];
}

@end
