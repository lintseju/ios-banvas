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
    for(ZBarSymbol *sym in syms){
        //check url
        //NSLog(@"%@", sym.data);
        //ckeck url
        break;
    }
    BACardViewController *card = [[BACardViewController alloc] init];
    [self.navigationController pushViewController:card animated:YES];
}

@end
