//
//  TasksViewController.h
//  tasker
//
//  Created by Thomas Gamble on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskDetailViewController.h"
#import "LoginViewController.h"
#import <RestKit/Restkit.h>


@interface TasksViewController : UITableViewController <NSFetchedResultsControllerDelegate, LoginViewControllerDelegate, RKObjectLoaderDelegate,
    TaskDetailViewControllerDelegate>;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) RKObjectManager *objectManager;
@property (strong, nonatomic) NSString *userEmail;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *loginButton;



@end
