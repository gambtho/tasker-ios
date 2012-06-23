//
//  DatePickerViewController.m
//  tasker
//
//  Created by Thomas Gamble on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DatePickerViewController.h"

@implementation DatePickerViewController

@synthesize datePicker;
@synthesize dateButton;
@synthesize date;
@synthesize delegate;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setDatePicker:nil];
    [self setDateButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self.datePicker setDate:self.date animated:YES];
    
}

-(void)cancel
{
    [self.delegate datePickerDidCancel:self];
}

-(void)done
{
    [self.delegate datePicker:self didPickDate:self.date];
}

-(void)dateChanged
{
    self.date = [self.datePicker date];
}
@end
