//
//  CustomNavigationBar.m
//  NavigationBarWithShadowDemo
//
//  Created by Derek Yang on 01/07/12.
//  Copyright 2012 Derek Yang. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "CustomNavigationBar.h"

@implementation CustomNavigationBar

- (void)awakeFromNib {
    [super awakeFromNib];
    _image = [UIImage imageNamed:@"navigationbar.png"];
    self.tintColor = [UIColor colorWithRed:148.0 / 255.0 green:82.0 / 255.0 blue:29.0 / 255.0 alpha:1.0];

    // draw shadow
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0, 3);
    self.layer.shadowOpacity = 0.6;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    
    
}

- (void)drawRect:(CGRect)rect
{
    [_image drawInRect:rect];
}


@end
