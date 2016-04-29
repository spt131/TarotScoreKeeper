//
//  ScoreTableViewCell.h
//  TarotScores
//
//  Created by Sam - BlackRock on 4/3/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIStackView *cellStackView;

- (instancetype)init;

@end
