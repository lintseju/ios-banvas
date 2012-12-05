//
//  BAPeopleListViewController.h
//  ios-banvas
//
//  Created by lintseju on 12/11/24.
//  Copyright (c) 2012年 lintseju. All rights reserved.
//
//
//
//  This class is for both total list and second level of catagorical list.
//

#import <UIKit/UIKit.h>
#import "BADataSource.h"
#import "BAPeopleListViewCell.h"

@interface BAPeopleListViewController : UITableViewController{
    /*
     * displayTag is a string of tag name
     * If the person does not in any catagory, then displayTag == nil
     */
}

@property (strong, nonatomic) NSString *displayName;

@end
