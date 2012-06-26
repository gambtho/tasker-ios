//
//  DatePickerViewController.h
//  tasker
//
//  Created by Thomas Gamble on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DatePickerViewController;

@protocol DatePickerViewControllerDelegate <NSObject>
- (void)datePickerDidCancel:(DatePickerViewController *)picker;
- (void)datePicker:(DatePickerViewController *)picker didPickDate:(NSDate *)date;
@end


@interface DatePickerViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIButton *dateButton;
@property (strong, nonatomic) NSDate *date;
@property (nonatomic, weak) id <DatePickerViewControllerDelegate> delegate;

-(IBAction)cancel;
-(IBAction)done;
-(IBAction)dateChanged;

@end
