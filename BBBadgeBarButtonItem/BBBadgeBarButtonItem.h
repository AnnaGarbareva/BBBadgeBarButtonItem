//
//  BBBadgeBarButtonItem.h
//
//  Created by Tanguy Aladenise on 07/02/14.
//  Copyright (c) 2014 Riverie, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZAppearance.h"

typedef NS_ENUM(NSInteger, BBBadgePosition) {
    BBBadgePositionTopLeft,
    BBBadgePositionTopRight,
    BBBadgePositionBottomLeft,
    BBBadgePositionBottomRight,
    BBBadgePositionBottomCustom
};

@interface BBBadgeBarButtonItem : UIBarButtonItem

// Each time you change one of the properties, the badge will refresh with your changes

// Badge value to be display
@property (nonatomic) NSString *badgeValue;
// Badge background color
@property (nonatomic) UIColor *badgeBGColor MZ_APPEARANCE_SELECTOR;
// Badge text color
@property (nonatomic) UIColor *badgeTextColor MZ_APPEARANCE_SELECTOR;
// Badge font
@property (nonatomic) UIFont *badgeFont MZ_APPEARANCE_SELECTOR;
// Padding value for the badge
@property (nonatomic) CGFloat badgePadding MZ_APPEARANCE_SELECTOR;
// Minimum size badge to small
@property (nonatomic) CGFloat badgeMinSize MZ_APPEARANCE_SELECTOR;
// In case of numbers, remove the badge when reaching zero
@property (nonatomic) BOOL shouldHideBadgeAtZero MZ_APPEARANCE_SELECTOR;
// Badge has a bounce animation when value changes
@property (nonatomic) BOOL shouldAnimateBadge MZ_APPEARANCE_SELECTOR;
@property (nonatomic) BBBadgePosition badgePosition MZ_APPEARANCE_SELECTOR;
//if badgePosition is custom, used badgeCustomOrigin property
@property (nonatomic) CGPoint badgeCustomOrigin;

- (BBBadgeBarButtonItem *)initWithCustomUIButton:(UIButton *)customButton;



@end