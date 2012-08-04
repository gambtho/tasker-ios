//
//  AppDelegate.m
//  tasker
//
//  Created by Thomas Gamble on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "TasksViewController.h"
#import "Task.h"
#import "MappingProvider.h"
#import <RestKit/RestKit.h>
#import "DDASLLogger.h"
#import "DDTTYLogger.h"

@interface AppDelegate ()
@property (nonatomic, strong) RKObjectManager *objectManager;
@property (nonatomic, strong) RKManagedObjectStore *objectStore;
@property (nonatomic, strong) NSManagedObjectContext *objectContext;
@end

@implementation AppDelegate

static const int ddLogLevel = LOG_LEVEL_INFO;

@synthesize window = _window;
@synthesize objectManager, objectStore, objectContext;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self testFlightSetup];
    [self restKitSetup];
    [self setupLogging];
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    TasksViewController *taskViewController = (TasksViewController *)[[navigationController viewControllers] objectAtIndex:0];
    taskViewController.objectManager = self.objectManager;
    taskViewController.managedObjectContext = self.objectContext;
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [TestFlight passCheckpoint:@"APPLICATION WENT TO BACKGROUND"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [TestFlight passCheckpoint:@"APPLICATION WENT TO FOREGROUND"];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [TestFlight passCheckpoint:@"CLOSED APPLICATION"];
}

-(void)fatalCoreDataError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Internal Error", nil) message:@"There was a fatal error in the app and it cannot continue" delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [TestFlight passCheckpoint:@"CORE DATA ERROR"];
    [alertView show];
    
}

#pragma mark - TestFlight

-(void)testFlightSetup
{
    #if DEBUG
        [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
        [TestFlight passCheckpoint:@"SET DEVICE IDENTIFIER"];
    #endif
    [TestFlight takeOff:TF_ID];
    [TestFlight passCheckpoint:@"LAUNCHED APPLICATION"];
}

#pragma mark - RestKit

-(void)restKitSetup
{
    
    //RKLogConfigureByName("RestKit/*", RKLogLevelTrace);

    self.objectManager = [RKObjectManager managerWithBaseURLString:HOST];
    self.objectManager.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
    self.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:DB_NAME];
    self.objectManager.objectStore = self.objectStore;
    self.objectManager.mappingProvider = [MappingProvider mappingProviderWithObjectStore:self.objectStore];
    self.objectContext = self.objectStore.managedObjectContextForCurrentThread;
    
}

#pragma mark - Cocoa Lumberjack

-(void)setupLogging
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}

#pragma mark - AlertView Delegate

-(void)alertView:(UIAlertView *)theAlertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    abort();
}

@end
