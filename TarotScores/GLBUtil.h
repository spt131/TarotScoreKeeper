//
//  GLBUtil.h
//  FoodAtWork
//
//  Created by Sam - BlackRock on 6/14/14.
//  Copyright (c) 2014 BlackRock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLBUtil : NSObject

@property (nonatomic) BOOL firstAppLaunch;
@property (nonatomic) BOOL firstVersionLaunch;

+(GLBUtil *)shared;

extern NSString * const HUDupdatingText;
extern NSString * const HUDupdateFoundText;
extern NSString * const HUDdownloadingText;
extern const CGRect hudViewSize;

//Macro to convert from Hex to UIColor to keep HTMl and iOS consistent
#define UIColorFromHex(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@property (nonatomic, strong) UIColor *headerColor;
@property (nonatomic, strong) UIColor *barButtonColor;
@property (nonatomic, strong) UIColor *tabBarTintColor;
@property (nonatomic, strong) UIColor *tableSectionHeaderColor;
@property (nonatomic, strong) UIColor *tableSectionHeaderTextColor;
@property (nonatomic, strong) UIColor *tableCellBackgroundColor;
@property (nonatomic, strong) UIColor *tableCellAltBackgrouColor;

@property (nonatomic, strong) UIColor *globalBgColor;
@property (nonatomic, strong) UIColor *globalContentColor;

@property (nonatomic, weak) UIStoryboard *mainStoryboard;

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

@end
