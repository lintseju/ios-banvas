//
//  BACardViewViewController.m
//  ios-banvas
//
//  Created by Lucien on 12/11/26.
//  Copyright (c) 2012年 lintseju. All rights reserved.
//

#import "BACardViewController.h"
#import "BAPeopleListViewController.h"

@interface BACardViewController ()

@end

@implementation BACardViewController

//exterstatic NSString *pictureFileType = @"jpg";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
//    [super viewDidLoad];
//    UIImageView *customBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"head.png"]];
//    [self.view addSubview:customBackground];
//    [self.view sendSubviewToBack:customBackground];
    
    //get data by id
    
    NSDictionary *PersonInfo =  [[BADataSource data]getPersonInfo:self.userId];
    self.name.text = [PersonInfo valueForKey:@"name"];
    self.position.text =[PersonInfo valueForKey:@"position"];
    self.company.text = [PersonInfo valueForKey:@"company"];
    self.department.text = [PersonInfo valueForKey:@"department"];
    NSString *path = [[NSBundle mainBundle] pathForResource:[PersonInfo valueForKey:@"picture"] ofType:pictureFileType];
    self.picture.image = [UIImage imageWithContentsOfFile:path];
    
    //Detail view init
    self.DetailscrollView.contentSize = CGSizeMake(320.0f, 600.0f);
    self.DetailscrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"debut_light.png"]];
    
    self.DetailscrollView.showsHorizontalScrollIndicator = NO;
    self.DetailscrollView.scrollEnabled = YES;
    self.DetailscrollView.pagingEnabled = YES;
}




- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPicture:nil];
    [self setName:nil];
    [self setCompany:nil];
    [self setPosition:nil];
    [self setDepartment:nil];
    [self setDetailscrollView:nil];
    [super viewDidUnload];
}
@end
