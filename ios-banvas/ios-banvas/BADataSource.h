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

//data arrays
static NSArray *arrayOfPersonInList;

@interface BADataSource : NSObject{
    NSArray* dbFileArray;
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

//For scan class
-(Boolean) createPersonByPersonID:(NSString*) personID;

//For Collection update
-(Boolean) updatePersonByPersonID:(NSString*) personID andTag:(NSString*)tag;

-(Boolean) deletePersonByPersonID:(NSString*) personID;

-(Boolean) readPersonByPersonID:(NSString*) personID;

@end
