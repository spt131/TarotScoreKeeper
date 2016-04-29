//
//  NewRoundChoiceTableViewCell.h
//  TarotScores
//
//  Created by Sam - BlackRock on 4/9/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewRoundChoiceTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UISwitch *smallSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *largeSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *largeWithoutSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *largeAgainstSwitch;

@end
