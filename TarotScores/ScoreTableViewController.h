//
//  ScoreTableViewController.h
//  TarotScores
//
//  Created by Sam - BlackRock on 4/3/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
#import "Player.h"
#import "GameRoundPlayer.h"

@interface ScoreTableViewController : UITableViewController

@property (nonatomic, strong) Game *game;

@end
