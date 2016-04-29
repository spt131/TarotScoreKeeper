//
//  GameRoundPlayer+CoreDataProperties.h
//  TarotScores
//
//  Created by Sam - BlackRock on 4/10/16.
//  Copyright © 2016 Sam. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GameRoundPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface GameRoundPlayer (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *contractPlayer;
@property (nullable, nonatomic, retain) NSNumber *roundNum;
@property (nullable, nonatomic, retain) NSNumber *score;
@property (nullable, nonatomic, retain) NSNumber *win;
@property (nullable, nonatomic, retain) NSNumber *defensePlayer;
@property (nonatomic) TarotGameType contractType;
@property (nullable, nonatomic, retain) NSNumber *pointsFor;
@property (nullable, nonatomic, retain) NSNumber *pointsNeeded;
@property (nullable, nonatomic, retain) NSNumber *partnerPlayer;
@property (nullable, nonatomic, retain) Player *forPlayer;

@end

NS_ASSUME_NONNULL_END
