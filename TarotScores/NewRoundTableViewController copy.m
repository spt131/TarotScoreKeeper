//
//  NewRoundTableViewController.m
//  TarotScores
//
//  Created by Sam - BlackRock on 4/3/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import "NewRoundTableViewController.h"
#import "NewRoundTableViewCell.h"
#import "NewRoundPlayerHeaderView.h"
#import "NewRoundSummaryHeaderView.h"
#import "NewRoundChoiceTableViewCell.h"
#import "BLKManagerCoreData.h"
#import "GameDataManager.h"
#import "GameRoundPlayer.h"
#import "NewRoundSegmentTableViewCell.h"

#import "PlayerTableViewCell.h"
#import "SegmentedTableViewCell.h"

@interface NewRoundTableViewController () <UITextFieldDelegate>

@property (nonatomic, strong) NSString *selectedPlayer;

@property (nonatomic, strong) NSMutableArray <Player *> *offense;
@property (nonatomic, strong) NSMutableArray <Player *> *defense;

@property (nonatomic, strong) NSNumber *totalPoints;
@property (nonatomic, strong) NSNumber *requiredPoints;

@property (nonatomic, weak) UITextField *totalPointsTextField;

@property (nonatomic, assign) TarotGameType gameType;

@end

enum {
    kTotalPointsTextField
};

