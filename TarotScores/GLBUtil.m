//
//  GLBUtil.m
//  FoodAtWork
//
//  Created by Sam - BlackRock on 6/14/14.
//  Copyright (c) 2014 BlackRock. All rights reserved.
//

#import "GLBUtil.h"
#import "BLKManagerCoreData.h"

@interface GLBUtil ()

@end

@implementation GLBUtil

NSString * const HUDupdatingText = @"Checking for Updates...";
NSString * const HUDupdateFoundText = @"Updates Available";
NSString * const HUDdownloadingText = @"Downloading now...";
const CGRect hudViewSize = {0,0,300,300};

+ (GLBUtil *)shared {
    
    static dispatch_once_t pred;
    static id shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[self alloc] init];
        [shared setup];
    });
    
    return shared;
}

-(void)setup
{
    self.firstAppLaunch = [self checkFirstTimeLaunch:@"app"];
    self.firstVersionLaunch = [self checkFirstTimeLaunch:@"version"];
    
    self.tableCellBackgroundColor  = [UIColor whiteColor];
    self.tableCellAltBackgrouColor = UIColorFromHex(0xf1f1f1);
    self.tableSectionHeaderColor   = UIColorFromHex(0xF5F5DC);
    self.tableSectionHeaderTextColor = [UIColor whiteColor];
    self.headerColor = UIColorFromHex(0x37b34a);
    self.barButtonColor = [UIColor whiteColor];
    self.tabBarTintColor = UIColorFromHex(0x005DA0);
    
    self.globalBgColor = UIColorFromHex(0xDCE1E3);
    self.globalContentColor = UIColorFromHex(0x005DA0);
}

-(BOOL)checkFirstTimeLaunch:(NSString *)ofType
{
    return YES;
}

-(UIStoryboard *)mainStoryboard
{
    if (!_mainStoryboard){
        _mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    }
    
    return _mainStoryboard;
}

@end

/*
 Other Aladdin VI Colors
 http://dox/org/401/DSWebDelivery/UX/Aladdin%20VI/Documents/Aladdin_DesignSpecs_v2.0.pdf
 
 Greens
 37b34a
 55BE65
 73ca80
 91D59c
 
 Blues
 008ccf
 269dd6
 4caedd
 73c0e5
 
 Dark Blues
 005da0
 2675ae
 4c8dbc
 73a6cb
 
 Reds
 cb333b
 d35158
 da7075
 e28f93
 
 oranges
 ed8b00
 f09c26
 f2ae4c
 f5bf73
 
 yellows
 ffcd00
 ffd426
 ffdc4c
 ffe473
 
 
 
 */