//
//  BATagUpdateViewController.m
//  ios-banvas
//
//  Created by lintseju on 12/12/13.
//  Copyright (c) 2012年 lintseju. All rights reserved.
//

#import "BATagUpdateViewController.h"

@interface BATagUpdateViewController ()

@end

@implementation BATagUpdateViewController

static NSArray *colorList;

+ (UIColor*)getColorByIndex:(NSInteger)colorListIndex
{
    switch (colorListIndex) {
        case 0:
            return [UIColor blackColor];
        case 1:
            return [UIColor darkGrayColor];
        case 2:
            return [UIColor lightGrayColor];
        case 3:
            return [UIColor grayColor];
        case 4:
            return [UIColor redColor];
        case 5:
            return [UIColor greenColor];
        case 6:
            return [UIColor blueColor];
        case 7:
            return [UIColor cyanColor];
        case 8:
            return [UIColor yellowColor];
        case 9:
            return [UIColor magentaColor];
        case 10:
            return [UIColor orangeColor];
        case 11:
            return [UIColor purpleColor];
        case 12:
            return [UIColor brownColor];
        default:
            break;
    }
    return [UIColor whiteColor];
}

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
	// Do any additional setup after loading the view.
    colorList = [[NSArray alloc] initWithObjects:@"Black", @"Dark Gray", @"Light Gray", @"Gray", @"Red", @"Green", @"Blue",\
                 @"Cyan", @"Yellow", @"Magenta", @"Orange", @"Purple", @"Brown", nil];
    //update tag
    if(self.tagName != nil){
        self.navigationController.title = @"更新分類";
        self.textInput.text = self.tagName;
        self.textInput.enabled = false;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTextInput:nil];
    [self setColorSelect:nil];
    [super viewDidUnload];
}

- (IBAction)buttonTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:TRUE];
    UIButton* senderButton = (UIButton*)sender;
    //好
    if(senderButton.tag == 1){
        UIColor *tagColorNow = [BATagUpdateViewController getColorByIndex:[self.colorSelect selectedRowInComponent:0]];
        if([self.textInput.text length] > 0)
            [[BADataSource data] addCategory:self.textInput.text andColor:tagColorNow];
    }
}

#pragma For UIPickerView Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [colorList count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [colorList objectAtIndex:row];
}

@end
