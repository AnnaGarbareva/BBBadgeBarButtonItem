//
//  BBBadgeBarButtonItem.m
//
//  Created by Tanguy Aladenise on 07/02/14.
//  Copyright (c) 2014 Riverie, Inc. All rights reserved.
//

#import "BBBadgeBarButtonItem.h"
#import "NSObject+MTKObserving.h"

@interface BBBadgeBarButtonItem()

// The badge displayed over the BarButtonItem
@property (nonatomic) UILabel *badge;

@end


@implementation BBBadgeBarButtonItem


#pragma mark - Init methods

- (BBBadgeBarButtonItem *)initWithCustomUIButton:(UIButton *)customButton
{
    return [self initWithCustomView:customButton];
}

- (BBBadgeBarButtonItem *)initWithCustomView:(UIView *)customView
{
    self = [super initWithCustomView:customView];
    if (self) {
        [self initializer];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializer];
    }
    return self;
}

+ (id)appearance
{
    return [MZAppearance appearanceForClass:[self class]];
}

+ (void)initialize
{
    [[BBBadgeBarButtonItem appearance] setBadgeBGColor:[UIColor redColor]];
    [[BBBadgeBarButtonItem appearance] setBadgeTextColor:[UIColor whiteColor]];
    [[BBBadgeBarButtonItem appearance] setBadgeFont:[UIFont systemFontOfSize:12.0]];
    [[BBBadgeBarButtonItem appearance] setShouldAnimateBadge:YES];
    [[BBBadgeBarButtonItem appearance] setShouldHideBadgeAtZero:YES];
    [[BBBadgeBarButtonItem appearance] setShouldHideBadgeAtZero:YES];
    [[BBBadgeBarButtonItem appearance] setBadgePadding:6];
    [[BBBadgeBarButtonItem appearance] setBadgeMinSize:8];
    [[BBBadgeBarButtonItem appearance] setBadgePosition:BBBadgePositionTopRight];
    [super initialize];
}

- (void)initializer
{
    // Default design initialization
    [[[self class] appearance] applyInvocationTo:self];

    // Avoids badge to be clipped when animating its scale
    self.customView.clipsToBounds = NO;

    [self subscribeForUpdateNotifications];
}

- (void)subscribeForUpdateNotifications
{
    [self observeProperty:@"badgeBGColor" withSelector:@selector(updateBadge)];
    [self observeProperty:@"badgeTextColor" withSelector:@selector(updateBadge)];
    [self observeProperty:@"badgeFont" withSelector:@selector(updateBadge)];
    [self observeProperty:@"badgePadding" withSelector:@selector(updateBadge)];
    [self observeProperty:@"badgeMinSize" withSelector:@selector(updateBadge)];
    [self observeProperty:@"badgeCustomOrigin" withSelector:@selector(updateBadge)];
    [self observeProperty:@"badgePosition" withSelector:@selector(updateBadge)];
}

- (void)dealloc
{
    [self removeAllObservations];
}

#pragma mark - Utility methods

// Handle badge display when its properties have been changed (color, font, ...)
- (void)updateBadgeStyle
{
    // Change new attributes
    self.badge.textColor        = self.badgeTextColor;
    self.badge.backgroundColor  = self.badgeBGColor;
    self.badge.font             = self.badgeFont;
}

- (void)updateBadgeFrame
{
    // When the value changes the badge could need to get bigger
    // Calculate expected size to fit new value
    // Use an intermediate label to get expected size thanks to sizeToFit
    // We don't call sizeToFit on the true label to avoid bad display
    UILabel *frameLabel = [self duplicateLabel:self.badge];
    [frameLabel sizeToFit];

    CGSize expectedLabelSize = frameLabel.frame.size;

    // Make sure that for small value, the badge will be big enough
    CGFloat minHeight = expectedLabelSize.height;

    // Using a const we make sure the badge respect the minimum size
    minHeight = (minHeight < self.badgeMinSize) ? self.badgeMinSize : expectedLabelSize.height;
    CGFloat minWidth = expectedLabelSize.width;
    CGFloat padding = self.badgePadding;

    // Using const we make sure the badge doesn't get too smal
    minWidth = (minWidth < minHeight) ? minHeight : expectedLabelSize.width;
    CGPoint origin = [self badgeOrigin];
    self.badge.frame = CGRectMake(origin.x, origin.y, minWidth + padding, minHeight + padding);
    self.badge.layer.cornerRadius = (minHeight + padding) / 2;
    self.badge.layer.masksToBounds = YES;
}

