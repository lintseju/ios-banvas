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
static NSArray *rgba;

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
        //read local data
        
        NSString *path = [[NSBundle mainBundle] pathForResource:dbFileName ofType:dbFileType];
        NSString *dbString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSArray *tmpArray = [dbString mutableObjectFromJSONString];
        if(tmpArray == nil)
            NSLog(@"Read %@.%@ error!!!", dbFileName, dbFileType);
        //check activity
        dbFileArray = [[NSMutableArray alloc] init];
        for(NSDictionary *obj in tmpArray){
            if([[obj valueForKey:@"active"] isEqualToString:@"y"]){
                [dbFileArray addObject:obj];
            }
        }

        NSString *configPath = [[NSBundle mainBundle] pathForResource:configName ofType:configType];
        NSString *confString = [[NSString alloc] initWithContentsOfFile:configPath encoding:NSUTF8StringEncoding error:nil];
        configDic = [confString mutableObjectFromJSONString];
        if(configDic == nil)
            NSLog(@"Read %@.%@ error!!!", configName, configType);
        
        //[self refresh];
        arrayOfPersonInList = [[NSArray alloc] initWithObjects:@"id", @"pictureSmall", @"name", @"tag", @"company", @"department", @"position", nil];
        rgba = [[NSArray alloc] initWithObjects:@"r", @"g", @"b", @"a", nil];
        
        cache = [[NSCache alloc] init];
    }
    return self;
}

- (void)refresh {
    NSString *configPath = [[NSBundle mainBundle] pathForResource:configName ofType:configType];
    [[configDic JSONString] writeToFile:configPath atomically:NO encoding:NSUTF8StringEncoding error:nil];

    NSString *path = [[NSBundle mainBundle] pathForResource:dbFileName ofType:dbFileType];
    [[dbFileArray JSONString] writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
    
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

//URLString is like "http://xxx.xxx.xx.xxx"
//content is what you want to sent, check setHTTPBody in detail
//method is like "POST", "GET"
//encoding is string encoding..
//return value is server return in string format
+(NSDictionary*) getRequestStringFromURL:(NSString*)URLString withContent:(NSString*)content withMethod:(NSString*)method withEncoding:(NSStringEncoding)encoding;
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSURL *url = [[NSURL alloc] initWithString:URLString];
    [request setURL:url];
    [request setHTTPMethod:method];
    [request setHTTPBody:[content dataUsingEncoding:encoding]];
    NSLog(@"request = %@", request);
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error != nil)
        NSLog(@"getRequestString response:%@ and error: %@", response, error);
    NSDictionary *msgDic = [[[NSString alloc] initWithData:data encoding:encoding] objectFromJSONString];
    if(msgDic == nil)
        NSLog(@"Error reading msgDic as JSON format in getRequestString.");
    return msgDic;
}

+(NSDictionary*) getRequestString:(NSString*)URLString withContent:(NSString*)content withMethod:(NSString*)method withEncoding:(NSStringEncoding)encoding
{
    return [BADataSource getRequestStringFromURL:URLString withContent:content withMethod:method withEncoding:encoding];
}

-(Boolean) login:(NSString*)account andPassword:(NSString*)password
{
    NSString *loginURL = [NSString stringWithFormat:@"%@/login", URLString];
    NSString *loginMsg = [NSString stringWithFormat:@"email=%@&password=%@", account, password];
    NSDictionary *serverMsg = [BADataSource getRequestStringFromURL:loginURL withContent:loginMsg withMethod:@"POST" withEncoding:NSUTF8StringEncoding];
//    NSLog(@"%@", [[serverMsg valueForKey:@"err"] class]);
    if([[serverMsg valueForKey:@"err"] intValue] != 0){
        NSLog(@"Error %@ occurred in login!", [serverMsg valueForKey:@"err"]);
        return NO;
    }
    userID = [serverMsg valueForKey:@"id"];
    token = [serverMsg valueForKey:@"token"];
//    NSLog(@"%@, %@", userID, token);
    return YES;
}

-(Boolean) addCategory:(NSString*)categoryName andColor:(UIColor*)color
{
    const CGFloat *components = CGColorGetComponents([color CGColor]);
    NSMutableArray *tag = [configDic valueForKey:@"tag"];
    NSMutableDictionary *newTag = [[NSMutableDictionary alloc] init];
    for(int i = 0;i < 4;i++){
        NSNumber *tmp = [[NSNumber alloc] initWithDouble:components[i]];
        [newTag setObject:tmp forKey:rgba[i]];
    }
    //future work: check name collision
    [newTag setObject:categoryName forKey:@"name"];
    [tag addObject:newTag];
    [configDic removeObjectForKey:@"tag"];
//    NSLog(@"%@", [configDic JSONString]);
    [configDic setObject:tag forKey:@"tag"];
//    NSLog(@"%@", [configDic JSONString]);

    [self refresh];
    return YES;
}

