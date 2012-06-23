//
//  AddTaskViewController.h
//  tasker
//
//  Created by Thomas Gamble on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatePickerViewController.h"

@class Task;
@class AddTaskViewController;


@protocol AddTaskViewControllerDelegate <NSObject>
-(void)addTaskViewControllerDidCancel:(AddTaskViewController *)controller;
-(void)addTaskViewController:(AddTaskViewController *)controller didFinishAddingItem:(Task *)task;
@end

@interface AddTaskViewController : UITableViewController <UITextFieldDelegate, DatePickerViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (strong, nonatomic) IBOutlet UITextField *titleField;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
@property (strong, nonatomic) Task *taskToAdd;
@property (weak, nonatomic) id <AddTaskViewControllerDelegate> delegate;

-(IBAction)cancel:(id)sender;
-(IBAction)done:(id)sender;
-(IBAction)textDone:(id)sender;

@end
