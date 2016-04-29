//
//  NewRoundSegmentTableViewCell.m
//  TarotScores
//
//  Created by Sam - BlackRock on 4/10/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import "NewRoundSegmentTableViewCell.h"

@implementation NewRoundSegmentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.segmentedControl setTintColor:[GLBUtil shared].headerColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