@implementation NewRoundTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"NewRoundTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"newRound"];
    [self.tableView registerNib:[UINib nibWithNibName:@"NewRoundChoiceTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"choiceCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PlayerTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"newPlayerCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SegmentedTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"segmentedCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"NewRoundSegmentTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"newRoundSegmentCell"];
    
    self.offense = [[NSMutableArray alloc] init];
    self.defense = [[NSMutableArray alloc] init];
    
    self.gameType = -1;
    
    if (self.existingRoundArray.count > 0){
        for (GameRoundPlayer *round in self.existingRoundArray) {
            if ([round.offense boolValue]){
                [self.offense addObject:round.forPlayer];
                
                if (round.contract){
                    self.totalPoints = round.pointsFor;
                    self.requiredPoints = round.pointsNeeded;
                    self.gameType = round.contract;
                }
            } else {
                [self.defense addObject:round.forPlayer];
            }
            self.title = [NSString stringWithFormat:@"Round %@", round.roundNum];
        }
    }
    
    if (!self.requiredPoints){
        self.requiredPoints = [NSNumber numberWithInt:36];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0){
        return self.game.hasPlayers.count;
    } else if (section == 1){
        return 1;
    } else if (section == 2){
        return 2;
    }
    return 0;
}

- (IBAction)dismiss:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)save:(UIBarButtonItem *)sender {
    //Let's validate before we dismiss
    NSString *errorMessage;
    
    //Force resign first responders
    if (self.totalPointsTextField.isFirstResponder){
        [self.totalPointsTextField resignFirstResponder];
    }
    
    //Total Score
    int scoreMultipler = 0;
    switch (self.gameType) {
        case kGameTypeSmall:
            scoreMultipler = 1;
            break;
        case kGameTypeLarge:
            scoreMultipler = 2;
            break;
        case kGameTypeLargeAgainst:
            scoreMultipler = 3;
            break;
        case kGameTypeLargeWithout:
            scoreMultipler = 4;
            break;
            
        default:
            errorMessage = @"Error determining game type";
            break;
    }
    
    BOOL win = self.totalPoints > self.requiredPoints;
    int defaultScore = abs([self.totalPoints intValue] - [self.requiredPoints intValue]) + 25;
    int count = 0;
    for (Player *playerObj in self.game.hasPlayers) {
        GameRoundPlayer *roundDetails;
        
        if (self.roundNum){
            roundDetails = self.existingRoundArray[count];
            
        } else {
            roundDetails = [NSEntityDescription insertNewObjectForEntityForName:@"GameRoundPlayer" inManagedObjectContext:[GameDataManager shared].childMoc];
        }
        
        roundDetails.defense = [NSNumber numberWithBool:[self.defense containsObject:playerObj]];
        roundDetails.offense = [NSNumber numberWithBool:[self.offense containsObject:playerObj]];
        roundDetails.win = [NSNumber numberWithBool:win];
        
        if ([roundDetails.offense boolValue] == YES){
            int winMultipler = (win == YES) ? 1 : -1;
            if (playerObj == self.offense.firstObject){
                //Taker
                roundDetails.score = [NSNumber numberWithInt:(defaultScore * winMultipler * scoreMultipler * 2)];
                roundDetails.contract = self.gameType;
                roundDetails.pointsFor = self.totalPoints;
                roundDetails.pointsNeeded = self.requiredPoints;
            } else {
                //Partner
                roundDetails.score = [NSNumber numberWithInt:(defaultScore * winMultipler * scoreMultipler)];
            }
        } else {
            int winMultipler = (win == YES) ? -1 : 1;
            roundDetails.score = [NSNumber numberWithInt:(defaultScore * winMultipler * scoreMultipler)];
        }
        
        BOOL save;
        if (self.roundNum){
            save = [[GameDataManager shared] updateGameRound:self.existingRoundArray[count] toNewRound:roundDetails];
        } else {
            save = [[GameDataManager shared] storeGameRound:roundDetails forPlayer:playerObj andGame:self.game];
        }
        
        count++;
        
        if (save)
            continue;
        else
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Players
    if (indexPath.section == 0){
        NewRoundSegmentTableViewCell *cell = (NewRoundSegmentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"newRoundSegmentCell"];
        Player *playerObj = [self.game.hasPlayers objectAtIndex:indexPath.row];
        cell.playerNameLabel.text = playerObj.name;
        return cell;
    } else if (indexPath.section == 1){
        //Decide the type of round the taker selected
        NewRoundChoiceTableViewCell *cell = (NewRoundChoiceTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"choiceCell"];
        
        [cell.smallSwitch addTarget:self action:@selector(choiceSelected:) forControlEvents:UIControlEventTouchUpInside];
        [cell.largeSwitch addTarget:self action:@selector(choiceSelected:) forControlEvents:UIControlEventTouchUpInside];
        [cell.largeWithoutSwitch addTarget:self action:@selector(choiceSelected:) forControlEvents:UIControlEventTouchUpInside];
        [cell.largeAgainstSwitch addTarget:self action:@selector(choiceSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.smallSwitch.on = (self.gameType == (TarotGameType)cell.smallSwitch.tag);
        cell.largeSwitch.on = (self.gameType == (TarotGameType)cell.largeSwitch.tag);
        cell.largeWithoutSwitch.on = (self.gameType == (TarotGameType)cell.largeWithoutSwitch.tag);
        cell.largeAgainstSwitch.on = (self.gameType == (TarotGameType)cell.largeAgainstSwitch.tag);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (indexPath.section == 2){
        //Need to get some info for scoring
        // - How many special cards did you have 0, 1, 2, 3
        // - Number of total points acquired
        // - petit au bout held to the end
        if (indexPath.row == 0){
            PlayerTableViewCell *cell = (PlayerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"newPlayerCell"];
            cell.playerNumberLabel.text = @"";
            cell.titleTextLabel.text = @"Points scored";
            cell.playerNameTextField.placeholder = @"Total";
            cell.playerNameTextField.keyboardType = UIKeyboardTypeDecimalPad;
            cell.playerNameTextField.tag = kTotalPointsTextField;
            cell.playerNameTextField.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.totalPointsTextField = cell.playerNameTextField;
            if (self.totalPoints){
                cell.playerNameTextField.text = [NSString stringWithFormat:@"%@", self.totalPoints];
            }
            return cell;
        } else {
            SegmentedTableViewCell *cell = (SegmentedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"segmentedCell"];
            [cell.segmentedControl addTarget:self
                                 action:@selector(pointsNeededSegmentedControlChanged:)
                            forControlEvents:UIControlEventValueChanged];
            
            if ([self.requiredPoints isEqualToNumber:[NSNumber numberWithInt:36]]){
                [cell.segmentedControl setSelectedSegmentIndex:0];
            } else if ([self.requiredPoints isEqualToNumber:[NSNumber numberWithInt:41]]){
                [cell.segmentedControl setSelectedSegmentIndex:1];
            } else if ([self.requiredPoints isEqualToNumber:[NSNumber numberWithInt:51]]){
                [cell.segmentedControl setSelectedSegmentIndex:2];
            } else if ([self.requiredPoints isEqualToNumber:[NSNumber numberWithInt:56]]){
                [cell.segmentedControl setSelectedSegmentIndex:3];
            }
            
            return cell;
        }

    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    return cell;
  
}

- (void)choiceSelected:(UISwitch *)sender
{
    self.gameType = (TarotGameType)sender.tag;
    [self reloadTableForOffenseDefenseSelection];
}

- (void)offenseSwitchSelected:(UISwitch *)sender
{
    NewRoundTableViewCell *cell = (NewRoundTableViewCell *) sender.superview.superview;
    Player *playerObj = [self.game.hasPlayers objectAtIndex:cell.tag];
    
    if (sender.on){
        if (self.offense.count == [self numberOfOffenseAllowed]){
            [self.offense removeLastObject];
        }
        [self.offense addObject:playerObj];
        if ([self.defense containsObject:playerObj]){
            [self.defense removeObject:playerObj];
        }
    } else {
        if ([self.offense containsObject:playerObj]){
            [self.offense removeObject:playerObj];
        }
    }
    [self reloadTableForOffenseDefenseSelection];
}

- (void)defenseSwitchSelected:(UISwitch *)sender
{
    NewRoundTableViewCell *cell = (NewRoundTableViewCell *) sender.superview.superview;
    Player *playerObj = [self.game.hasPlayers objectAtIndex:cell.tag];
    
    if (sender.on){
        //Can't ever have more than 3 maximum
        if (self.defense.count == 3){
            [self.defense removeLastObject];
        }
        [self.defense addObject:playerObj];
        if ([self.offense containsObject:playerObj]){
            [self.offense removeObject:playerObj];
        }
        
    } else {
        if ([self.defense containsObject:playerObj]){
            [self.defense removeObject:playerObj];
        }
    }
    [self reloadTableForOffenseDefenseSelection];
}

- (void)reloadTable
{
    [self.tableView reloadData];
}

- (void)reloadTableForOffenseDefenseSelection
{
    [self performSelector:@selector(reloadTable) withObject:nil afterDelay:0.1];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        NewRoundPlayerHeaderView *header = [NewRoundPlayerHeaderView new];
        return header;
    } else if (section == 1){
        NewRoundSummaryHeaderView *header = [NewRoundSummaryHeaderView new];
        if (self.offense.count > 0){
            header.mainPlayerLabel.text = [self.offense objectAtIndex:0].name;
            if (self.offense.count > 1){
                header.partnerPlayerLabel.text = [self.offense objectAtIndex:1].name;
            } else {
                header.partnerPlayerLabel.text = @"None";
            }
        } else {
            header.mainPlayerLabel.text = @"None";
            header.partnerPlayerLabel.text = @"None";
        }
        return header;
    } else if (section == 2){
        NewRoundPlayerHeaderView *header = [NewRoundPlayerHeaderView new];
        header.mainLabel.text = @"Scoring";
        header.offenseLabel.text = @"";
        header.defenseLabel.text = @"";
        return header;
        
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? 50 : 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
        return 44;
    } else if (indexPath.section == 1){
        return 90;
    }
    return 44;
}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case kTotalPointsTextField:
            self.totalPoints = [NSNumber numberWithInt:[textField.text intValue]];
            break;
            
        default:
            break;
    }
}

- (NSInteger)numberOfOffenseAllowed
{
    return ([self.game.numberOfPlayers intValue] < 5) ? 1 : 2;
}

- (void)pointsNeededSegmentedControlChanged:(UISegmentedControl *)sender
{
    self.requiredPoints = [NSNumber numberWithInt:[[sender titleForSegmentAtIndex:sender.selectedSegmentIndex] intValue]];
}



@end
