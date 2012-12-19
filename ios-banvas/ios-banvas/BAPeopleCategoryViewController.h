//
//  BAPeopleCategoryViewController.h
//  ios-banvas
//
//  Created by lintseju on 12/12/2.
//  Copyright (c) 2012年 lintseju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BADataSource.h"
#import "BAPeopleListViewController.h"
#import "JSONKit.h"

@interface BAPeopleCategoryViewController : UITableViewController
- (id)objectFromJSONString;
- (id)objectFromJSONStringWithParseOptions:(JKParseOptionFlags)parseOptionFlags;
- (id)objectFromJSONStringWithParseOptions:(JKParseOptionFlags)parseOptionFlags error:(NSError **)error;
- (id)mutableObjectFromJSONString;
- (id)mutableObjectFromJSONStringWithParseOptions:(JKParseOptionFlags)parseOptionFlags;
- (id)mutableObjectFromJSONStringWithParseOptions:(JKParseOptionFlags)parseOptionFlags error:(NSError **)error;

@end
