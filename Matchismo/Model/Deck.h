//
//  Deck.h
//  Matchismo
//
//  Created by Dean Williams on 16/01/2014.
//  Copyright (c) 2014 Dean Williams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@interface Deck : NSObject

- (void)addCard:(Card *)card atTop:(BOOL)atTop;
- (void)addCard:(Card *)card;

- (Card *)drawRandomCard;

@end
