//
//  FriendSelectViewController.m
//  tasker
//
//  Created by Thomas Gamble on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendSelectViewController.h"

@interface FriendSelectViewController ()

@end

@implementation FriendSelectViewController

@synthesize delegate;
@synthesize emailAddress;
@synthesize emailField;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [emailField setDelegate:self];
}

- (void)viewDidUnload
{
    [self setEmailField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self.emailField.text length] == 0) {
        [self.emailField becomeFirstResponder];
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)emailDone:(id)sender {
    emailAddress = emailField.text;
    [self.delegate friendSelect:self didSelectFriend:emailAddress];
}

- (IBAction)emailCancel:(id)sender {
    [self.delegate FriendSelectDidCancel:self];
}

@end
