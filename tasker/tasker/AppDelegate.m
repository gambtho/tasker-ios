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
#import <RestKit/RestKit.h>

@interface AppDelegate ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) RKObjectManager *objectManager;
@property (nonatomic, strong) RKManagedObjectMapping *taskMapping;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext, managedObjectModel, persistentStoreCoordinator, objectManager, taskMapping;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self testFlightSetup];
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    TasksViewController *taskViewController = (TasksViewController *)[[navigationController viewControllers] objectAtIndex:0];
    taskViewController.managedObjectContext = self.managedObjectContext;
    taskViewController.objectManager = self.objectManager;

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
    //remove the next line before release...and the compiler setting under target build phases
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    [TestFlight takeOff:@"bee96b8435ae376fc15786c7c99c64fe_OTgwMzIyMDEyLTA2LTI0IDE0OjQ1OjU4LjA5MDMzMw"];
    [TestFlight passCheckpoint:@"LAUNCHED APPLICATION"];
}

#pragma mark - RestKit

- (RKObjectManager *)objectManager
{
    if(objectManager == nil)
    {
        
        NSString *seedDatabaseName = nil;
        NSString *databaseName = RKDefaultSeedDatabaseFileName;
        
        // Initialize RestKit
        objectManager = [RKObjectManager managerWithBaseURLString:@"http://localhost:8888/"];
        
        // Enable automatic network activity indicator management
        objectManager.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
        
        objectManager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:databaseName usingSeedDatabaseName:seedDatabaseName managedObjectModel:nil delegate:self]; 
        NSLog(@"object store created");
        [objectManager.mappingProvider setObjectMapping:[self taskMapping] forResourcePathPattern:@"/tasker/task"];
    }
    return objectManager;
}

-(RKManagedObjectMapping *)taskMapping
{
    NSLog(@"creating taskMapping");
    if(taskMapping == nil)
    {
        taskMapping = [RKManagedObjectMapping mappingForClass:[Task class] inManagedObjectStore:objectManager.objectStore];
        taskMapping.primaryKeyAttribute = @"taskID";
        [taskMapping mapKeyPath:@"id" toAttribute:@"taskID"];
        [taskMapping mapKeyPath:@"title" toAttribute:@"title"];
        [taskMapping mapKeyPath:@"creator" toAttribute:@"creator"];
        [taskMapping mapKeyPath:@"createDate" toAttribute:@"createDate"];
    }
    return taskMapping;
}

#pragma mark - AlertView Delegate

-(void)alertView:(UIAlertView *)theAlertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    abort();
}

#pragma mark - Core Data

- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel == nil) {
        NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"DataModel" ofType:@"momd"];
        NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
        managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return managedObjectModel;
}

- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (NSString *)dataStorePath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"DataStore.sqlite"];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator == nil) {
        NSURL *storeURL = [NSURL fileURLWithPath:[self dataStorePath]];
        
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSError *error;
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NSLog(@"Error adding persistent store %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext == nil) {
        NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
        if (coordinator != nil) {
            managedObjectContext = [[NSManagedObjectContext alloc] init];
            [managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return managedObjectContext;
}



@end
