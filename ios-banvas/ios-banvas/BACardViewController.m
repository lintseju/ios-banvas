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
    NSString* pathName = [PersonInfo valueForKey:@"picture"];
    if ([pathName isEqualToString:@""]) {
        pathName = @"user";
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:pathName ofType:pictureFileType];
    self.picture.image = [UIImage imageWithContentsOfFile:path];
    
    //Detail view 設定
    self.DetailscrollView.contentSize = CGSizeMake(320.0f, 600.0f);
    self.DetailscrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"debut_light.png"]];

    [self updateSelectedSegmentLabel];
    
    
    //gesture!
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view] addGestureRecognizer:recognizer];
//    [recognizer release];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self view] addGestureRecognizer:recognizer];
//    [recognizer release];
    
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    NSLog(@"Swipe received.");
    
    if (recognizer.direction==UISwipeGestureRecognizerDirectionLeft) {
        if(self.segmentedControl.selectedSegmentIndex != 3){
            self.segmentedControl.selectedSegmentIndex++;
            [self updateSelectedSegmentLabel];
        }
    }
    if (recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        if(self.segmentedControl.selectedSegmentIndex != 0){
            self.segmentedControl.selectedSegmentIndex--;
            [self updateSelectedSegmentLabel];
        }
        else
            [self.navigationController popViewControllerAnimated:YES];
    }
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
            NSArray* content = [PersonInfo valueForKey:@"skill"];
            [self drawSkillView:content];
        }
        break;
        case 3:{
            NSString* phone = [PersonInfo valueForKey:@"phone_number"];
            NSString* fb = [PersonInfo valueForKey:@"fb"];
            NSString* email = [PersonInfo valueForKey:@"email"];
            NSString* twitter = [PersonInfo valueForKey:@"twitter"];
            
            [self drawContactView:phone :fb :email :twitter];

        }break;
        default:{
            }break;
    }
 
    
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
    title.text = @"過往履歷";
    title.numberOfLines =1;
    [title setFont:[UIFont fontWithName:@"HoeflerText-Black" size:22]];
    [title setTextColor:[UIColor colorWithRed:159/255.0 green:76/255.0 blue:23/255.0 alpha:1]];
    [self.DetailscrollView addSubview:title];
    [title setBackgroundColor:[UIColor clearColor]];
    
    CGFloat height = title.frame.size.height+50;
    int i = 1;
    for( NSDictionary *unit in content){
        
        UILabel *company = [[UILabel alloc]initWithFrame:CGRectMake( 10.0f, 0.0f, 260.0f, 50.0f)];
        company.text = [unit valueForKey:@"company"];
        [company setBackgroundColor:[UIColor clearColor]];
        company.textColor =[UIColor whiteColor];
        UILabel *department =  [[UILabel alloc]initWithFrame:CGRectMake( 10.0f, 30.0f, 260.0f, 30.0f)];
        department.text = [unit valueForKey:@"department"];
        [department setBackgroundColor:[UIColor clearColor]];
        department.textColor =[UIColor whiteColor];
        UILabel *position =  [[UILabel alloc]initWithFrame:CGRectMake( 10.0f, 60.0f, 260.0f, 30.0f)];
        position.text = [unit valueForKey:@"position"];
        position.textColor =[UIColor whiteColor];
        [position setBackgroundColor:[UIColor clearColor]];
        
        UIView *partial = [[UIView alloc]initWithFrame:CGRectMake(30.0f, height, 260.0f, 120.0f)];
        partial.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3 ];
        [partial addSubview:company];
        [partial addSubview:department];
        [partial addSubview:position];
        
        partial.layer.shadowColor = [[UIColor blackColor] CGColor];
        partial.layer.shadowOffset = CGSizeMake(3.0f, 3.0f); // [水平偏移, 垂直偏移]
        partial.layer.shadowOpacity = 0.5f; // 0.0 ~ 1.0 的值
        partial.layer.shadowRadius = 10.0f; // 陰影發散的程度
        partial.layer.cornerRadius = 8;
        partial.layer.masksToBounds =YES;

        
        
        [self.DetailscrollView addSubview:partial];
        height += company.frame.size.height;
        height += department.frame.size.height;
        height += position.frame.size.height;
        height += 30;
        
        i++;
        
    }
    height += 200;
    self.DetailscrollView.contentSize = CGSizeMake(320.0f, height);

}

