//
//  NewGameTableViewController.m
//  TarotScores
//
//  Created by Sam - BlackRock on 4/3/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import "NewGameTableViewController.h"
#import "PlayerTableViewCell.h"
#import "BLKManagerCoreData.h"
#import "GameDataManager.h"
#import "Player.h"
#import "GameRoundPlayer.h"

@interface NewGameTableViewController ()

@property (nonatomic) NSInteger numberOfPlayers;
@property (strong, nonatomic) NSArray *playerNameArray;

@end

@implementation NewGameTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PlayerTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"newPlayerCell"];
    
    if (self.existingGame){
        self.numberOfPlayers = [self.existingGame.numberOfPlayers integerValue];
        self.navigationItem.title = @"Edit Game";
    } else {
        self.numberOfPlayers = 3;
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
        return self.numberOfPlayers;
    } else {
        return 1;
    }
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveGame:(id)sender {
    
    //Let's validate before we dismiss
    NSString *errorMessage;
    //Make sure the players have names
    NSMutableArray *playersArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.numberOfPlayers; i++) {
        PlayerTableViewCell *cell = (PlayerTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (cell.playerNameTextField.text.length > 0){
            [playersArray addObject:cell.playerNameTextField.text];
        } else {
            errorMessage = [NSString stringWithFormat:@"Player name missing for player %ld", (long)cell.playerNumber + 1];
            break;
        }
    }
    self.playerNameArray = [playersArray copy];

    if (errorMessage.length > 0){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error creating new game. Go back and fix it!" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDestructive handler:nil];
        [alert addAction:okay];
        [self presentViewController: alert animated:YES completion:nil];
    } else {
        //Ask user for the game name before saving
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enter a name for this game" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *save = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            UITextField *nameTf = alert.textFields.firstObject;
            NSString *name = nameTf.text;
            [self saveGameWithName:name];
        }];
        
        [alert addAction:cancel];
        [alert addAction:save];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *tf){
            tf.placeholder = @"Name the game";
            if (self.existingGame){
                tf.text = self.existingGame.name;
            }
        }];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)saveGameWithName:(NSString *)name
{
    //Update the existing
    if (self.existingGame){
        self.existingGame.name = name;
        self.existingGame.time = [NSDate new];
        //Update player names maybe
        
        for (int i=0; i< self.existingGame.hasPlayers.count; i++) {
            self.existingGame.hasPlayers[i].name = self.playerNameArray[i];
        }
        //Check for any added new players
        if (self.playerNameArray.count > self.existingGame.hasPlayers.count){
            int newPlayers = (int)self.playerNameArray.count - (int)self.existingGame.hasPlayers.count;
            for (int i = 0; i < newPlayers; i++) {
                Player *player = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:[GameDataManager shared].mainMoc];
                player.name = self.playerNameArray[i + self.existingGame.hasPlayers.count];
                player.currentScore = [NSNumber numberWithInt:0];
                player.playsGame = self.existingGame;
                player.currentRound = [NSNumber numberWithInt:0];
                
                //If we are adding a player we have to add fake rounds
                for (int i = 0; i < [self.existingGame.hasPlayers[0].currentRound intValue]; i++) {
                    GameRoundPlayer *roundDetails = [NSEntityDescription insertNewObjectForEntityForName:@"GameRoundPlayer" inManagedObjectContext:[GameDataManager shared].mainMoc];
                    roundDetails.score = [NSNumber numberWithInt:0];
                    roundDetails.defensePlayer = [NSNumber numberWithBool:NO];
                    roundDetails.contractPlayer = [NSNumber numberWithBool:NO];
                    roundDetails.defensePlayer = [NSNumber numberWithBool:NO];
                    roundDetails.win = [NSNumber numberWithBool:NO];
                    [player addPlaysRoundsObject:roundDetails];
                }
            }
            self.existingGame.numberOfPlayers = [NSNumber numberWithInteger:self.numberOfPlayers];
        }
        
        // Now save the details
        NSError *error;
        if (![[GameDataManager shared].mainMoc save:&error]){
            DLOG(@"There was an error saving to core data %@", error);
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:SAVE_ROUND_NOTIFICATION object:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    //Create a new Game
    } else {
        // Set parameters for the model updates
        Game *game = [NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:[GameDataManager shared].childMoc];
        game.numberOfPlayers = [NSNumber numberWithInteger:self.numberOfPlayers];
        game.time = [NSDate date];
        game.name = name;
        
        for (NSString *playerString in self.playerNameArray){
            Player *player = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:[GameDataManager shared].childMoc];
            player.name = playerString;
            player.currentScore = [NSNumber numberWithInt:0];
            player.playsGame = game;
            player.currentRound = [NSNumber numberWithInt:0];
        }
        
        // Now save the details
        NSError *error;
        if (![[GameDataManager shared].childMoc save:&error]){
            DLOG(@"There was an error saving to core data %@", error);
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:SAVE_ROUND_NOTIFICATION object:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        [[GameDataManager shared].childMoc reset];
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
        //Players
        PlayerTableViewCell *cell = (PlayerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"newPlayerCell"];
        cell.playerNumber = indexPath.row + 1;
        cell.playerNumberLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row + 1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (self.existingGame && self.existingGame.hasPlayers.count > indexPath.row){
            cell.playerNameTextField.text = self.existingGame.hasPlayers[indexPath.row].name;
        }
        return cell;
    } else if (indexPath.section == 1){
        //Add player button
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        if (self.numberOfPlayers< 5){
            UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
            [addButton addTarget:self action:@selector(addPlayer:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = addButton;
        } else {
            cell.accessoryView = nil;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    //Catch all - should never come here
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

- (void)addPlayer:(id)sender
{
    NSIndexPath *ip = [NSIndexPath indexPathForRow:self.numberOfPlayers inSection:0];
    self.numberOfPlayers++;
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    NSRange range = NSMakeRange(1, 1);
    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    //Make new player cell the first responder
    PlayerTableViewCell *cell = (PlayerTableViewCell *)[self.tableView cellForRowAtIndexPath:ip];
    [cell.playerNameTextField becomeFirstResponder];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 2){
        return @"Players";
    }
    return @"";
}

@end
