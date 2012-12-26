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

//queue for server
static dispatch_queue_t network_queue;

+(BADataSource*) data
{
    static dispatch_once_t once;
    static BADataSource *data;
    dispatch_once(&once, ^ {
        data = [[self alloc] init];
        network_queue = dispatch_queue_create("network_queue", DISPATCH_QUEUE_SERIAL);
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
//        NSLog(@"%@", color);
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

-(Boolean) getAllDataFromServer
{
    NSDictionary *listData = [[[BADataSource data] updateDataWithServer:@"personList" withParameter:nil] valueForKey:@"collection"];
    NSArray *keys = [listData allKeys];
//    NSLog(@"%@", keys);
    if(![keys containsObject:noneCategory]){
        [self addCategory:noneCategory andColor:[UIColor blackColor]];
        listData = [[[BADataSource data] updateDataWithServer:@"personList" withParameter:nil] valueForKey:@"collection"];
        keys = [listData allKeys];
    }
    NSArray *statusArray = [[self updateDataWithServer:@"readPersonStatus" withParameter:[NSArray arrayWithObject:userID]] valueForKey:@"data"];
    NSMutableArray *tagArray = [[NSMutableArray alloc] init];
    configDic = [[NSMutableDictionary alloc] init];
    dbFileArray = [[NSMutableArray alloc] init];
    for(NSString *key in keys){
        NSArray *peopleArray = [listData valueForKey:key];
        NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
        [tmp setObject:key forKey:@"name"];
        [tmp setObject:@0 forKey:@"r"];
        [tmp setObject:@0 forKey:@"g"];
        [tmp setObject:@0 forKey:@"b"];
        [tmp setObject:@0 forKey:@"a"];
        [tagArray addObject:tmp];
        for(NSString *personID in peopleArray){
            NSMutableDictionary *person;
            for(NSDictionary *tmp2 in statusArray){
                if([[tmp2 valueForKey:@"id"] isEqualToString:personID]){
                    person = [[NSMutableDictionary alloc] initWithDictionary:tmp2];
                    break;
                }
            }
            [person addEntriesFromDictionary:[[self updateDataWithServer:@"readPerson" withParameter:[NSArray arrayWithObject:personID]] valueForKey:@"data"]];
            
            [dbFileArray addObject:person];
        }
    }
    [configDic setObject:tagArray forKey:@"tag"];
//    NSLog(@"%@", list);
//    NSLog(@"%@", [[self updateDataWithServer:@"readPersonStatus" withParameter:[NSArray arrayWithObject:userID]] valueForKey:@"data"]);
    if(listData == nil){
        NSLog(@"listData is nil in getAllDataFromServer.");
        return NO;
    }
//    NSLog(@"%@", dbFileArray);
//    NSLog(@"%@", configDic);
    [self refresh];
    return YES;
}

-(NSDictionary*) updateDataWithServer:(NSString*)data withParameter:(NSArray*)parameter
{
    NSString *url;
    NSMutableString *contentToServer = [NSMutableString stringWithFormat:@"token=%@", token];
    NSDictionary *serverData;
    if(token != nil){
        if([data isEqualToString:@"personList"]){
            url = [NSMutableString stringWithFormat:@"%@/%@/collect/list", URLString, userID];
        }else if([data isEqualToString:@"readPerson"]){
            NSString *personID = [parameter objectAtIndex:0];
            url = [NSString stringWithFormat:@"%@/%@/ios/detail", URLString, personID];
        }else if([data isEqualToString:@"createPerson"]){
            NSString *personID = [parameter objectAtIndex:0];
            url = [NSString stringWithFormat:@"%@/%@/collect/save", URLString, userID];
            contentToServer = (NSMutableString*)[contentToServer stringByAppendingFormat:@"&id=%@&tag=%@", personID, noneCategory];
        }else if([data isEqualToString:@"addCategory"]){
            NSString *tagName = [parameter objectAtIndex:0];
            url = [NSString stringWithFormat:@"%@/%@/collect/save_empty", URLString, userID];
            contentToServer = (NSMutableString*)[contentToServer stringByAppendingFormat:@"&tag=%@", tagName];
        }else if([data isEqualToString:@"updatePerson"]){
            NSString *personID = [parameter objectAtIndex:0];
            NSString *newTag = [parameter objectAtIndex:1];
            NSString *oldTag = [parameter objectAtIndex:2];
            url = [NSString stringWithFormat:@"%@/%@/collect/move", URLString, userID];
            contentToServer = (NSMutableString*)[contentToServer stringByAppendingFormat:@"&id=%@&to=%@&from=%@", personID, newTag, oldTag];
        }else if([data isEqualToString:@"deleteCategory"]){
            NSString *tagName = [parameter objectAtIndex:0];
            url = [NSString stringWithFormat:@"%@/%@/collect/delete_empty", URLString, userID];
            contentToServer = (NSMutableString*)[contentToServer stringByAppendingFormat:@"&tag=%@", tagName];
        }else if([data isEqualToString:@"deletePerson"]){
            NSString *personID = [parameter objectAtIndex:0];
            NSString *tag = [parameter objectAtIndex:1];
            url = [NSString stringWithFormat:@"%@/%@/collect/delete", URLString, userID];
            contentToServer = (NSMutableString*)[contentToServer stringByAppendingFormat:@"&id=%@&tag=%@", personID, tag];
        }else if([data isEqualToString:@"readPersonStatus"]){
            NSString *personID = [parameter objectAtIndex:0];
            url = [NSString stringWithFormat:@"%@/%@/ios/status", URLString, personID];
        }else{
            NSLog(@"Unknown data %@ with parameter %@ to read.", data, parameter);
            return nil;
        }
//        NSLog(@"Data from server is:%@", serverData);
        serverData = [BADataSource getRequestStringFromURL:url withContent:contentToServer withMethod:@"POST" withEncoding:NSUTF8StringEncoding];
        if([[serverData valueForKey:@"err"] isEqualToNumber:@0])
            return serverData;
    }
    NSLog(@"Error %@ occurred, when doing %@ to server with content %@.", [serverData valueForKey:@"err"], data, contentToServer);
    return nil;
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
//    NSLog(@"content = %@", content);
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error != nil)
        NSLog(@"getRequestString response:%@ and error: %@", response, error);
    NSDictionary *msgDic = [[[NSString alloc] initWithData:data encoding:encoding] objectFromJSONString];
    if(msgDic == nil)
        NSLog(@"Error reading msgDic as JSON format in getRequestString %@.", [[NSString alloc] initWithData:data encoding:encoding]);
    return msgDic;
}

+(NSString*) createHTTPBodyByDictionary:(NSDictionary*)dataDictionary
{
    NSEnumerator *keys = [dataDictionary keyEnumerator];
    id key = [keys nextObject];
    if(key == nil)
        return nil;
    NSString *outputString = [[NSString alloc] initWithFormat:@"%@=%@", key, [dataDictionary valueForKey:key]];
    while((key = [keys nextObject])){
        [outputString stringByAppendingFormat:@"&%@=%@", key, [dataDictionary valueForKey:key]];
    }
    return outputString;
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
    NSArray *tagList = [self getTagList];
    NSLog(@"%@", tagList);
    for(NSString *tagNow in tagList){
        if([tagNow isEqualToString:categoryName]){
            NSLog(@"Cannot create category %@, already exist.", categoryName);
            return NO;
        }
    }
    [newTag setObject:categoryName forKey:@"name"];
    [tag addObject:newTag];
    [configDic removeObjectForKey:@"tag"];
//    NSLog(@"%@", [configDic JSONString]);
    [configDic setObject:tag forKey:@"tag"];
//    NSLog(@"%@", [configDic JSONString]);
    dispatch_async(network_queue,^(void){
        [[BADataSource data] updateDataWithServer:@"addCategory" withParameter:[NSArray arrayWithObject:categoryName]];
    });

    [self refresh];
    return YES;
}

-(Boolean) deleteCategory:(NSString*)categoryName
{
    NSUInteger index = -1;
    NSMutableArray *tagArray = [configDic valueForKey:@"tag"];
    //move people to none category
    NSArray *peopleToUpdate = [self getPersonListByTag:categoryName];

    for(NSDictionary *person in peopleToUpdate){
        dispatch_async(network_queue,^(void){
            [[BADataSource data] updateDataWithServer:@"updatePerson" withParameter:[NSArray arrayWithObjects:categoryName, noneCategory, [person valueForKey:@"id"], nil]];
        });
        [self updatePersonByPersonID:[person valueForKey:@"id"] andTag:noneCategory];
    }
    //find category to delete
    for(NSMutableDictionary *obj in tagArray){
        if([[obj valueForKey:@"name"] isEqualToString:categoryName]){
            index = [tagArray indexOfObject:obj];
            break;
        }
    }
    if(index == -1){
        NSLog(@"No such category %@ when deleting category.", categoryName);
        return  NO;
    }
    [tagArray removeObjectAtIndex:index];
//    [configDic removeObjectForKey:@"tag"];
    [configDic setObject:tagArray forKey:@"tag"];
    [self refresh];
    dispatch_async(network_queue,^(void){
        [[BADataSource data] updateDataWithServer:@"deleteCategory" withParameter:[NSArray arrayWithObject:categoryName]];
    });
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

    dispatch_async(network_queue,^(void){
        [[BADataSource data] updateDataWithServer:@"createPerson" withParameter:[NSArray arrayWithObject:personID]];
    });
    
    return YES;
}

-(Boolean) updatePersonByPersonID:(NSString*) personID andTag:(NSString*)tag
{
    NSUInteger index;
    NSMutableDictionary *personWithNewTag;
    NSDictionary *oldInfo = [self getPersonInfo:personID];
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
    
    dispatch_async(network_queue,^(void){
        [[BADataSource data] updateDataWithServer:@"updatePerson" withParameter:[NSArray arrayWithObjects:personID, tag, [oldInfo valueForKey:@"tag"], nil]];
    });
    
    return YES;
}

//offline only now
-(Boolean) deletePersonByPersonID:(NSString*) personID
{
    NSUInteger index;
    NSMutableDictionary *personToUpdate;
    NSDictionary *oldInfo = [self getPersonInfo:personID];
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
    
    dispatch_async(network_queue,^(void){
        [[BADataSource data] updateDataWithServer:@"deletePerson" withParameter:[NSArray arrayWithObjects:personID, [oldInfo valueForKey:@"tag"], nil]];
    });
    
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
            
            dispatch_async(network_queue,^(void){
                [[BADataSource data] updateDataWithServer:@"readPerson" withParameter:[NSArray arrayWithObject:personID]];
            });
            
            return obj;
        }
    }
    return nil;
}

