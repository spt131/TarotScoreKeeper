//
//  NewRoundPlayerHeaderView.h
//  TarotScores
//
//  Created by Sam - BlackRock on 4/9/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewRoundPlayerHeaderView : UIView

+ (NewRoundPlayerHeaderView *)new;

@property (strong, nonatomic) IBOutlet UILabel *mainLabel;
@property (strong, nonatomic) IBOutlet UILabel *offenseLabel;
@property (strong, nonatomic) IBOutlet UILabel *defenseLabel;

@end
