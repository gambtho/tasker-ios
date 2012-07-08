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

@interface TasksViewController ()

@end

@implementation TasksViewController{
    NSFetchedResultsController *fetchedResultsController;
}

@synthesize managedObjectContext;
@synthesize userEmail;
@synthesize addButton;
@synthesize loginButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

-(NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        [NSFetchedResultsController deleteCacheWithName:@"Tasks"];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"creator == %@", self.userEmail];
        [fetchRequest setPredicate:predicate];
       
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dueDate" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        [fetchRequest setFetchBatchSize:20];
        
        fetchedResultsController = [[NSFetchedResultsController alloc]
                                    initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Tasks"];
        fetchedResultsController.delegate = self;
    }
    return fetchedResultsController;
}

-(void)performFetch
{
    NSError *error;
    if(![self.fetchedResultsController performFetch:&error]) 
    {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.userEmail==nil) {
//        userEmail = @"Placeholder user";
        addButton.enabled = FALSE;
    }
//    [NSFetchedResultsController deleteCacheWithName:@"Tasks"];
    [self performFetch];
}

- (void)viewDidUnload
{
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
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
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
        image = [task photoImage:[task.beforePhotoId intValue]];
        if(image!=nil) {
            image = [image resizedImageWithBounds:CGSizeMake(60, 60)];
        }
    }
    taskCell.imageView.image = image;
    
    if([task isComplete]) {
        taskCell.completeCheck.hidden = NO;
    }
    else {
        taskCell.completeCheck.hidden = YES;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
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
    
    if([segue.identifier isEqualToString:@"AddTask"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        TaskDetailViewController *controller = (TaskDetailViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
        controller.userEmail = self.userEmail;
    }
     
    if([segue.identifier isEqualToString:@"Login"]) {
        self.userEmail = nil;
        self.loginButton.title = @"Login";
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
    
    self.userEmail = theUserEmail;
    [self dismissModalViewControllerAnimated:YES];
    
    [NSFetchedResultsController deleteCacheWithName:@"Tasks"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"creator == %@", self.userEmail];
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    
    [self performFetch];
    [self.tableView reloadData];
    
    [TestFlight passCheckpoint:@"SUCCESFUL LOGIN"];
    
}

-(void)loginCancelled:(LoginViewController *)login
{
    [self dismissModalViewControllerAnimated:NO];
    
    [NSFetchedResultsController deleteCacheWithName:@"Tasks"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"creator == %@", self.userEmail];
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    
    [self performFetch];
    [self.tableView reloadData];
    [TestFlight passCheckpoint:@"CANCELLED LOGIN"];
}

@end