-(void) drawSkillView:(NSArray*) content{
    UILabel *title =[[UILabel alloc] initWithFrame:CGRectMake(30.0f, 50.0f, 100.0f, 50.0f)];
    title.text = @"技能";
    title.numberOfLines =1;
    [title setFont:[UIFont fontWithName:@"HoeflerText-Black" size:22]];
    [title setTextColor:[UIColor colorWithRed:235/255.0 green:158/255.0 blue:0/255.0 alpha:1]];
    [self.DetailscrollView addSubview:title];
    [title setBackgroundColor:[UIColor clearColor]];
    
    CGFloat height = title.frame.size.height+50;
    
    int index = 0;
    for( NSString* skill in content ){
        
        UIImage *image = [UIImage imageNamed: [skill stringByAppendingString:@".png"]];
        image = [self reSizeImage:image toSize:CGSizeMake(100.0f, 100.0f)];
        UIImageView *set = [[UIImageView alloc] initWithImage:image];
        set.backgroundColor = [UIColor grayColor];
        
        UILabel *description = [[UILabel alloc]initWithFrame:CGRectMake(0, 70, 100, 30)];
        description.text = skill;
        description.textAlignment = UITextAlignmentCenter;
        [description setFont:[UIFont fontWithName:@"Helveltica" size:16]];
        description.textColor = [UIColor whiteColor];
        description.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3 ];
        [set addSubview:description];
        
        CGFloat posX;
        if (index%2 == 0)
            posX = 100;
        else
            posX = 220;
        
        [set setCenter:CGPointMake(posX, index/2 * 100 + height+60)];
        
        [self.DetailscrollView addSubview:set];
        index++;
    }
    height += index/2 * 100;
    self.DetailscrollView.contentSize = CGSizeMake(320.0f, height);
}

-(void) drawContactView:(NSString*) phone :(NSString*)email :(NSString*)fb :(NSString*)twitter{
    UILabel *title =[[UILabel alloc] initWithFrame:CGRectMake(30.0f, 50.0f, 100.0f, 50.0f)];
    title.text = @"聯絡資訊";
    title.numberOfLines =1;
    [title setFont:[UIFont fontWithName:@"HoeflerText-Black" size:22]];
    [title setTextColor:[UIColor colorWithRed:144/255.0 green:135/255.0 blue:271/255.0 alpha:1]];
    [self.DetailscrollView addSubview:title];
    [title setBackgroundColor:[UIColor clearColor]];
    
    CGFloat height = title.frame.size.height+70;
    
    UIView *template = [[UIView alloc]initWithFrame:CGRectMake(50, height, 220, 40)];
    template.backgroundColor = [UIColor grayColor];
    template.layer.cornerRadius = 8;
    template.layer.masksToBounds =YES;
    
    
    UIImage *telephone = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"telephone.png"]];
    telephone = [self reSizeImage:telephone toSize:CGSizeMake(32, 32)];
    UIImage *facebook = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"mail.png"]];
    facebook = [self reSizeImage:facebook toSize:CGSizeMake(32, 32)];
    UIImage *mail = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"facebook.png"]];
    mail = [self reSizeImage:mail toSize:CGSizeMake(32, 32)];
//    UIImage *twi = [UIImage imageNamed:@"twitter"];
//    twi = [self reSizeImage:telephone toSize:CGSizeMake(32, 32)];
    
    //telephone
    UIView *phoneSet = [[UIView alloc]initWithFrame:template.frame];
    phoneSet.backgroundColor = [UIColor grayColor];
    phoneSet.layer.cornerRadius = 8;
    phoneSet.layer.masksToBounds =YES;
    [phoneSet setCenter:CGPointMake(150, height)];
    UIImageView *Picon = [[UIImageView alloc]initWithImage:telephone];
    [Picon setCenter:CGPointMake(20, 20)];
    UILabel *Ptext = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, 170, 40)];
    Ptext.text = phone;
    Ptext.textAlignment = UITextAlignmentCenter;
    [phoneSet addSubview:Picon];
    [phoneSet addSubview:Ptext];
    
    height+=70;
    
    //email
    UIView *emailSet = [[UIView alloc]initWithFrame:template.frame];
    emailSet.backgroundColor = [UIColor grayColor];
    emailSet.layer.cornerRadius = 8;
    emailSet.layer.masksToBounds =YES;
    [emailSet setCenter:CGPointMake(150, height)];
    UIImageView *Eicon = [[UIImageView alloc]initWithImage:mail];
    [Eicon setCenter:CGPointMake(20, 20)];
    UILabel *Etext = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, 170, 40)];
    Etext.text = email;
    Etext.textAlignment = UITextAlignmentCenter;
    [emailSet addSubview:Eicon];
    [emailSet addSubview:Etext];

    height+=70;

    //fb
    UIView *fbSet = [[UIView alloc]initWithFrame:template.frame];
    fbSet.backgroundColor = [UIColor grayColor];
    fbSet.layer.cornerRadius = 8;
    fbSet.layer.masksToBounds =YES;
    [fbSet setCenter:CGPointMake(150, height)];
    UIImageView *Ficon = [[UIImageView alloc]initWithImage:facebook];
    [Ficon setCenter:CGPointMake(20, 20)];
    UILabel *Ftext = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, 170, 40)];
    Ftext.text = fb;
    Ftext.textAlignment = UITextAlignmentCenter;
    [fbSet addSubview:Ficon];
    [fbSet addSubview:Ftext];
    
    
    [self.DetailscrollView addSubview:phoneSet];
    [self.DetailscrollView addSubview:emailSet];
    [self.DetailscrollView addSubview:fbSet];
//    [self.DetailscrollView addSubview:twitterSet];
    height += 200;
    self.DetailscrollView.contentSize = CGSizeMake(320.0f, height);

}

-(void) cleanDetailView{
    for (UIView *view in [self.DetailscrollView subviews])
    {
        if ( ![view isKindOfClass:[UISegmentedControl class]])
            [view removeFromSuperview];
    }
}


- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize

{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return reSizeImage;
    
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
   
    [super viewDidUnload];
}
@end
