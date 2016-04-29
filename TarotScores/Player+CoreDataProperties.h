//
//  Player+CoreDataProperties.h
//  TarotScores
//
//  Created by Sam - BlackRock on 4/4/16.
//  Copyright © 2016 Sam. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Player.h"

NS_ASSUME_NONNULL_BEGIN

@interface Player (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *currentScore;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *currentRound;
@property (nullable, nonatomic, retain) Game *playsGame;
@property (nullable, nonatomic, retain) NSOrderedSet<GameRoundPlayer *> *playsRounds;

@end

@interface Player (CoreDataGeneratedAccessors)

- (void)insertObject:(GameRoundPlayer *)value inPlaysRoundsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPlaysRoundsAtIndex:(NSUInteger)idx;
- (void)insertPlaysRounds:(NSArray<GameRoundPlayer *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePlaysRoundsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPlaysRoundsAtIndex:(NSUInteger)idx withObject:(GameRoundPlayer *)value;
- (void)replacePlaysRoundsAtIndexes:(NSIndexSet *)indexes withPlaysRounds:(NSArray<GameRoundPlayer *> *)values;
- (void)addPlaysRoundsObject:(GameRoundPlayer *)value;
- (void)removePlaysRoundsObject:(GameRoundPlayer *)value;
- (void)addPlaysRounds:(NSOrderedSet<GameRoundPlayer *> *)values;
- (void)removePlaysRounds:(NSOrderedSet<GameRoundPlayer *> *)values;

@end

NS_ASSUME_NONNULL_END
