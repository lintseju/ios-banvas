//
//  BAScannerViewController.m
//  ios-banvas
//
//  Created by lintseju on 12/12/13.
//  Copyright (c) 2012年 lintseju. All rights reserved.
//

#import "BAScannerViewController.h"

@interface BAScannerViewController ()

@end

@implementation BAScannerViewController

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
    //[[self navigationController] setNavigationBarHidden:YES animated:YES];
    self.readerDelegate = self;
    self.showsZBarControls = NO;
    self.supportedOrientationsMask = ZBarOrientationMaskAll;
}

- (void)viewDidAppear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    id <NSFastEnumeration> syms = [info objectForKey: ZBarReaderControllerResults];
    NSArray *parsedData = [NSArray alloc];
    for(ZBarSymbol *sym in syms){
        //check url
        //NSLog(@"%@", sym.data);
        //ckeck url
        parsedData = [sym.data componentsSeparatedByString:@"/"];
        NSLog(@"QQQQ");
        NSLog(@"%@", [parsedData lastObject]);
        [[BADataSource data] createPersonByPersonID:[parsedData lastObject]];
        self.tabBarController.selectedIndex = 1;
        break;
    }
}

@end
