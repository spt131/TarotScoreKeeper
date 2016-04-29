//
//  NewRoundTableViewCell.h
//  TarotScores
//
//  Created by Sam - BlackRock on 4/4/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewRoundTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (strong, nonatomic) IBOutlet UISwitch *takeSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *partnerSwitch;

@end
