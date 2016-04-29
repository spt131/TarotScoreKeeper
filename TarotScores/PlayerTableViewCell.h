//
//  PlayerTableViewCell.h
//  CardScores
//
//  Created by Tubiello, Samuel on 2/28/16.
//  Copyright © 2016 Tubiello, Samuel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *playerNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *playerNameTextField;
@property (nonatomic) NSInteger playerNumber;
@property (strong, nonatomic) IBOutlet UILabel *titleTextLabel;

@end
