//
//  Game+CoreDataProperties.h
//  TarotScores
//
//  Created by Sam - BlackRock on 4/4/16.
//  Copyright © 2016 Sam. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Game.h"

NS_ASSUME_NONNULL_BEGIN

@interface Game (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *numberOfPlayers;
@property (nullable, nonatomic, retain) NSDate *time;
@property (nullable, nonatomic, retain) NSOrderedSet<Player *> *hasPlayers;

@end

@interface Game (CoreDataGeneratedAccessors)

- (void)insertObject:(Player *)value inHasPlayersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromHasPlayersAtIndex:(NSUInteger)idx;
- (void)insertHasPlayers:(NSArray<Player *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeHasPlayersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInHasPlayersAtIndex:(NSUInteger)idx withObject:(Player *)value;
- (void)replaceHasPlayersAtIndexes:(NSIndexSet *)indexes withHasPlayers:(NSArray<Player *> *)values;
- (void)addHasPlayersObject:(Player *)value;
- (void)removeHasPlayersObject:(Player *)value;
- (void)addHasPlayers:(NSOrderedSet<Player *> *)values;
- (void)removeHasPlayers:(NSOrderedSet<Player *> *)values;

@end

NS_ASSUME_NONNULL_END
