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

- (id)init
{
    self = [super init];
    if(self){
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //if([self.navigationController.viewControllers indexOfObject:self] == 0)
        self.navigationItem.rightBarButtonItem = nil;
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
        if([self.navigationController.viewControllers indexOfObject:self] == 1){
            listArray = [[BADataSource data] getPersonListByTag:self.displayName];
        }else{
            listArray = [[BADataSource data] getPersonList];
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
    if([self.navigationController.viewControllers indexOfObject:self] == 1)
        return [[[BADataSource data] getPersonListByTag:self.displayName] count];
    return [[[BADataSource data] getPersonList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier /*forIndexPath:indexPath*/];
    int listIdx = indexPath.row;
    NSArray *listArray;
    NSDictionary *cellInfo;
    BAPeopleListViewCell *personCell = (BAPeopleListViewCell*)cell;
    if([self.navigationController.viewControllers indexOfObject:self] == 1){
        [personCell.coloredTag setBackgroundColor:[[BADataSource data] getColorOfTag:self.displayName]];
        listArray = [[BADataSource data] getPersonListByTag:self.displayName];
    }else{
        [personCell.coloredTag setBackgroundColor:[UIColor whiteColor]];
        listArray = [[BADataSource data] getPersonList];
    }
    cellInfo = [listArray objectAtIndex:listIdx];
    personCell.nameLabel.text = [cellInfo valueForKey:@"name"];
    personCell.descriptionLabel.text = [cellInfo valueForKey:@"company"];
    personCell.personID = [cellInfo valueForKey:@"id"];
    return cell;
}

#pragma For Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"pushToCard"]){
        BAPeopleListViewCell *cell = (BAPeopleListViewCell*)sender;
        NSLog(@"%@", cell.personID);
        BACardViewController *card = segue.destinationViewController;
        card.userId = cell.personID;
    }

}

@end