-(Boolean) deleteCategory:(NSString*)categoryName
{
    NSUInteger index;
    NSMutableArray *tagArray = [configDic valueForKey:@"tag"];
    for(NSMutableDictionary *obj in tagArray){
        if([[obj valueForKey:@"name"] isEqualToString:categoryName]){
            index = [tagArray indexOfObject:obj];
            break;
        }
    }
    [tagArray removeObjectAtIndex:index];
//    [configDic removeObjectForKey:@"tag"];
    [configDic setObject:tagArray forKey:@"tag"];
    [self refresh];
    return YES;
}

-(Boolean) updateTagColor:(NSString*)tag toColor:(UIColor*)color
{
    NSUInteger index;
    NSMutableArray *tagArray = [configDic valueForKey:@"tag"];
    const CGFloat *components = CGColorGetComponents([color CGColor]);
    NSMutableDictionary *tagToUpdate;
    for(NSMutableDictionary *obj in tagArray){
        if([[obj valueForKey:@"name"] isEqualToString:tag]){
            index = [tagArray indexOfObject:obj];
            tagToUpdate = [[NSMutableDictionary alloc] initWithDictionary:obj];
            break;
        }
    }
    for(int i = 0;i < 4;i++){
        NSNumber *tmp = [[NSNumber alloc] initWithDouble:components[i]];
        [tagToUpdate setObject:tmp forKey:rgba[i]];
    }
    [tagArray removeObjectAtIndex:index];
    [tagArray addObject:tagToUpdate];
    //    [configDic removeObjectForKey:@"tag"];
    [configDic setObject:tagArray forKey:@"tag"];
    [self refresh];
    return YES;
}

//offline only now
-(Boolean) createPersonByPersonID:(NSString*) personID
{
    NSUInteger index;
    NSMutableDictionary *personToUpdate;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:dbFileName ofType:dbFileType];
    NSString *dbString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *tmpArray = [dbString mutableObjectFromJSONString];
    if(tmpArray == nil)
        NSLog(@"Read %@.%@ error!!!", dbFileName, dbFileType);
    //check activity
    for(NSDictionary *obj in tmpArray){
        if([[obj valueForKey:@"id"] isEqualToString:personID]){
            [dbFileArray addObject:obj];
        }
    }

    
    for(NSMutableDictionary *person in dbFileArray){
        if([[person valueForKey:@"id"] isEqualToString:personID]){
            index = [dbFileArray indexOfObject:person];
            personToUpdate = [[NSMutableDictionary alloc] initWithDictionary:person];
            break;
        }
    }
    [personToUpdate setObject:@"y" forKey:@"active"];
    [dbFileArray removeObjectAtIndex:index];
    [dbFileArray addObject:personToUpdate];
    [self refresh];
    return YES;
}

-(Boolean) updatePersonByPersonID:(NSString*) personID andTag:(NSString*)tag
{
    NSUInteger index;
    NSMutableDictionary *personWithNewTag;
    for(NSMutableDictionary *person in dbFileArray){
        if([[person valueForKey:@"id"] isEqualToString:personID]){
            index = [dbFileArray indexOfObject:person];
            personWithNewTag = [[NSMutableDictionary alloc] initWithDictionary:person];
            break;
        }
    }
    [personWithNewTag setObject:tag forKey:@"tag"];
    [dbFileArray removeObjectAtIndex:index];
    [dbFileArray addObject:personWithNewTag];
    [self refresh];
    return YES;
}

//offline only now
-(Boolean) deletePersonByPersonID:(NSString*) personID
{
    NSUInteger index;
    NSMutableDictionary *personToUpdate;
    for(NSMutableDictionary *person in dbFileArray){
        if([[person valueForKey:@"id"] isEqualToString:personID]){
            index = [dbFileArray indexOfObject:person];
            personToUpdate = [[NSMutableDictionary alloc] initWithDictionary:person];
            break;
        }
    }
    [personToUpdate setObject:@"n" forKey:@"active"];
    [dbFileArray removeObjectAtIndex:index];
//    [dbFileArray addObject:personToUpdate];
    [self refresh];
    //NSLog(@"%@", dbFileArray);
    return YES;
}

-(NSDictionary*) readPersonByPersonID:(NSString*) personID
{
    /*NSString *statusURL = [NSString stringWithFormat:@"%@/%@/status", URLString, personID];
    NSString *statusMsg = nil;//[NSString stringWithFormat:@"{\"token\"=\"%@\"}", token];
    NSDictionary *serverMsg = [BADataSource getRequestStringFromURL:statusURL withContent:statusMsg withMethod:@"POST" withEncoding:NSUTF8StringEncoding];
    if([serverMsg valueForKey:@"err"] != 0){
        NSLog(@"Error %@ occurred in login!", [serverMsg valueForKey:@"err"]);
        return nil;
    }
    NSDictionary *returnData = [serverMsg valueForKey:@"data"];
    return returnData;*/
    for(NSDictionary *obj in dbFileArray){
        if([[obj valueForKey:@"id"] isEqualToString:personID]){
            [self refresh];
            return obj;
        }
    }
    return nil;
}

@end
