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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//Every people must have it's own tag!
//No category please assign "未分類"
static NSString *noneCategory = @"未分類";
static NSString *URLString = @"http://banvas-dev.herokuapp.com";

//Configure filename
static NSString *configName = @"banvas";
static NSString *configType = @"conf";
//DB filename
static NSString *dbFileName = @"personData";
static NSString *dbFileType = @"txt";

//cache keys
const static NSString *BADataSourceCacheKeyForPersonList = @"BADataSource.Cache.PersonList";
const static NSString *BADataSourceCacheKeyForTagList = @"BADataSource.Cache.TagList";
static NSString *BADataSourceCacheKeyForPersonInID = @"BADataSource.Cache.Person.%@";
static NSString *BADataSourceCacheKeyForPersonTag = @"BADataSource.Cache.Tag.%@";
static NSString *BADataSourceCacheKeyForTagColor = @"BADataSource.Cache.%@.Color";

@interface BADataSource : NSObject<UIAlertViewDelegate, UITextFieldDelegate>{
    NSMutableArray* dbFileArray;
    NSMutableDictionary *configDic;
    NSCache* cache;
    NSString *userID;
    NSString *token;
}

+(BADataSource*) data;
+(NSDictionary*) getRequestStringFromURL:(NSString*)URLString withContent:(NSString*)content withMethod:(NSString*)method withEncoding:(NSStringEncoding)encoding;
+(NSString*) createHTTPBodyByDictionary:(NSDictionary*)dataDictionary;

- (void)refresh;
- (void)cleanCache;

//client side
-(NSArray*) getPersonList;
-(NSArray*) getPersonListByTag:(NSString*)tag;
-(NSDictionary*) getPersonInfo:(NSString*) byPersonID;
-(UIColor*) getColorOfTag:(NSString*)tag;

-(NSArray*) getTagList;

//server side
-(Boolean) getAllDataFromServer;
-(NSDictionary*) updateDataWithServer:(NSString*)data withParameter:(NSArray*)parameter;
-(Boolean) login:(NSString*)account andPassword:(NSString*)password;

//For scan class
-(Boolean) createPersonByPersonID:(NSString*) personID;

//For Collection update
-(Boolean) addCategory:(NSString*)categoryName andColor:(UIColor*)color;
-(Boolean) deleteCategory:(NSString*)categoryName;
-(Boolean) updateTagColor:(NSString*)tag toColor:(UIColor*)color;

-(Boolean) updatePersonByPersonID:(NSString*) personID andTag:(NSString*)tag;
-(Boolean) deletePersonByPersonID:(NSString*) personID;
-(NSDictionary*) readPersonByPersonID:(NSString*) personID;

//for testing
//-(Boolean) signupSample;
-(void) loginAlert;

@end
