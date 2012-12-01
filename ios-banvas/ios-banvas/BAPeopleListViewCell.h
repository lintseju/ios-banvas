//
//  BAPeopleListViewCell.h
//  ios-banvas
//
//  Created by lintseju on 12/12/1.
//  Copyright (c) 2012年 lintseju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BAPeopleListViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *coloredTag;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *thumbnailView;

@end
