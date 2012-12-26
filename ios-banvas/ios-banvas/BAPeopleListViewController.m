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
    

    isNormalMode[[self.navigationController.viewControllers indexOfObject:self]] = true;
    //if([self.navigationController.viewControllers indexOfObject:self] == 0)
        //self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
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
//        NSLog(@"%d XD", [listArray count]);
        [[BADataSource data] deletePersonByPersonID:[cellInfo valueForKey:@"id"]];
//        [self.tableView reloadData];
        if([self.navigationController.viewControllers indexOfObject:self] == 1){
            listArray = [[BADataSource data] getPersonListByTag:self.displayName];
        }else{
            listArray = [[BADataSource data] getPersonList];
        }
//        NSLog(@"%d XD2", [listArray count]);
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
        listArray = [[BADataSource data] getPersonListByTag:self.displayName];
    }else{
        listArray = [[BADataSource data] getPersonList];
    }
    cellInfo = [listArray objectAtIndex:listIdx];
    [personCell.coloredTag setBackgroundColor:[[BADataSource data] getColorOfTag:[cellInfo valueForKey:@"tag"]]];
    personCell.nameLabel.text = [cellInfo valueForKey:@"name"];
    personCell.descriptionLabel.text = [cellInfo valueForKey:@"tag"];
    personCell.personID = [cellInfo valueForKey:@"id"];
    
    if([[cellInfo valueForKey:@"pictureSmall"] length] != 0){
        NSString *path = [[NSBundle mainBundle] pathForResource:[cellInfo valueForKey:@"pictureSmall"] ofType:pictureFileType];
        //縮放圖片
//        UIImage *pic = [UIImage imageWithContentsOfFile:path];
//        UIGraphicsBeginImageContext(CGSizeMake(60.0, 60.0));
//        [pic drawInRect:CGRectMake(0, 0, 60.0, 60.0)];
//        UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
        
        personCell.thumbnailView.image = [UIImage imageWithContentsOfFile:path];
    }else{
        personCell.thumbnailView = nil;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger modeIdx = [self.navigationController.viewControllers indexOfObject:self];

    int listIdx = indexPath.row;
    NSArray *listArray;
    if([self.navigationController.viewControllers indexOfObject:self] == 1){
        listArray = [[BADataSource data] getPersonListByTag:self.displayName];
    }else{
        listArray = [[BADataSource data] getPersonList];
    }
    NSDictionary *cellInfo = [listArray objectAtIndex:listIdx];
    
    UITableViewController *nextViewController;
    if(!isNormalMode[modeIdx]){
        nextViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"tagUpdateVIew"];
        BATagUpdateViewController *tmp = (BATagUpdateViewController*)nextViewController;
        tmp.personName = [cellInfo valueForKey:@"name"];
        tmp.personID = [cellInfo valueForKey:@"id"];
    }else{
        nextViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CardView"];
        
        BACardViewController *tmp = (BACardViewController*)nextViewController;
        tmp.userId = [cellInfo valueForKey:@"id"];
    }
    [self.navigationController pushViewController:nextViewController animated:YES];
}

- (IBAction)reTagButtonTapped:(id)sender{
    //NSLog(@"%@", self.reTagButton.title);
    NSUInteger modeIdx = [self.navigationController.viewControllers indexOfObject:self];
    if(isNormalMode[modeIdx]){
        self.reTagButton.title = @"完成";
        isNormalMode[modeIdx] = false;
    }else{
        self.reTagButton.title = @"重新分類";
        isNormalMode[modeIdx] = true;
    }
}
@end
