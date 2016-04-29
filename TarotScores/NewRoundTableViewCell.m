//
//  NewRoundTableViewCell.m
//  TarotScores
//
//  Created by Sam - BlackRock on 4/4/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import "NewRoundTableViewCell.h"

@implementation NewRoundTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//        //List the players and decide the offense / defense
//        NewRoundTableViewCell *cell = (NewRoundTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"newRound"];
//        Player *playerObj = [self.game.hasPlayers objectAtIndex:indexPath.row];
//        cell.playerNameLabel.text = playerObj.name;
//
//        cell.tag = indexPath.row;
//
//        cell.takeSwitch.on = [self.offense containsObject:playerObj];
//        [cell.takeSwitch addTarget:self action:@selector(offenseSwitchSelected:) forControlEvents:UIControlEventTouchUpInside];
//
//        cell.partnerSwitch.on = [self.defense containsObject:playerObj];
//        [cell.partnerSwitch addTarget:self action:@selector(defenseSwitchSelected:) forControlEvents:UIControlEventTouchUpInside];
//
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        return cell;

@end
