//
//  BAPeopleListViewController.m
//  ios-banvas
//
//  Created by lintseju on 12/11/24.
//  Copyright (c) 2012年 lintseju. All rights reserved.
//

#import "BAPeopleListViewController.h"

@interface BAPeopleListViewController ()

@end

@implementation BAPeopleListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        displayTag = YES;
        displayName = nil;
    }
    NSLog(@"initWithaDecoder %@", aDecoder);
    return self;
}*/

- (id)init
{
    self = [super init];
    if(self){
        displayTag = NO;
    }
    NSLog(@"init");
    return self;
}

- (id)initWithTag:(NSString*)tag
{
    self = [super init];
    if(self){
        displayTag = YES;
        //displayName = tag;
        displayName = [[NSString alloc] initWithString:tag];
    }
    NSLog(@"initWithTag, %d, %@", displayTag, displayName);
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    /*
    //testing...
    NSArray *personList = [[BADataSource data] getPersonListByTag:@"Friend"];
    NSDictionary *personInfo = [[BADataSource data] getPersonInfo:@"1"];
    NSLog(@"%@", personList);
    NSLog(@"%@", personInfo);
    //testing...
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//This function is for swiping to delete
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //todo: delete the row
    if(editingStyle == UITableViewCellEditingStyleDelete){
        int listIdx = indexPath.row;
        NSArray *listArray;
        NSDictionary *cellInfo;
        if(!displayTag){
            listArray = [[BADataSource data] getPersonList];
        }else{
            listArray = [[BADataSource data] getPersonListByTag:displayName];
        }
        cellInfo = [listArray objectAtIndex:listIdx];
        [[BADataSource data] deletePersonByPersonID:[cellInfo valueForKey:@"id"]];
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!displayTag)
        return [[[BADataSource data] getPersonList] count];
    return [[[BADataSource data] getPersonListByTag:displayName] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    int listIdx = indexPath.row;
    NSArray *listArray;
    NSDictionary *cellInfo;
    BAPeopleListViewCell *personCell = (BAPeopleListViewCell*)cell;
    if(!displayTag){
        [personCell.coloredTag setBackgroundColor:[UIColor whiteColor]];
        listArray = [[BADataSource data] getPersonList];
    }else{
        [personCell.coloredTag setBackgroundColor:[[BADataSource data] getColorOfTag:displayName]];
        listArray = [[BADataSource data] getPersonListByTag:displayName];
    }
    cellInfo = [listArray objectAtIndex:listIdx];
    personCell.nameLabel.text = [cellInfo valueForKey:@"name"];
    personCell.descriptionLabel.text = [cellInfo valueForKey:@"company"];
    NSLog(@"cellForRowArIndexPath, %d, %@", displayTag, displayName);
    return cell;
}

#pragma For Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

@end
