//
//  NewRoundChoiceTableViewCell.m
//  TarotScores
//
//  Created by Sam - BlackRock on 4/9/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import "NewRoundChoiceTableViewCell.h"
#import "GameRoundPlayer.h"

@implementation NewRoundChoiceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.smallSwitch.tag = kGameTypeSmall;
    self.largeSwitch.tag = kGameTypeLarge;
    self.largeWithoutSwitch.tag = kGameTypeLargeWithout;
    self.largeAgainstSwitch.tag = kGameTypeLargeAgainst;
}

@end
