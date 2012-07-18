//
//  LoginViewController.m
//  tasker
//
//  Created by Thomas Gamble on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMHTTPFetcherLogging.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize managedObjectContext;
@synthesize accessToken;
@synthesize delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [TestFlight passCheckpoint:@"LOADED LOGIN SCREEN"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setAccessToken:nil];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)googleLogin:(id)sender
{    
    [GTMHTTPFetcher setLoggingEnabled:YES];
    
    static NSString *const kKeychainItemName = @"Tasker: Google Auth";
    
    NSString *kMyClientID = @"340027406247.apps.googleusercontent.com";     // pre-assigned by service
    NSString *kMyClientSecret = @"AR0hLFuzc7fL5vu23vTD7MBw"; // pre-assigned by service
    
    NSString *scope = @"https://www.googleapis.com/auth/plus.me"; // scope for Google+ API
    
    
    
    
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope
                                                                 clientID:kMyClientID
                                                             clientSecret:kMyClientSecret
                                                         keychainItemName:kKeychainItemName
                                                                 delegate:self
                                                         finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    [[self navigationController] pushViewController:viewController
                                           animated:YES];
}

- (IBAction)didCancel:(id)sender {
    [self.delegate loginCancelled:self];
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        // Authentication failed (perhaps the user denied access, or closed the
        // window before granting access)
        NSLog(@"Authentication error: %@", error);
        NSData *responseData = [[error userInfo] objectForKey:@"data"]; // kGTMHTTPFetcherStatusDataKey
        if ([responseData length] > 0) {
            // show the body of the server's authentication failure response
            NSString *str = [[NSString alloc] initWithData:responseData
                                                   encoding:NSUTF8StringEncoding];
            NSLog(@"%@", str);
        }
        
    } else {

        self.accessToken = auth.userEmail;
        NSLog(@"Email: %@", self.accessToken);
        [self.delegate loginCompleted:self didLogin:auth.userEmail];
    }
    
}
@end
