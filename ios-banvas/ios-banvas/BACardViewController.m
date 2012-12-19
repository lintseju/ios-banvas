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
//    [self.view sendSubviewToBack:self.DetailscrollView];
    
//    self.DetailscrollView.showsHorizontalScrollIndicator = NO;
//    self.DetailscrollView.scrollEnabled = YES;
//    self.DetailscrollView.pagingEnabled = YES;
//    [self.DetailscrollView setDelegate:self];
//    
//    //page control
//    [self.pageControl setNumberOfPages:4];
//    [self.pageControl setCurrentPage:0];
//    
//    //every detail view set size
//    CGFloat width, height;
//    width = self.DetailscrollView.frame.size.width;
//    height = self.DetailscrollView.frame.size.height;
//    [self.DetailscrollView setContentSize:CGSizeMake(width * 4, height)];
//    
////    UIScrollView 
//    for (int i=0; i!=self.pageControl.numberOfPages; i++) {
//        CGRect frame = CGRectMake(width*i, 0, width, height);
//        UIScrollView *view = [[UIScrollView alloc]initWithFrame:frame];
//        view.scrollEnabled = YES;
//        view.showsHorizontalScrollIndicator = NO;
//        
//        CGFloat r, g ,b;
//        r = (arc4random() % 10) / 10.0;
//        g = (arc4random() % 10) / 10.0;
//        b = (arc4random() % 10) / 10.0;
//        [view setBackgroundColor:[UIColor colorWithRed:r green:g blue:b alpha:0.8]];
//        
//        //使用QuartzCore.framework替UIView加上圓角
//        [view.layer setCornerRadius:15.0];
//        UILabel *text = [[UILabel alloc]initWithFrame:CGRectMake(30.0f, 30.0f, 150.0f, 80.0f)];text.text = [@"view" stringByAppendingFormat:@"%d", i];
//        [view addSubview:text];
//        [self.DetailscrollView addSubview:view];
//    }
//    
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)sender {
//    CGFloat width = self.DetailscrollView.frame.size.width;
//    NSInteger currentPage = ((self.DetailscrollView.contentOffset.x - width / 2) / width) + 1;
//    [self.pageControl setCurrentPage:currentPage];
//}
//
//- (IBAction)changeCurrentPage:(UIPageControl *)sender {
//    NSInteger page = self.pageControl.currentPage;
//    
//    CGFloat width, height;
//    width = self.DetailscrollView.frame.size.width;
//    height = self.DetailscrollView.frame.size.height;
//    CGRect frame = CGRectMake(width*page, 0, width, height);
//    
//    [self.DetailscrollView scrollRectToVisible:frame animated:YES];
}

- (void)updateSelectedSegmentLabel
{
    NSDictionary *PersonInfo =  [[BADataSource data]getPersonInfo:self.userId];
    [self cleanDetailView];
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
        {
            for (UIView *view in [self.DetailscrollView subviews])
            {
                if ( ![view isKindOfClass:[UISegmentedControl class]])
                    [view removeFromSuperview];
            }
            NSString* content = [PersonInfo valueForKey:@"about_me"];
            [self drawAboutView:content];
        }
        break;
        
        case 1:
        {
           NSString* content = [PersonInfo valueForKey:@"about_me"];
            NSLog(@"TT");
            
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
    
    UILabel *about =[[UILabel alloc] initWithFrame:CGRectMake(30.0f, 30.0f, 150.0f, 80.0f)];
    about.text =content;
    [self.DetailscrollView addSubview:about
     ];

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
