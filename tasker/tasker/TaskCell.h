//
//  TaskCell.h
//  tasker
//
//  Created by Thomas Gamble on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *dueDate;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;


@end
