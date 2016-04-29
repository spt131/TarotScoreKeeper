//
//  NewRoundTableViewController.m
//  TarotScores
//
//  Created by Sam - BlackRock on 4/3/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import "NewRoundTableViewController.h"
#import "NewRoundTableViewCell.h"
#import "ContractTableViewCell.h"
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

@property (nonatomic, strong) Player *contractPlayer;
@property (nonatomic, strong) Player *partnerPlayer;
@property (nonatomic, strong) NSMutableArray <Player *> *defense;
@property (nonatomic, strong) NSMutableArray <Player *> *inactivePlayers;

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
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ContractTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"contractCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SegmentedTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"segmentedCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"NewRoundSegmentTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"newRoundSegmentCell"];
     [self.tableView registerNib:[UINib nibWithNibName:@"PlayerTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"newPlayerCell"];
    
    self.defense = [[NSMutableArray alloc] init];
    self.inactivePlayers = [[NSMutableArray alloc] init];
    if (self.existingRoundArray.count > 0){
        for (GameRoundPlayer *round in self.existingRoundArray) {
            if ([round.contractPlayer boolValue] == YES){
                self.contractPlayer = round.forPlayer;
                self.totalPoints = round.pointsFor;
                self.requiredPoints = round.pointsNeeded;
                self.gameType = round.contractType;
                
            } else if ([round.partnerPlayer boolValue] == YES){
                self.partnerPlayer = round.forPlayer;
            } else if ([round.defensePlayer boolValue] == YES){
                [self.defense addObject:round.forPlayer];
            } else {
                //New Player that wasnt in the round originally
                [self.inactivePlayers addObject:round.forPlayer];
            }
            self.title = [NSString stringWithFormat:@"Round %@", round.roundNum];
        }
    }
    
    if (!self.requiredPoints){
        self.requiredPoints = [NSNumber numberWithInt:41];
        self.gameType = (TarotGameType)0;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0){
        return self.game.hasPlayers.count;
    } else if (section == 1){
        return 3;
    }
    return 0;
}

- (IBAction)dismiss:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)save:(UIBarButtonItem *)sender {
    //Let's validate before we dismiss
    //Must have one contract no matter what
    //If 5 players or more, must have partner? - not really?
    
    NSString *errorMessage;
    
    //Make sure we have at contract,partner, or defense for all players
    if ([self selectedPositions] < [self.game.numberOfPlayers intValue]){
        errorMessage = @"You must select a position for each player";
    }
    
    //Force resign first responders
    if (self.totalPointsTextField.isFirstResponder){
        [self.totalPointsTextField resignFirstResponder];
    }
    
    //Total Score multiplier based on contract size
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
            errorMessage = @"You must select a contract size";
            break;
    }
    
    if (errorMessage.length > 0){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error creating new round" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDestructive handler:nil];
        [alert addAction:okay];
        [self presentViewController: alert animated:YES completion:nil];
        return;
    }
    
    BOOL win = [self.totalPoints intValue] >= [self.requiredPoints intValue];
    int defaultScore = abs([self.totalPoints intValue] - [self.requiredPoints intValue]) + 25;
    int count = 0;
    for (Player *playerObj in self.game.hasPlayers) {
        GameRoundPlayer *roundDetails;
        NSNumber *oldScore = self.existingRoundArray[count].score;
        if (self.roundNum){
            roundDetails = self.existingRoundArray[count];
        } else {
            roundDetails = [NSEntityDescription insertNewObjectForEntityForName:@"GameRoundPlayer" inManagedObjectContext:[GameDataManager shared].childMoc];
        }
        
        roundDetails.defensePlayer = [NSNumber numberWithBool:[self.defense containsObject:playerObj]];
        roundDetails.win = [NSNumber numberWithBool:win];
        roundDetails.contractPlayer = [NSNumber numberWithBool:[self.contractPlayer isEqual:playerObj]];
        roundDetails.partnerPlayer = [NSNumber numberWithBool:[self.partnerPlayer isEqual:playerObj]];
        
        if ([roundDetails.contractPlayer boolValue] == YES){
            int winMultipler = (win == YES) ? 1 : -1;
            if ([self.game.numberOfPlayers intValue] >= 5){
                //Handle the case where there is no partner
                if (!self.partnerPlayer){
                    winMultipler *= 2;
                }
            }
            int playerCountMultiplier = ([self.game.numberOfPlayers intValue] == 4) ? 3 : 2;
            
            roundDetails.score = [NSNumber numberWithInt:(defaultScore * winMultipler * scoreMultipler * playerCountMultiplier)];
            roundDetails.contractType = self.gameType;
            roundDetails.pointsFor = self.totalPoints;
            roundDetails.pointsNeeded = self.requiredPoints;
        } else if ([roundDetails.partnerPlayer boolValue] == YES){
            int winMultipler = (win == YES) ? 1 : -1;
            roundDetails.score = [NSNumber numberWithInt:(defaultScore * winMultipler * scoreMultipler)];
        } else {
            int winMultipler = (win == YES) ? -1 : 1;
            roundDetails.score = [NSNumber numberWithInt:(defaultScore * winMultipler * scoreMultipler)];
        }
        
        BOOL save;
        if (self.roundNum){
            save = [[GameDataManager shared] updateGameRound:self.existingRoundArray[count] toNewRound:roundDetails withOldScore:oldScore];
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
        cell.tag = indexPath.row;
        [cell.segmentedControl addTarget:self action:@selector(playerTypeSelected:) forControlEvents:UIControlEventValueChanged];
        
        [cell.segmentedControl setEnabled:YES];
        
        //Disable partner if less than 5 players
        if ([self activePlayers] < 5){
            [cell.segmentedControl setEnabled:NO forSegmentAtIndex:1];
        }
        
        //Set other segments based on self properties
        if ([self.contractPlayer isEqual:playerObj]){
            [cell.segmentedControl setSelectedSegmentIndex:0];
        } else if ([self.partnerPlayer isEqual:playerObj]){
            [cell.segmentedControl setSelectedSegmentIndex:1];
        } else if ([self.defense containsObject:playerObj]){
            [cell.segmentedControl setSelectedSegmentIndex:2];
        } else if ([self.inactivePlayers containsObject:playerObj]){
            [cell.segmentedControl setEnabled:NO];
        } else {
            [cell.segmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
        }
        
        return cell;
    } else if (indexPath.section == 1){
        if (indexPath.row == 0){
            //Decide the type of round the taker selected
            ContractTableViewCell *cell = (ContractTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"contractCell"];
            [cell.segmentedControl addTarget:self action:@selector(contractTypeSelected:) forControlEvents:UIControlEventValueChanged];
            [cell.segmentedControl setSelectedSegmentIndex:self.gameType];
            return cell;
        } else if (indexPath.row == 1){
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
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        } else if (indexPath.row == 2){
            PlayerTableViewCell *cell = (PlayerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"newPlayerCell"];
            cell.playerNumberLabel.text = @"";
            cell.titleTextLabel.text = @"Points scored";
            cell.playerNameTextField.placeholder = @"Total";
            cell.playerNameTextField.keyboardType = UIKeyboardTypeDecimalPad;
            cell.playerNameTextField.tag = kTotalPointsTextField;
            cell.playerNameTextField.delegate = self;
            self.totalPointsTextField = cell.playerNameTextField;
            if (self.totalPoints){
                cell.playerNameTextField.text = [NSString stringWithFormat:@"%@", self.totalPoints];
            }
            return cell;
        }
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    return cell;
  
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

- (void)pointsNeededSegmentedControlChanged:(UISegmentedControl *)sender
{
    self.requiredPoints = [NSNumber numberWithInt:[[sender titleForSegmentAtIndex:sender.selectedSegmentIndex] intValue]];
}

- (void)playerTypeSelected:(UISegmentedControl *)sender
{
    NewRoundSegmentTableViewCell *cell = (NewRoundSegmentTableViewCell *)sender.superview.superview;
    Player *playerObj = [self.game.hasPlayers objectAtIndex:cell.tag];
    
    // Remove existing
    if ([self.defense containsObject:playerObj]){
        [self.defense removeObject:playerObj];
    }
    if ([self.contractPlayer isEqual:playerObj]){
        self.contractPlayer = nil;
    }
    if ([self.partnerPlayer isEqual:playerObj]){
        self.partnerPlayer = nil;
    }
    
    // Add new based on selection
    
    //Selected the Taker
    if (sender.selectedSegmentIndex == 0){
        self.contractPlayer = playerObj;
        //If no other defenses are set, let's add all the other players to defense!
        if (self.defense.count == 0 && self.game.hasPlayers.count < 5){
            for (Player *player in self.game.hasPlayers) {
                //Make sure it's not the player we're dealing with
                //The player is not already there because the count is zero!
                if (![player isEqual:playerObj]){
                    [self.defense addObject:player];
                }
            }
        } else if (self.defense.count == 0 && self.game.hasPlayers.count >= 5 && self.partnerPlayer){
            for (Player *player in self.game.hasPlayers) {
                //Make sure it's not the player we're dealing with
                //The player is not already there because the count is zero!
                if (![player isEqual:playerObj]){
                    [self.defense addObject:player];
                }
            }
        }
    } else if (sender.selectedSegmentIndex == 1){
        self.partnerPlayer = playerObj;
        //If no other defenses are set and its a 5 player game and you already set the contract set the others
        if (self.defense.count == 0 && self.game.hasPlayers.count >= 5 && self.contractPlayer){
            for (Player *player in self.game.hasPlayers) {
                //Make sure it's not the player we're dealing with
                //The player is not already there because the count is zero!
                if (![player isEqual:playerObj]){
                    [self.defense addObject:player];
                }
            }
        }
    } else if (sender.selectedSegmentIndex == 2){
        if (self.defense.count == [self maxDefenseAllowed]){
            [self.defense removeLastObject];
        }
        [self.defense addObject:playerObj];
    }
    
    [self.tableView reloadData];
    
}

- (void)contractTypeSelected:(UISegmentedControl *)sender
{
    self.gameType = (TarotGameType)sender.selectedSegmentIndex;
}

- (int)maxDefenseAllowed
{
    return (int)[self activePlayers] - 1;
}

- (int)selectedPositions
{
    int count = 0;
    
    count += self.defense.count;
    count += (self.contractPlayer) ? 1 : 0;
    count += (self.partnerPlayer) ? 1 : 0;
    
    return count;
}

- (NSInteger)activePlayers{
    return ([self.game.numberOfPlayers intValue] - self.inactivePlayers.count);
}
@end
