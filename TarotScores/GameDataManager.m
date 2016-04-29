//
//  GameDataManager.m
//  TarotScores
//
//  Created by Sam - BlackRock on 4/3/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import "GameDataManager.h"
#import "BLKManagerCoreData.h"
#import <CoreData/CoreData.h>

@interface GameDataManager ()

@end

@implementation GameDataManager

+ (GameDataManager *)shared {
    
    static dispatch_once_t pred;
    static id shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[self alloc] init];
        [shared setup];
    });
    
    return shared;
}

- (void)setup
{
    self.mainMoc = [[BLKManagerCoreData shared] mocForModelNamed:@"Model"];
    self.childMoc = [[BLKManagerCoreData shared] childMocForModelNamed:@"Model"];
    self.mom = [[BLKManagerCoreData shared] momForModelNamed:@"Model"];
}

- (BOOL)storeGameRound:(GameRoundPlayer *)newRound forPlayer:(Player *)player andGame:(Game *)game
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player" inManagedObjectContext:[GameDataManager shared].childMoc];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@ AND playsGame == %@", player.name, player.playsGame];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[GameDataManager shared].childMoc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        DLOG(@"There was an error");
    } else {
        if (fetchedObjects.count > 0){
            Player *player = [fetchedObjects objectAtIndex:0];
            
            player.currentScore = [NSNumber numberWithFloat:([player.currentScore floatValue] + [newRound.score floatValue])];
            
            player.currentRound = [NSNumber numberWithFloat:([player.currentRound floatValue] + 1)];
            newRound.roundNum = player.currentRound;
            newRound.forPlayer = player;
        }
        NSError *error;
        if (![[GameDataManager shared].childMoc save:&error]){
            DLOG(@"Unresolved Error in Fetch");
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:SAVE_ROUND_NOTIFICATION object:nil];
            return YES;
        }
    }
    return NO;
}

- (BOOL)upateGameRound:(GameRoundPlayer *)newRound forPlayer:(Player *)player andGame:(Game *)game andRoundNum:(NSNumber *)number
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GameRoundPlayer" inManagedObjectContext:[GameDataManager shared].childMoc];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"roundNum == %@ AND forPlayer == %@", number, player];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"roundNum"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[GameDataManager shared].childMoc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        DLOG(@"There was an error");
    } else {
        DLOG(@"Rounds %@", fetchedObjects);
    }
    return NO;
}

- (BOOL)updateGameRound:(GameRoundPlayer *)oldRound toNewRound:(GameRoundPlayer *)newRound  withOldScore:(NSNumber *)oldScore
{
    //We update the existing round but we need to update the score of the player also
    int scoreDiff = [oldScore intValue] - [newRound.score intValue];

    oldRound = newRound;
    
    NSError *error;
    if (![[GameDataManager shared].childMoc save:&error]){
        DLOG(@"Unresolved Error in Fetch");
        return NO;
    } else {
        
        if ([self changeScoreForPlayer:oldRound.forPlayer byPoints:[NSNumber numberWithInt:scoreDiff]]){
            [[NSNotificationCenter defaultCenter] postNotificationName:SAVE_ROUND_NOTIFICATION object:nil];
            return YES;
        } else {
            return NO;
        }
    }
    
    return NO;
}

- (BOOL)changeScoreForPlayer:(Player *)player byPoints:(NSNumber *)number
{
    player.currentScore = [NSNumber numberWithInt:[player.currentScore intValue] - [number intValue]];
    
    NSError *error;
    if (![[GameDataManager shared].childMoc save:&error]){
        DLOG(@"Unresolved Error in Fetch");
        return NO;
    } else {
        return YES;
    }
    
    return NO;
}

- (BOOL)gameNotStarted:(Game *)game
{
    return [game.hasPlayers[0].currentRound isEqualToNumber:[NSNumber numberWithInt:0]];
}
@end
