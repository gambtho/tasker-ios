//
//  AddTaskViewController.h
//  tasker
//
//  Created by Thomas Gamble on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatePickerViewController.h"
#import <RestKit/Restkit.h>
#import "FriendSelectViewController.h"

@class Task;
@class TaskDetailViewController;

@protocol TaskDetailViewControllerDelegate <NSObject>
- (void)taskDetailCompleted:(TaskDetailViewController *)taskDetail;
- (void)taskDetailCancelled:(TaskDetailViewController *)taskDetail;
@end

@interface TaskDetailViewController : UITableViewController 
    <UITextFieldDelegate, 
    DatePickerViewControllerDelegate,   
    FriendSelectViewControllerDelegate,
    UIImagePickerControllerDelegate, 
    UIActionSheetDelegate,
    UINavigationControllerDelegate,
    RKObjectLoaderDelegate>
@property (strong, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (strong, nonatomic) IBOutlet UITextField *titleField;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) RKObjectManager *objectManager;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *photoLabel;
@property (strong, nonatomic) Task *taskToEdit;
@property (strong, nonatomic) IBOutlet UITableViewCell *assignCell;

@property (strong, nonatomic) NSString *userEmail;

@property (weak, nonatomic) id <TaskDetailViewControllerDelegate> delegate;

-(IBAction)cancel:(id)sender;
-(IBAction)done:(id)sender;
-(IBAction)textDone:(id)sender;
-(IBAction)complete:(id)sender;

@end
