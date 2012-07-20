//
//  FriendSelectViewController.h
//  tasker
//
//  Created by Thomas Gamble on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FriendSelectViewController;

@protocol FriendSelectViewControllerDelegate <NSObject>
- (void)FriendSelectDidCancel:(FriendSelectViewController *)selector;
- (void)friendSelect:(FriendSelectViewController *)selector didSelectFriend:(NSString *)emailAddress;
@end


@interface FriendSelectViewController : UIViewController <UITextFieldDelegate>


@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) NSString *emailAddress;
- (IBAction)emailDone:(id)sender;
- (IBAction)emailCancel:(id)sender;

@property (nonatomic, weak) id <FriendSelectViewControllerDelegate> delegate;


@end
