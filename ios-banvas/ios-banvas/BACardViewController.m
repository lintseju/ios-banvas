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
    
    //Detail view 設定
    self.DetailscrollView.contentSize = CGSizeMake(320.0f, 600.0f);
    self.DetailscrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"debut_light.png"]];

    [self updateSelectedSegmentLabel];
    
    
}

- (void)updateSelectedSegmentLabel
{
    NSDictionary *PersonInfo =  [[BADataSource data]getPersonInfo:self.userId];
    [self cleanDetailView];
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
        {
            NSString* content = [PersonInfo valueForKey:@"about_me"];
            [self drawAboutView:content];
        }
        break;
        
        case 1:
        {
           NSArray* content = [PersonInfo valueForKey:@"resume"];
            [self drawResumeView:content];
            
        }
        break;
        
        case 2:
        {
//            NSString* content = [PersonInfo valueForKey:@"about_me"];
            NSLog(@"TT");
            
        }
        break;
        case 3:{
//            NSString* content = [PersonInfo valueForKey:@"about_me"];
            NSLog(@"TT");
        }break;
        default:{
            }break;
    }
    self.test.text = [NSString stringWithFormat:@"%d", self.segmentedControl.selectedSegmentIndex];
}

-(void) drawAboutView:(NSString*)content{
    
    //set title
    UILabel *title =[[UILabel alloc] initWithFrame:CGRectMake(30.0f, 50.0f, 100.0f, 50.0f)];
    title.text = @"關於我";
    title.numberOfLines =1;
    [title setFont:[UIFont fontWithName:@"HoeflerText-Black" size:22]];
    [title setTextColor:[UIColor colorWithRed:0/255.0 green:184/255.0 blue:200/255.0 alpha:1]];
     [self.DetailscrollView addSubview:title];
    [title setBackgroundColor:[UIColor clearColor]];
    
    UILabel *about =[[UILabel alloc] initWithFrame:CGRectMake(30.0f, 100.0f, 260.0f, 80.0f)];
    about.numberOfLines = 0;
    about.text = content;
    [about setBackgroundColor:[UIColor clearColor]];
    [about sizeToFit];
    [self.DetailscrollView addSubview:about];
    
    
    CGFloat height = about.frame.size.height + title.frame.size.height + 200;
   
    self.DetailscrollView.contentSize = CGSizeMake(320.0f, height);

}

-(void) drawResumeView:(NSArray *)content{
    //set title
    UILabel *title =[[UILabel alloc] initWithFrame:CGRectMake(30.0f, 50.0f, 100.0f, 50.0f)];
    title.text = @"關於我";
    title.numberOfLines =1;
    [title setFont:[UIFont fontWithName:@"HoeflerText-Black" size:22]];
    [title setTextColor:[UIColor colorWithRed:0/255.0 green:184/255.0 blue:200/255.0 alpha:1]];
    [self.DetailscrollView addSubview:title];
    [title setBackgroundColor:[UIColor clearColor]];
    
    CGFloat height = title.frame.size.height;
    for( NSDictionary *unit in content){
        
    }

}

-(void) cleanDetailView{
    for (UIView *view in [self.DetailscrollView subviews])
    {
        if ( ![view isKindOfClass:[UISegmentedControl class]])
            [view removeFromSuperview];
    }
}


- (IBAction)segmentDidChange:(id)sender
{
    [self updateSelectedSegmentLabel];
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
    [self setSegmentedControl:nil];
    [self setTest:nil];
    [super viewDidUnload];
}
@end
