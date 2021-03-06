//
//  BAPeopleListViewController.h
//  ios-banvas
//
//  Created by lintseju on 12/11/24.
//  Copyright (c) 2012年 lintseju. All rights reserved.
//
//
//
//  This class is for both total list and second level of categorical list.
//

#import <UIKit/UIKit.h>
#import "BADataSource.h"
#import "BAPeopleListViewCell.h"
#import "BACardViewController.h"
#import "BATagUpdateViewController.h"

static NSString *pictureFileType = @"jpg";
BOOL isNormalMode[2];

@interface BAPeopleListViewController : UITableViewController

@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *reTagButton;
- (IBAction)reTagButtonTapped:(id)sender;

@end
