//
//  BACardViewViewController.h
//  ios-banvas
//
//  Created by Lucien on 12/11/26.
//  Copyright (c) 2012年 lintseju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BADataSource.h"
@interface BACardViewController : UIViewController

@property (strong, nonatomic) NSString *userId;
@property (weak, nonatomic) IBOutlet UIImageView *picture;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *company;
@property (weak, nonatomic) IBOutlet UILabel *position;
@property (weak, nonatomic) IBOutlet UILabel *department;

@property (weak, nonatomic) IBOutlet UIScrollView *DetailscrollView;

@end
