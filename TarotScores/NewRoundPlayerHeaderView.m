//
//  NewRoundPlayerHeaderView.m
//  TarotScores
//
//  Created by Sam - BlackRock on 4/9/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import "NewRoundPlayerHeaderView.h"

@interface NewRoundPlayerHeaderView ()


@end

@implementation NewRoundPlayerHeaderView

+ (NewRoundPlayerHeaderView *)new
{
    NewRoundPlayerHeaderView *view = [[[NSBundle mainBundle] loadNibNamed:@"NewRoundPlayerHeaderView" owner:nil options:nil] firstObject];
    return view;
}

@end
