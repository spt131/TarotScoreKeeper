//
//  Player+CoreDataProperties.m
//  TarotScores
//
//  Created by Sam - BlackRock on 4/4/16.
//  Copyright © 2016 Sam. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Player+CoreDataProperties.h"

@implementation Player (CoreDataProperties)

@dynamic currentScore;
@dynamic name;
@dynamic currentRound;
@dynamic playsGame;
@dynamic playsRounds;

- (void)addPlaysRoundsObject:(GameRoundPlayer *)value
{
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.playsRounds];
    [tempSet addObject:value];
    self.playsRounds = tempSet;
}
@end
