//
//  GameRoundPlayer.h
//  TarotScores
//
//  Created by Sam - BlackRock on 4/3/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum TarotGameType_e : int16_t {
    kGameTypeSmall = 0,
    kGameTypeLarge = 1,
    kGameTypeLargeWithout = 2,
    kGameTypeLargeAgainst = 3
} TarotGameType;

@class Game, Player;

NS_ASSUME_NONNULL_BEGIN

@interface GameRoundPlayer : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "GameRoundPlayer+CoreDataProperties.h"

