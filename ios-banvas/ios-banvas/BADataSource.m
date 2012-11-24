//
//  BADataSource.m
//  ios-banvas
//
//  Created by Lucien on 12/11/23.
//  Copyright (c) 2012年 lintseju. All rights reserved.
//

#import "BADataSource.h"

@implementation BADataSource

+(BADataSource*) data
{
    static dispatch_once_t once;
    static BADataSource *data;
    dispatch_once(&once, ^ {
        data = [[self alloc] init];
    });
    return data;
}

#pragma mark - ClientSide

-(NSArray*) getPersonList
{
    return nil;
}

-(NSDictionary*) getPersonInfo:(id) byPersonID
{
    return nil;
}

#pragma mark - ServerSide

-(Boolean) createPersonByPersonID:(NSString*) personID
{
    return YES;
}

-(Boolean) updatePersonByPersonID:(NSString*) personID andTag:(NSString*)tag
{
    return YES;
}

-(Boolean) deletePersonByPersonID:(NSString*) personID
{
    return YES;
}

-(Boolean) readPersonByPersonID:(NSString*) personID
{
    return YES;
}

@end
