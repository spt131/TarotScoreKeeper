//
//  ContractTableViewCell.m
//  TarotScores
//
//  Created by Sam - BlackRock on 4/10/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import "ContractTableViewCell.h"

@implementation ContractTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.segmentedControl setTintColor:[GLBUtil shared].headerColor];
    

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (IS_IPHONE_5 && [[UIDevice currentDevice] orientation] == UIUserInterfaceSizeClassCompact){
        [self.segmentedControl setTitle:@"G. Sans" forSegmentAtIndex:2];
        [self.segmentedControl setTitle:@"G. Contre" forSegmentAtIndex:3];
    } else {
        [self.segmentedControl setTitle:@"Garde Sans" forSegmentAtIndex:2];
        [self.segmentedControl setTitle:@"Garde Contre" forSegmentAtIndex:3];
    }
    
}

@end
