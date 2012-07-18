//
//  LoginViewController.h
//  tasker
//
//  Created by Thomas Gamble on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LoginViewController;

@protocol LoginViewControllerDelegate <NSObject>
- (void)loginCompleted:(LoginViewController *)login didLogin:(NSString *)userEmail;
- (void)loginCancelled:(LoginViewController *)login;
@end

@interface LoginViewController : UIViewController <UINavigationControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *accessToken;
@property (weak, nonatomic) id <LoginViewControllerDelegate> delegate;

- (IBAction)googleLogin:(id)sender;
- (IBAction)didCancel:(id)sender;

@end
