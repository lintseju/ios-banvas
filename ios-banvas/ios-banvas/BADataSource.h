//
//  BADataSource.h
//  ios-banvas
//
//  Created by Lucien on 12/11/23.
//  Copyright (c) 2012年 lintseju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JSONKit.h"

//Every people must have it's own tag!
//No category please assign "未分類"
static NSString *noneCategory = @"未分類";

@interface BADataSource : NSObject{
    NSArray* dbFileArray;
    NSDictionary *configDic;
    NSCache* cache;
}

+(BADataSource*) data;
- (void)refresh;
- (void)cleanCache;

//client side
-(NSArray*) getPersonList;
-(NSArray*) getPersonListByTag:(NSString*)tag;
-(NSDictionary*) getPersonInfo:(NSString*) byPersonID;
-(UIColor*) getColorOfTag:(NSString*)tag;

-(NSArray*) getTagList;

//server side
-(Boolean) refreshData:(NSString*)data;

//For scan class
-(Boolean) createPersonByPersonID:(NSString*) personID;

//For Collection update
-(Boolean) addCategory:(NSString*)categoryName;
-(Boolean) deleteCategory:(NSString*)categoryName;
-(Boolean) updateTagColor:(NSString*)tag toColor:(UIColor*)color;

-(Boolean) updatePersonByPersonID:(NSString*) personID andTag:(NSString*)tag;
-(Boolean) deletePersonByPersonID:(NSString*) personID;
-(Boolean) readPersonByPersonID:(NSString*) personID;

@end
