//
//  NewRoundSummaryHeaderView.m
//  TarotScores
//
//  Created by Sam - BlackRock on 4/9/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import "NewRoundSummaryHeaderView.h"

@implementation NewRoundSummaryHeaderView

+ (NewRoundSummaryHeaderView *)new
{
    NewRoundSummaryHeaderView *view = [[[NSBundle mainBundle] loadNibNamed:@"NewRoundSummaryHeaderView" owner:nil options:nil] firstObject];
    return view;
}

@end
