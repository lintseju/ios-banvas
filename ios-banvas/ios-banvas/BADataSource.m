//
//  BADataSource.m
//  ios-banvas
//
//  Created by Lucien on 12/11/23.
//  Copyright (c) 2012年 lintseju. All rights reserved.
//

#import "BADataSource.h"

@implementation BADataSource

//data arrays
static NSArray *arrayOfPersonInList;

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
        NSString *configPath = [[NSBundle mainBundle] pathForResource:configName ofType:configType];
        NSString *confString = [[NSString alloc] initWithContentsOfFile:configPath encoding:NSUTF8StringEncoding error:nil];
        configDic = [confString objectFromJSONString];
        
        arrayOfPersonInList = [[NSArray alloc] initWithObjects:@"id", @"pictureSmall", @"name", @"tag", @"company", @"department", @"position", nil];
        
        cache = [[NSCache alloc] init];
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
        personListByTag = [[NSMutableArray alloc] init];
        if(tag){
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

-(UIColor*) getColorOfTag:(NSString*)tag
{
    NSString *cacheKey = [NSString stringWithFormat:BADataSourceCacheKeyForTagColor, tag];
    UIColor *color = [cache objectForKey:cacheKey];
    NSArray *tagColorList = [configDic valueForKey:@"tag"];
    if(!color){
        for(NSDictionary *obj in tagColorList){
            NSString *nameNow = [obj valueForKey:@"name"];
            if([nameNow isEqualToString:tag]){
                CGFloat r = [[obj valueForKey:@"r"] doubleValue];
                CGFloat g = [[obj valueForKey:@"g"] doubleValue];
                CGFloat b = [[obj valueForKey:@"b"] doubleValue];
                CGFloat a = [[obj valueForKey:@"a"] doubleValue];
                color = [[UIColor alloc] initWithRed:r green:g blue:b alpha:a];
            }
        }
        [cache setObject:color forKey:cacheKey];
    }
    return color;
}

-(NSArray*) getTagList
{
    NSMutableArray *tagList = [cache objectForKey:BADataSourceCacheKeyForTagList];
    if(!tagList){
        NSArray *tagInConfig = [configDic valueForKey:@"tag"];
        tagList = [[NSMutableArray alloc] init];
        for(NSDictionary *obj in tagInConfig){
            NSString *tagNow = [obj valueForKey:@"name"];
            if(tagNow != nil && ![tagNow isEqualToString:noneCategory] && ![tagList containsObject:tagNow]){
                [tagList addObject:tagNow];
            }
        }
        if(!tagList)
            [cache setObject:tagList forKey:BADataSourceCacheKeyForTagList];
    }
    return (NSArray*)tagList;
}

#pragma mark - ServerSide

-(Boolean) refreshData:(NSString*)data
{
    return YES;
}

-(Boolean) addCategory:(NSString*)categoryName andColor:(UIColor*)color
{
    return YES;
}

-(Boolean) deleteCategory:(NSString*)categoryName
{
    return YES;
}

-(Boolean) updateTagColor:(NSString*)tag toColor:(UIColor*)color
{
    return YES;
}

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
