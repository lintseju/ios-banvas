//
//  BATagUpdateViewController.h
//  ios-banvas
//
//  Created by lintseju on 12/12/13.
//  Copyright (c) 2012年 lintseju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BADataSource.h"

@interface BATagUpdateViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *textInput;
@property (strong, nonatomic) IBOutlet UIPickerView *colorSelect;
@property (strong, nonatomic) NSString *tagName;

+ (UIColor*)getColorByIndex:(NSInteger)colorListIndex;

- (IBAction)buttonTouched:(id)sender;

@end
