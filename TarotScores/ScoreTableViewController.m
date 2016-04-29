//
//  ScoreTableViewController.m
//  TarotScores
//
//  Created by Sam - BlackRock on 4/3/16.
//  Copyright © 2016 Sam. All rights reserved.
//

#import "ScoreTableViewController.h"
#import "ScoreTableViewCell.h"
#import "GameDataManager.h"
#import "NewRoundTableViewController.h"
#import "NewGameTableViewController.h"

@interface ScoreTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIStackView *headerStackView;
@property (nonatomic, strong) NSFetchedResultsController *fetchController;
@property (strong, nonatomic) IBOutlet UIView *navBarTitleView;
@property (strong, nonatomic) IBOutlet UILabel *navBarTopTitle;
@property (strong, nonatomic) IBOutlet UILabel *navBarBottomTitle;

@end

@implementation ScoreTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNameView];
    self.headerStackView.backgroundColor = [GLBUtil shared].tableSectionHeaderColor;
    self.headerView.backgroundColor = [GLBUtil shared].tableSectionHeaderColor;
    self.view.backgroundColor = [GLBUtil shared].tableSectionHeaderColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roundSaved) name:SAVE_ROUND_NOTIFICATION object:nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ScoreTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
    // table
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([Game class])];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetch setSortDescriptors:@[sortDescriptor]];
    [fetch setRelationshipKeyPathsForPrefetching:@[ @"hasPlayers", @"playsRounds"]];
    fetch.includesSubentities = YES;
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"SELF = %@", self.game];
    [fetch setPredicate:filter];
    
    self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetch managedObjectContext:[GameDataManager shared].mainMoc sectionNameKeyPath:nil cacheName:nil];
    
    [self.fetchController performFetch:nil];
    
    self.navBarTopTitle.textColor = [GLBUtil shared].barButtonColor;
    self.navBarBottomTitle.textColor = [GLBUtil shared].barButtonColor;
    
    [self updateNavTitle];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //Add button to titleView
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navTitleTapped)];
    [self.navBarTitleView addGestureRecognizer:tapGesture];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)updateNavTitle
{
    if ([[GameDataManager shared] gameNotStarted:self.game]){
        self.navBarBottomTitle.text = @"";
    } else {
        self.navBarBottomTitle.text = [NSString stringWithFormat:@"Round %@",self.game.hasPlayers[0].currentRound];
    }
    self.navBarTopTitle.text = self.game.name;
}

- (void)setupNameView
{
    //Remove names if they already exist
    if (self.headerStackView.arrangedSubviews.count > 0){
        for (UIView *view in self.headerStackView.arrangedSubviews) {
            [self.headerStackView removeArrangedSubview:view];
            [view removeFromSuperview];
        }
    }
    //Add names to header
    for (Player *player in self.game.hasPlayers) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
        label.adjustsFontSizeToFitWidth = YES;
        label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        label.numberOfLines = 1;
        label.text = player.name;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        
        [self.headerStackView addArrangedSubview:label];
    }
}

- (void)navTitleTapped
{
    UINavigationController *nvc = (UINavigationController *)[[GLBUtil shared].mainStoryboard instantiateViewControllerWithIdentifier:@"newGameNVC"];
    NewGameTableViewController *vc = (NewGameTableViewController* )[nvc topViewController];
    vc.existingGame = self.game;
    
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SAVE_ROUND_NOTIFICATION object:nil];
}

- (void)roundSaved
{   
    [self.fetchController performFetch:nil];
    self.game = [self.fetchController fetchedObjects].firstObject;
    [self updateNavTitle];
    [self setupNameView];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? [self.game.hasPlayers[0].currentRound integerValue] : [[GameDataManager shared] gameNotStarted:self.game] ? 0 : 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Init from new without reuse because it's too slow otherwise
    ScoreTableViewCell *cell = [[ScoreTableViewCell alloc] init];
    
    for (int i = 0; i < self.game.hasPlayers.count; i++){
        NSNumber *number;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.cornerRadius = 5.0;
        label.clipsToBounds = YES;
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor darkGrayColor];
        if (indexPath.section == 0){
            //Display each round
            if (self.game.hasPlayers[i].playsRounds.count > indexPath.row){
                GameRoundPlayer *round = self.game.hasPlayers[i].playsRounds[indexPath.row];
                number =  round.score;
                if ([round.contractPlayer boolValue] == YES || [round.partnerPlayer boolValue] == YES){
                    if ([round.win boolValue] == YES){
                        label.backgroundColor = UIColorFromHex(0x73ca80);
                    } else {
                        label.backgroundColor = UIColorFromHex(0xda7075);
                    }
                }
                label.text = [NSString stringWithFormat:@"%@", number];
            } else {
                //If a player joined after the beginning, rounds may not exist
                label.text = @"--";
            }

            
        } else {
            //Display the total
            Player *player =  self.game.hasPlayers[i];
            number = player.currentScore;
            cell.backgroundColor = [GLBUtil shared].tableSectionHeaderColor;
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 10000);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.userInteractionEnabled = NO;
            if ([player.currentScore isEqualToNumber:[self topScore]]){
                label.backgroundColor = UIColorFromHex(0x73ca80);
            }
            label.font = [UIFont systemFontOfSize:15 weight:0.25];
            label.text = [NSString stringWithFormat:@"%@", number];
        }
        
        [cell.cellStackView addArrangedSubview:label];
    }

    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"newRoundSegue"]){
        UINavigationController *nvc = (UINavigationController *)segue.destinationViewController;
        NewRoundTableViewController *vc = (NewRoundTableViewController* )[nvc topViewController];
        vc.game = self.game;
    } else if ([segue.identifier isEqualToString:@"roundDateilSegue"]){
        UINavigationController *nvc = (UINavigationController *)segue.destinationViewController;
        NewRoundTableViewController *vc = (NewRoundTableViewController *)[nvc topViewController];
        vc.game = self.game;
        int roundNum = (int)[self.tableView indexPathForSelectedRow].row;
        vc.roundNum = [NSNumber numberWithInt:roundNum];
        vc.existingRoundArray = [self arrayOfPlayersForRound:roundNum];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return (section == 0) ? 20: 0;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    //Set the background color of the View
    view.tintColor = [GLBUtil shared].tableSectionHeaderColor;
    
    if ([[GameDataManager shared] gameNotStarted:self.game]){
        
        UILabel *label = [[UILabel alloc] initWithFrame:view.frame];
        label.font = [UIFont systemFontOfSize:16];
        label.text = @"Add a new round to get started";
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
    } else {
        for (UIView *subView in view.subviews){
            if ([subView isKindOfClass:[UILabel class]]){
                [subView removeFromSuperview];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 0) ? 36: 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
        [self performSegueWithIdentifier:@"roundDateilSegue" sender:self];
    }
}

- (NSArray *)arrayOfPlayersForRound:(int)number
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (Player *playerObj in self.game.hasPlayers) {
        GameRoundPlayer *round = playerObj.playsRounds[number];
        [array addObject: round];
    }
    return array;
}

- (NSNumber *)topScore
{
    int top = 0;
    for (Player *playerObj in self.game.hasPlayers) {
        if ([playerObj.currentScore intValue] > top){
            top = [playerObj.currentScore intValue];
        }
    }
    return [NSNumber numberWithInt:top];
}

@end