//tesing
/*-(Boolean) signupSample
{
    NSString *account = @"r01922004@csie.ntu.edu.tw";
    NSString *password = @"123";
    NSString *firstName = @"Tse-Ju";
    NSString *lastName = @"Lin";
    NSString *signup_id = @"lintseju";
    NSString *signupURL = [NSString stringWithFormat:@"%@/signup", URLString];
    NSString *signupMsg = [NSString stringWithFormat:@"email=%@&password=%@&first_name=%@&last_name=%@&id=%@", account, password, firstName, lastName, signup_id];
    NSArray *serverMsg = [BADataSource getRequestStringFromURL:signupURL withContent:signupMsg withMethod:@"POST" withEncoding:NSUTF8StringEncoding];
    //    NSLog(@"%@", [[serverMsg valueForKey:@"err"] class]);
    if([[serverMsg valueForKey:@"err"] intValue] != 0){
        NSLog(@"Error %@ occurred in login!", [serverMsg valueForKey:@"err"]);
        return NO;
    }
    return YES;
}*/

-(void) loginAlert
{
    UIAlertView *loginAlertView = [[UIAlertView alloc]initWithTitle:@"Login" message:@"Enter email and password to login or pass." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    loginAlertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    UITextField *emailField = [loginAlertView textFieldAtIndex:0];
    UITextField *passwordField = [loginAlertView textFieldAtIndex:1];
    emailField.text = @"r01922004@csie.ntu.edu.tw";
    passwordField.text = @"123";
    [loginAlertView show];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //login
    if(buttonIndex == 1){
        [[BADataSource data] login:[alertView textFieldAtIndex:0].text andPassword:[alertView textFieldAtIndex:1].text];
        
        //NSLog(@"%@", [[BADataSource data] updateDataWithServer:@"personList" withParameter:nil]);
        //    [[BADataSource data] updateDataWithServer:@"addCategory" withParameter:[NSArray arrayWithObject:noneCategory]];
        //    [[BADataSource data] updateDataWithServer:@"createPerson" withParameter:[NSArray arrayWithObject:@"wallywei"]];
        //    NSLog(@"%@", [[BADataSource data] updateDataWithServer:@"personList" withParameter:nil]);
        //    [[BADataSource data] updateDataWithServer:@"deletePerson" withParameter:[NSArray arrayWithObject:@"123456"]];
        //    NSLog(@"%@", [[BADataSource data] updateDataWithServer:@"readPerson" withParameter:[NSArray arrayWithObject:@"123456"]]);
        
        [[BADataSource data] getAllDataFromServer];
        
    }
}

@end
