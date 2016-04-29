//
//  NewRoundTableViewController.h
//  TarotScores
//
//  Created by Sam - BlackRock on 4/3/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
#import "Player.h"
#import "GameRoundPlayer.h"

@interface NewRoundTableViewController : UITableViewController

@property (nonatomic, strong) Game *game;
@property (nonatomic) NSNumber *roundNum;
@property (nonatomic, strong) NSArray <GameRoundPlayer *> *existingRoundArray;

@end
