//
//  NewRoundSummaryHeaderView.h
//  TarotScores
//
//  Created by Sam - BlackRock on 4/9/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewRoundSummaryHeaderView : UIView

+ (NewRoundSummaryHeaderView *)new;

@property (strong, nonatomic) IBOutlet UILabel *mainPlayerLabel;
@property (strong, nonatomic) IBOutlet UILabel *partnerPlayerLabel;

@end
