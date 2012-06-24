//
//  TasksViewController.h
//  tasker
//
//  Created by Thomas Gamble on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddTaskViewController.h"

@interface TasksViewController : UITableViewController <AddTaskViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
