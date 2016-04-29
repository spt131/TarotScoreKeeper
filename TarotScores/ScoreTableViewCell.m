//
//  ScoreTableViewCell.m
//  TarotScores
//
//  Created by Sam - BlackRock on 4/3/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import "ScoreTableViewCell.h"

@implementation ScoreTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)init
{
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"ScoreTableViewCell" owner:self options:nil];
    ScoreTableViewCell *cell = [nibObjects objectAtIndex:0];
    self = cell;
    cell = nil;
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    UIView * selectedBackgroundView = [[UIView alloc] init];
    [selectedBackgroundView setBackgroundColor:[UIColor clearColor]];
    [self setSelectedBackgroundView:selectedBackgroundView];

}

- (void)prepareForReuse {
    [super prepareForReuse];

    for (UIView *view in self.cellStackView.arrangedSubviews) {
        [self.cellStackView removeArrangedSubview:view];
        [view removeFromSuperview];
    }
}

@end
