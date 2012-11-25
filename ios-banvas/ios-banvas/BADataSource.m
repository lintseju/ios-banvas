//
//  BADataSource.m
//  ios-banvas
//
//  Created by Lucien on 12/11/23.
//  Copyright (c) 2012年 lintseju. All rights reserved.
//

#import "BADataSource.h"

@implementation BADataSource

//DB filename
static NSString *dbFileName = @"personData";
static NSString *dbFileType = @"txt";

//cache keys
const static NSString *BADataSourceCacheKeyForPersonList = @"BADataSource.Cache.PersonList";
static NSString *BADataSourceCacheKeyForPersonInID = @"BADataSource.Cache.Person.%@";
static NSString *BADataSourceCacheKeyForPersonTag = @"BADataSource.Cache.Tag.%@";


+(BADataSource*) data
{
    static dispatch_once_t once;
    static BADataSource *data;
    dispatch_once(&once, ^ {
        data = [[self alloc] init];
    });
    return data;
}

- (id)init {
    if (self = [super init]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:dbFileName ofType:dbFileType];
        NSString *dbString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        dbFileArray = [dbString objectFromJSONString];
        
        arrayOfPersonInList = [[NSArray alloc] initWithObjects:@"name", @"tag", @"company", @"department", @"position", nil];
        
        cache = [[NSCache alloc] init];
        //NSLog(@"%@", dbFileArray);
    }
    return self;
}

- (void)refresh {
    NSString *path = [[NSBundle mainBundle] pathForResource:dbFileName ofType:dbFileType];
    NSString *dbString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    dbFileArray = [dbString objectFromJSONString];
    
    [self cleanCache];
}

- (void)cleanCache {
    [cache removeAllObjects];
}

#pragma mark - ClientSide

-(NSArray*) getPersonList
{
    NSMutableArray *personList = [cache objectForKey:BADataSourceCacheKeyForPersonList];
    if(!personList){
        //personInList records the person ID
        personList = [[NSMutableArray alloc] init];
        NSMutableArray *personInList = [[NSMutableArray alloc] init];
        for(NSDictionary *obj in dbFileArray){
            NSString *personIDNow = [obj valueForKey:@"id"];
            if(personIDNow != nil && ![personInList containsObject:personIDNow]){
                [personInList addObject:personIDNow];
                NSArray *valuesForPersonNow = [obj objectsForKeys:arrayOfPersonInList notFoundMarker:@"keyNotFoundError"];
                NSDictionary *personNow = [[NSDictionary alloc] initWithObjects:valuesForPersonNow
                                                                                      forKeys:arrayOfPersonInList];
                [personList addObject:personNow];
            }
        }
        [cache setObject:personList forKey:BADataSourceCacheKeyForPersonList];
    }
    return (NSArray*)personList;
}

-(NSArray*) getPersonListByTag:(NSString*)tag
{
    NSString *cacheKey = [NSString stringWithFormat:BADataSourceCacheKeyForPersonTag, tag];
    NSMutableArray *personListByTag = [cache objectForKey:cacheKey];
    if(!personListByTag){
        NSArray *personList = [[BADataSource data] getPersonList];
        if(!tag){ //tag == nil
            for(NSDictionary *obj in personList){
                if([obj valueForKey:@"tag"])
                    [personListByTag addObject:obj];
            }
        }else{  //tag != nil
            for(NSDictionary *obj in personList){
                NSString *tagNow = [obj valueForKey:@"tag"];
                if([tagNow isEqualToString:tag])
                    [personListByTag addObject:obj];
            }
        }
    }
    return (NSArray*)personListByTag;
}

-(NSDictionary*) getPersonInfo:(NSString*) byPersonID
{
    NSString *cacheKey = [NSString stringWithFormat:BADataSourceCacheKeyForPersonInID, byPersonID];
    NSDictionary *personDict = [cache objectForKey:cacheKey];
    if(!personDict){
        for(NSDictionary *obj in dbFileArray){
            NSString *personIDNow = [obj valueForKey:@"id"];
            if([personIDNow isEqualToString:byPersonID]){
                personDict = [[NSDictionary alloc] initWithDictionary:obj];
                [cache setObject:personDict forKey:cacheKey];
                break;
            }
        }
    }
    return personDict;
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
