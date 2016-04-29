//
//  GameListTableViewController.m
//  TarotScores
//
//  Created by Sam - BlackRock on 4/3/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import "GameListTableViewController.h"
#import "ScoreTableViewController.h"
#import "BLKManagerCoreData.H"
#import "GameDataManager.h"
#import "GLBUtil.h"
#import "Game.h"
@interface GameListTableViewController ()

@end

@implementation GameListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.managedObjectContext = [GameDataManager shared].mainMoc;
    self.navigationItem.title = @"Tarot Score Keeper";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Game"];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO]];
    [request setRelationshipKeyPathsForPrefetching:@[ @"hasPlayers", @"playsRounds"]];
    request.includesSubentities = YES;
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gameCell" forIndexPath:indexPath];
    
    id object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    Game *gameObj = (Game *)object;
    cell.textLabel.text = gameObj.name;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterLongStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];
    cell.detailTextLabel.text = [df stringFromDate:gameObj.time];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:@"Do you really want to delete this game?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            [self deleteGameAtIndexPath:indexPath];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [ac addAction:cancel];
        [ac addAction:delete];
        
        [self presentViewController:ac animated:YES completion:nil];
    }
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return YES;
}

- (void)deleteGameAtIndexPath:(NSIndexPath *)indexPath
{
    // Delete the row from the data source on the main context
    Game *game = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.managedObjectContext deleteObject:game];
    NSError *error;
    if (![self.managedObjectContext save:&error]){
        DLOG(@"Error deleting from Core Data");
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: @"singleGameSegue"]){
        ScoreTableViewController *vc = segue.destinationViewController;
        vc.game = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.tableView.backgroundView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    NSInteger rows = 0;
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        rows = [sectionInfo numberOfObjects];
        if (!(rows > 0)){
            
            CGRect frame = self.view.frame;
            
            // Display a message when the table is empty
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            messageLabel.textColor = [UIColor blackColor];
            messageLabel.numberOfLines = 7;
            messageLabel.textAlignment = NSTextAlignmentCenter;
            messageLabel.font = [UIFont fontWithName:@"Arial" size:18];
            [messageLabel sizeToFit];
            NSString *text = @"Welcome to Tarot Score Keeper!\r\r\r\r\r\r\r";
            NSAttributedString *myText = [[NSAttributedString alloc] initWithString:text];
            
            
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = [UIImage imageNamed:@"tarot_raw"];
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
            float buttonWidth = 200;
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width/2 - buttonWidth/2, frame.size.height/2 - 75, buttonWidth, 40)];
            [button setTitle:@"New Game" forState:UIControlStateNormal];
            [button setTitleColor:[GLBUtil shared].headerColor forState:UIControlStateNormal];
            button.layer.borderColor = [GLBUtil shared].headerColor.CGColor;
            button.layer.borderWidth = 1.0f;
            button.layer.cornerRadius = 5.0f;
            button.backgroundColor = [GLBUtil shared].barButtonColor;
            [button addTarget:self action:@selector(newGame) forControlEvents:UIControlEventTouchUpInside];
            [messageLabel addSubview:button];
            
            
            NSMutableAttributedString *myString = [[NSMutableAttributedString alloc] initWithAttributedString:myText];
            [myString appendAttributedString:attachmentString];
            messageLabel.attributedText = myString;
            messageLabel.userInteractionEnabled = YES;
            
            self.tableView.backgroundView = messageLabel;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
    }
    return rows;
}


- (void)newGame
{
    UINavigationController *nvc = (UINavigationController *)[[GLBUtil shared].mainStoryboard instantiateViewControllerWithIdentifier:@"newGameNVC"];
    [self presentViewController:nvc animated:YES completion:nil];
}

@end
