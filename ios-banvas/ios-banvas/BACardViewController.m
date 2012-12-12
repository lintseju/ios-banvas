//
//  BACardViewViewController.m
//  ios-banvas
//
//  Created by Lucien on 12/11/26.
//  Copyright (c) 2012年 lintseju. All rights reserved.
//

#import "BACardViewController.h"

@interface BACardViewController ()

@end

@implementation BACardViewController

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
    [super viewDidLoad];
    UIImageView *customBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"head.png"]];
    [self.view addSubview:customBackground];
    [self.view sendSubviewToBack:customBackground];
    
  
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

@end
