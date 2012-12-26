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
    if(self.personName != nil){
        self.navigationItem.title = @"重新分類";
        self.textInput.text = self.personName;
        self.textInput.enabled = false;
    }
    self.textInput.returnKeyType = UIReturnKeyDone;
    self.textInput.delegate = self;
    self.colorSelect.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTextInput:nil];
    [self setColorSelect:nil];
    [self setButtonNew:nil];
    [self setButtonCancel:nil];
    [super viewDidUnload];
}

- (IBAction)buttonTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:TRUE];
    UIButton* senderButton = (UIButton*)sender;
    //好
    if(senderButton.tag == 1 && self.personName == nil){
        UIColor *tagColorNow = [BATagUpdateViewController getColorByIndex:[self.colorSelect selectedRowInComponent:0]];
        if([self.textInput.text length] > 0)
            [[BADataSource data] addCategory:self.textInput.text andColor:tagColorNow];
    }else if(senderButton.tag == 1){
        NSString *newTag = [[[BADataSource data] getTagList] objectAtIndex:[self.colorSelect selectedRowInComponent:0]];
        [[BADataSource data] updatePersonByPersonID:self.personID andTag:newTag];
    }
    //NSLog(@"%@", [[BADataSource data] getTagList]);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma For UIPickerView Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(self.personName != nil){
        return [[[BADataSource data] getTagList] count];
        //return [[BADataSource getTagList] count];
    }
    return [colorList count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(self.personName != nil){
        return [[[BADataSource data] getTagList] objectAtIndex:row];
        //return [[BADataSource getTagList] objectAtIndex:row];
    }
//    NSLog(@"%d", [pickerView selectedRowInComponent:0]);
//    CIImage *selector = [[[CIImage alloc] initWithColor:(CIColor*)[BATagUpdateViewController getColorByIndex:component]]];
    return [colorList objectAtIndex:row];
}

//UIImage *X = [UIImage alloc]initWithFrame: CGRectMake(, , , , )

@end
