//
//  TasksViewController.m
//  tasker
//
//  Created by Thomas Gamble on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TasksViewController.h"
#import "TaskCell.h"
#import "Task.h"
#import "UIImage+Resize.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface TasksViewController ()
{
    BOOL needRefresh;
}

@end

@implementation TasksViewController{
    NSFetchedResultsController *fetchedResultsController;
}

@synthesize managedObjectContext;
@synthesize userEmail;
@synthesize addButton;
@synthesize loginButton;
@synthesize objectManager;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (int)nextPhotoId
{
    int photoId = [[NSUserDefaults standardUserDefaults] integerForKey:@"PhotoID"];
    NSLog(@"Photo Id is currently: %d", photoId);
    [[NSUserDefaults standardUserDefaults] setInteger:photoId+1 forKey:@"PhotoID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return photoId;
}

-(NSFetchedResultsController *)fetchedResultsController
{
    NSLog(@"Getting fetched results controller");
    if (fetchedResultsController == nil) {
                
        NSFetchRequest *fetchRequest = [[[RKObjectManager sharedManager] 
                                         mappingProvider] fetchRequestForResourcePath:@"/tasker/task"]; 
        
        [NSFetchedResultsController deleteCacheWithName:@"Tasks"]; 
    
/*        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];

        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dueDate" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
*/      
        [fetchRequest setFetchBatchSize:20];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completor == %@", self.userEmail];   
        [fetchRequest setPredicate:predicate];
        
        fetchedResultsController = [[NSFetchedResultsController alloc]
                                    initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Tasks"];
        
        fetchedResultsController.delegate = self;
    }
    return fetchedResultsController;
}


-(void)getTasks
{
    NSLog(@"Getting tasks");
    if(userEmail!=nil)
    {
        NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:self.userEmail, @"user", nil];
        NSString *resourcePath = [@"/tasker/task" stringByAppendingQueryParameters:queryParams];
        NSLog(@"%@", resourcePath);
        [objectManager loadObjectsAtResourcePath:resourcePath delegate:self]; 
    }
}

-(void)performFetch
{
    NSLog(@"Performing fetch");
    NSError *error;
    if(![self.fetchedResultsController performFetch:&error]) 
    {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    else{
        NSLog(@"Fetch succesful");
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
        NSLog(@"Number objects fetched: %d", [sectionInfo numberOfObjects]);
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSLog(@"response code: %d", [response statusCode]);
//    NSLog(@"response is: %@", [response bodyAsString]);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{

    NSLog(@"Objectloader loaded objects[%d]", [objects count]);
/*

 -(void)imageDownloader:(SDWebImageDownloader *)downloader didFailWithError:(NSError *)error
 {
 NSLog(@"Image download failed with error: %@", [error localizedDescription]);
 }
 
 -(void)imageDownloader:(SDWebImageDownloader *)downloader didFinishWithImage:(UIImage *)image
 {
 //
 }
 
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    for(Task *task in objects)
    {
        NSLog(@"First item: %@", task.taskID);
        UIImage *image = nil;
        if([task hasBeforePhoto]) {
            image = [task photoImage:task.beforePhotoId];
            if(image==nil) {
                NSLog(@"task url is: %@", task.beforePhotoUrl.absoluteString);
      //          NSURL *url = [[NSURL alloc] initWithString:task.beforePhotoId];
                NSString *tempString = [NSString stringWithFormat:@"http://localhost:8888%@", task.beforePhotoUrl.path];
                NSLog(@"%@", tempString);
                NSURL *url = [[NSURL alloc] initWithString:tempString];
                [manager downloadWithURL:url
                                delegate:self
                                 options:0
                                 success:^(UIImage *newImage)
                                 {
                                     NSLog(@"Succesfull image download");
                                     NSData *data = UIImagePNGRepresentation(newImage);
                                     
                                     NSError *errorP;
                                     if (![data writeToFile:[task photoPath:task.beforePhotoId] options:NSDataWritingAtomic error:&errorP]) {
                                         NSLog(@"Error writing file: %@", errorP);
                                     }
                                     else
                                     {
                                         needRefresh = TRUE;
                                     }
                                 }
                                 failure:^(NSError *error)
                                 {
                                     NSLog(@"Error downloading image: %@", [error localizedDescription]);
                                 }];
            }
            else{
                NSLog(@"Image already present");
            }
        
        }
    }
    if(needRefresh)
    {
        needRefresh = FALSE;
        [self.tableView reloadData];
    }
*/
}


-(void)objectLoaderDidFinishLoading:(RKObjectLoader *)objectLoader{
    //
}

- (void)viewDidLoad
{
    NSLog(@"View did load");
    
    self.userEmail = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserEmail"];

//    [NSFetchedResultsController deleteCacheWithName:@"Tasks"];
   
    needRefresh = FALSE;
    
    [self getTasks];
    
    [super viewDidLoad];
    
    if(self.userEmail == nil) {
        addButton.enabled = FALSE;
    }
    else {
        self.addButton.enabled = TRUE;
        self.loginButton.title = @"Logout"; 
    }
    
    [self performFetch];
}

- (void)viewDidUnload
{
    NSLog(@"View did unload");
    [self setAddButton:nil];
    [self setLoginButton:nil];
    [super viewDidUnload];
    
    fetchedResultsController.delegate = nil;
    fetchedResultsController = nil;    
    userEmail = nil;

}

-(void)dealloc
{
    fetchedResultsController.delegate = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*
-(IBAction)launchFeedback {
    [TestFlight openFeedbackView];
}
*/


#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Number of rows in section");
    if(userEmail==nil)
    {
        return 0;
    
    } else {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSLog(@"Number of objects is: %d", [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
    
    }
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Configuring cell");
    TaskCell *taskCell = (TaskCell *)cell;
    Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if([task.title length] > 0)
    {
        taskCell.title.text = task.title;
    } else {
        taskCell.title.text = @"No title";
    }
    
    if(task.dueDate!=nil)
    {
        taskCell.dueDate.text = [NSDateFormatter localizedStringFromDate:task.dueDate 
                                                  dateStyle:NSDateFormatterShortStyle 
                                                  timeStyle:NSDateFormatterNoStyle];
    } else {
        taskCell.dueDate.text = @" ";
    }
    
    UIImage *image = nil;
    if([task hasBeforePhoto]) {
        image = [task photoImage:task.beforePhotoId];
        if(image!=nil) {
            image = [image resizedImageWithBounds:CGSizeMake(60, 60)];
            taskCell.imageView.image = image;
        }
        else if(task.beforePhotoUrl==nil && task.beforePhotoId == 0)
        {
            NSLog(@"Resetting photoID");
            task.beforePhotoId = [NSNumber numberWithInt:-1];
            
        } else {
            NSString *tempString = [NSString stringWithFormat:@"http://localhost:8888%@", task.beforePhotoUrl.path];
            NSLog(@"%@", tempString);
            NSURL *url = [[NSURL alloc] initWithString:tempString];
            
            [taskCell.imageView setImageWithURL:url success:^(UIImage *newImage) {
                
                NSData *data = UIImagePNGRepresentation(newImage);
                taskCell.imageView.image = [taskCell.imageView.image resizedImageWithBounds:CGSizeMake(60, 60)];
               
                task.beforePhotoId = [NSNumber numberWithInt:[self nextPhotoId]];
                NSLog(@"Succesfull image download for photoID: %@", task.beforePhotoId);
                NSError *error;
                if (![data writeToFile:[task photoPath:task.beforePhotoId]   options:NSDataWritingAtomic error:&error]) {
                     NSLog(@"Error writing file: %@", error);
                }

            } failure:^(NSError *error) {
                    NSLog(@"Error downloading image: %@", [error localizedDescription]);
            }
            
            ];
            
        }
    }
    else{
        taskCell.imageView.image = nil;
    }
    
    if([task isComplete]) {
        taskCell.completeCheck.hidden = NO;
    }
    else {
        taskCell.completeCheck.hidden = YES;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Cell for row and index path");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Task"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

-(void)deleteRemote:(Task *)task {
    NSLog(@"Contacting server to delete %@", task.title);
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 task.taskID, @"taskID",
                                 nil];
    NSString *resourcePath = [@"/tasker/task" stringByAppendingQueryParameters:queryParams];
    
    [objectManager loadObjectsAtResourcePath:resourcePath usingBlock:^(RKObjectLoader *loader) {
        loader.delegate = self;
        loader.method = RKRequestMethodDELETE;
    }];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"User initiated delete");
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self deleteRemote:task];
        [task removePhotoFiles];
        [self.managedObjectContext deleteObject:task];
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            FATAL_CORE_DATA_ERROR(error);
            return;
        }
    }
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Preparing for seque");
    if([segue.identifier isEqualToString:@"AddTask"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        TaskDetailViewController *controller = (TaskDetailViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
        controller.objectManager = objectManager;
        controller.delegate = self;
        controller.userEmail = self.userEmail;
    }
     
    if([segue.identifier isEqualToString:@"Login"]) {
        self.userEmail = nil;
        self.loginButton.title = @"Login";
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"UserEmail"];
        UINavigationController *navigationController = segue.destinationViewController;
        LoginViewController *controller = (LoginViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
        
        controller.delegate = self;
    }
    
    if([segue.identifier isEqualToString:@"EditTask"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        TaskDetailViewController *controller = (TaskDetailViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
        controller.taskToEdit = task;
        controller.userEmail = self.userEmail;
        controller.objectManager = objectManager;
        controller.delegate = self;
    }

    // Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"*** controllerWillChangeContent");
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            NSLog(@"*** controllerDidChangeObject - NSFetchedResultsChangeInsert");
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"*** controllerDidChangeObject - NSFetchedResultsChangeDelete");
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"*** controllerDidChangeObject - NSFetchedResultsChangeUpdate");
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            NSLog(@"*** controllerDidChangeObject - NSFetchedResultsChangeMove");
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            NSLog(@"*** controllerDidChangeSection - NSFetchedResultsChangeInsert");
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"*** controllerDidChangeSection - NSFetchedResultsChangeDelete");
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"*** controllerDidChangeContent");
    [self.tableView endUpdates];
}


#pragma mark - Login Delegate

- (void)loginCompleted:(LoginViewController *)login didLogin:(NSString *)theUserEmail
{
    self.addButton.enabled = TRUE;
    self.loginButton.title = @"Logout";
    
    [[NSUserDefaults standardUserDefaults] setValue:theUserEmail forKey:@"UserEmail"];
    
    self.userEmail = theUserEmail;
    [self dismissModalViewControllerAnimated:NO];
    
    [NSFetchedResultsController deleteCacheWithName:@"Tasks"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completor == %@", self.userEmail];
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];

    [self getTasks];
    
    [self performFetch];
    
    [self.tableView reloadData];
    
    [TestFlight passCheckpoint:@"SUCCESFUL LOGIN"];
    
}

-(void)loginCancelled:(LoginViewController *)login
{
    [self dismissModalViewControllerAnimated:NO];
    
    [NSFetchedResultsController deleteCacheWithName:@"Tasks"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completor == %@", self.userEmail];
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];

//    [self performFetch];
    
    [self.tableView reloadData];
    
    [TestFlight passCheckpoint:@"CANCELLED LOGIN"];
}

#pragma mark - Task Detail Delegate

-(void)taskDetailCancelled:(TaskDetailViewController *)taskDetail 
{
   [self dismissModalViewControllerAnimated:NO];
}

-(void)taskDetailCompleted:(TaskDetailViewController *)taskDetail
{
    NSLog(@"Task detail completed");
    [self.tableView reloadData];
    [self dismissModalViewControllerAnimated:NO];
}

@end
