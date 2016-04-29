//
//  NewRoundSegmentTableViewCell.h
//  TarotScores
//
//  Created by Sam - BlackRock on 4/10/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewRoundSegmentTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@end