- (CGPoint)badgeOrigin
{
    CGPoint origin;

    CGSize badgeHalfSize = CGSizeMake(floorf(self.badge.frame.size.width*0.5f), floorf(self.badge.frame.size.height*0.5f));
    CGSize viewSize = self.customView.frame.size;

    switch (self.badgePosition) {
        case BBBadgePositionTopLeft:
            origin = CGPointMake( -badgeHalfSize.width, -badgeHalfSize.height);
            break;
        default:
        case BBBadgePositionTopRight:
            origin = CGPointMake(viewSize.width - badgeHalfSize.width, - badgeHalfSize.height);
            break;
        case BBBadgePositionBottomLeft:
            origin = CGPointMake(- badgeHalfSize.width,viewSize.height - badgeHalfSize.height);
            break;
        case BBBadgePositionBottomRight:
            origin = CGPointMake(viewSize.width - badgeHalfSize.width,viewSize.height - badgeHalfSize.height);
            break;
        case BBBadgePositionBottomCustom:
           origin = self.badgeCustomOrigin;
    }

    return origin;
}

// Handle the badge changing value
- (void)updateBadgeValueAnimated:(BOOL)animated
{
    // Bounce animation on badge if value changed and if animation authorized
    if (animated && self.shouldAnimateBadge && ![self.badge.text isEqualToString:self.badgeValue]) {
        CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [animation setFromValue:[NSNumber numberWithFloat:1.5]];
        [animation setToValue:[NSNumber numberWithFloat:1]];
        [animation setDuration:0.2];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:.4 :1.3 :1 :1]];
        [self.badge.layer addAnimation:animation forKey:@"bounceAnimation"];
    }

    // Set the new value
    self.badge.text = self.badgeValue;

    // Animate the size modification if needed
    NSTimeInterval duration = animated ? 0.2 : 0;
    [UIView animateWithDuration:duration animations:^{
        [self updateBadgeFrame];
    }];
}

- (UILabel *)duplicateLabel:(UILabel *)labelToCopy
{
    UILabel *duplicateLabel = [[UILabel alloc] initWithFrame:labelToCopy.frame];
    duplicateLabel.text = labelToCopy.text;
    duplicateLabel.font = labelToCopy.font;

    return duplicateLabel;
}

- (void)removeBadge
{
    // Animate badge removal
    [UIView animateWithDuration:0.2 animations:^{
        self.badge.transform = CGAffineTransformMakeScale(0, 0);
    } completion:^(BOOL finished) {
        [self.badge removeFromSuperview];
        self.badge = nil;
    }];
}

#pragma mark - Setters

- (void)setBadgeValue:(NSString *)badgeValue
{
    // Set new value
    _badgeValue = badgeValue;

    // When changing the badge value check if we need to remove the badge
    if (!badgeValue || [badgeValue isEqualToString:@""] || ([badgeValue isEqualToString:@"0"] && self.shouldHideBadgeAtZero)) {
        [self removeBadge];
    } else if (!self.badge) {
        // Create a new badge because not existing
        CGPoint origin = [self badgeOrigin];
        self.badge                      = [[UILabel alloc] initWithFrame:CGRectMake(origin.x, origin.y, 20, 20)];
        self.badge.textColor            = self.badgeTextColor;
        self.badge.backgroundColor      = self.badgeBGColor;
        self.badge.font                 = self.badgeFont;
        self.badge.textAlignment        = NSTextAlignmentCenter;

        [self.customView addSubview:self.badge];
        [self updateBadgeValueAnimated:NO];
    } else {
        [self updateBadgeValueAnimated:YES];
    }
}

#pragma mark - Updating

- (void)updateBadge
{
    if (self.badge) {
        [self updateBadgeStyle];
        [self updateBadgeFrame];
    }
}

@end