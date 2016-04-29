//
//  GameDataManager.h
//  TarotScores
//
//  Created by Sam - BlackRock on 4/3/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Game.h"
#import "Player.h"
#import "GameRoundPlayer.h"

#define SAVE_ROUND_NOTIFICATION @"kTarotSavedGame"
//Macro to convert from Hex to UIColor to keep HTMl and iOS consistent
#define UIColorFromHex(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface GameDataManager : NSObject

+ (GameDataManager *)shared;

- (BOOL)storeGameRound:(GameRoundPlayer *)newRound forPlayer:(Player *)player andGame:(Game *)game;
- (BOOL)upateGameRound:(GameRoundPlayer *)newRound forPlayer:(Player *)player andGame:(Game *)game andRoundNum:(NSNumber *)number;

- (BOOL)updateGameRound:(GameRoundPlayer *)oldRound toNewRound:(GameRoundPlayer *)newRound  withOldScore:(NSNumber *)oldScore;

- (BOOL)gameNotStarted:(Game *)game;

@property (nonatomic, strong) NSManagedObjectContext *mainMoc;
@property (nonatomic, strong) NSManagedObjectContext *childMoc;
@property (nonatomic, strong) NSManagedObjectModel *mom;

@end
