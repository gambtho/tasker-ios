//
//  AddTaskViewController.m
//  tasker
//
//  Created by Thomas Gamble on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TaskDetailViewController.h"
#import "Task.h"
#import "UIImage+Resize.h"
#import "UITableViewController+NextPhotoId.h"
#import "UITableViewController+DateString.h"

@implementation TaskDetailViewController{
    NSDate *dueDate;
    NSDate *completedDate;
    NSNumber *beforePhotoId;
    UIImage *image;
    NSString *taskTitle;
    NSString *taskDescription;
    NSString *user;
    NSString *status;
    NSString *completor;
}
@synthesize dueDateLabel;
@synthesize titleField;
@synthesize descriptionTextView;
@synthesize doneBarButton;
@synthesize managedObjectContext;
@synthesize imageView;
@synthesize photoLabel;
@synthesize taskToEdit;
@synthesize assignCell;
@synthesize userEmail;
@synthesize objectManager;
@synthesize delegate;
@synthesize taskEdit;

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    [TestFlight passCheckpoint:@"LOADED TASK DETAIL"];
    
    [self configUI];
    [self configGestures];
}
 
- (void)viewDidUnload
{
    [self setTitleField:nil];
    [self setDescriptionTextView:nil];
    [self setDoneBarButton:nil];
    [self setDueDateLabel:nil];
    [self setImageView:nil];
    [self setPhotoLabel:nil];
    
    [self setAssignCell:nil];
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self.titleField.text length] == 0) {
           [self.titleField becomeFirstResponder];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)complete:(id)sender
{
    status = [[NSString alloc] initWithFormat:@"complete"];
    
    completedDate = [NSDate date];
    
    [TestFlight passCheckpoint:@"COMPLETED TASK"];
    
    [self done:sender];
}

-(void)assign:(NSString *)email
{
    status = [[NSString alloc] initWithFormat:@"assigned"];
    
    completor = email;
    DDLogVerbose(@"Completor is %@", completor);

    [TestFlight passCheckpoint:@"ASSIGNED TASK"];
    
    [self dismissModalViewControllerAnimated:NO];
    
    [self done:nil];
}

-(IBAction)cancel:(id)sender
{
    [self.delegate taskDetailCancelled:self];
    
    
    [TestFlight passCheckpoint:@"CANCELLED TASK DETAIL"];
    
}


-(IBAction)done:(id)sender
{
    Task *task;
    RKRequestMethod method;
    
    if(self.taskEdit==TRUE)
    {
        task = taskToEdit;
        method = RKRequestMethodPOST;
    }
    else {
        task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:managedObjectContext];
        method = RKRequestMethodPUT;
        task.taskID = [NSNumber numberWithInt:0];
        task.creator = user;
        task.beforePhotoId = [NSNumber numberWithInt:-1];
        
        [TestFlight passCheckpoint:@"ADDED TASK"];
    }
    
    if(image != nil) {
        if(![task hasBeforePhoto]){
            task.beforePhotoId = [NSNumber numberWithInt:[self nextPhotoId]];
            DDLogVerbose(@"Saving photo with id: %@", task.beforePhotoId);
        }
        
        NSData *data = UIImagePNGRepresentation(image);
        
        NSError *error;
        if (![data writeToFile:[task photoPath:task.beforePhotoId]   options:NSDataWritingAtomic error:&error]) {
            DDLogError(@"Error writing file: %@", error);
        }
    }
    
    task.title = self.titleField.text;
    task.taskDescription = self.descriptionTextView.text;
    task.dueDate = dueDate;
    task.status = status;
    task.completor = completor;
    task.completedDate = completedDate;
    
//    [self sendTask:task withMethod:method];
    
    [self.delegate taskDetailCompleted:self forTask:task updateMethod:method];

    DDLogVerbose(@"End of done in task detail");
    
}


#pragma photo methods

-(void)choosePhotoFromLibrary
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}

-(void)takePhoto
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}

-(void)showPhotoMenu
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"TakePhoto", @"Choose From Library", nil];
        [actionSheet showInView:self.view];
    }
    else {
        [self choosePhotoFromLibrary];
    }
}

#pragma mark - Image Picker delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if ([self isViewLoaded]) {
        [self showImage];
        [self.tableView reloadData];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DatePicker

-(void)datePickerDidCancel:(DatePickerViewController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)datePicker:(DatePickerViewController *)picker didPickDate:(NSDate *)date
{
    dueDate = date;
    [self updateDueDateLabel];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Friend Select

-(void)friendSelect:(FriendSelectViewController *)selector didSelectFriend:(NSString *)emailAddress
{
    [self assign:emailAddress];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)FriendSelectDidCancel:(FriendSelectViewController *)selector
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Seque
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   
    if([segue.identifier isEqualToString:@"PickDate"]) {
        DatePickerViewController *controller = segue.destinationViewController;
        controller.delegate = self;
        controller.date = [NSDate date];
    }
        
    if([segue.identifier isEqualToString:@"AssignTask"]) {
        FriendSelectViewController *controller = segue.destinationViewController;
        controller.delegate = self;
        controller.emailField.text = completor;
    }
}



#pragma mark - Action Sheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        [self takePhoto];
    } 
    
    else if (buttonIndex == 1) {
        [self choosePhotoFromLibrary];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if((![taskToEdit isComplete]) && (![taskToEdit isAssigned])) {
        if(indexPath.section == 0 && indexPath.row == 0) {
            [self.titleField becomeFirstResponder];
        }
        else if (indexPath.section == 1 && indexPath.row == 0) {
            [self.descriptionTextView becomeFirstResponder];    
        }
        else if (indexPath.section == 1 && indexPath.row == 1){
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self showPhotoMenu];
        }
        else if (indexPath.section == 2 && indexPath.row == 0){
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
//            [self assign];
        }
    }

}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   //  && (indexPath.section == 2)
    if(([self.taskToEdit isComplete] || [self.taskToEdit isAssigned]))
    {
        return nil;
    }
    else {
        return indexPath;
    }
}


- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        return 88;
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        if (self.imageView.hidden) {
            return 44;
        } else {
            return 280;
        }
    } else {
        return 44;
    }  
}

#pragma text related

-(IBAction)textDone:(id)sender
{
    [sender resignFirstResponder];
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *tempText = [titleField.text stringByReplacingCharactersInRange:range withString:string];
    self.doneBarButton.enabled = ([tempText length] > 0);
    return YES;
}

#pragma gesture

-(void)hideKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if(self.descriptionTextView.isFirstResponder) {
        if(indexPath !=nil && indexPath.section == 1 && indexPath.row == 0)
        {
            return;
        }
        
        [self.descriptionTextView resignFirstResponder];
    }
    else if(self.titleField.isFirstResponder) {
        if(indexPath !=nil && indexPath.section == 0 && indexPath.row == 0)
        {
            return;
        }
        [self.titleField resignFirstResponder];
    }
}


#pragma Update Remote

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    DDLogError(@"Error: %@", [error localizedDescription]);
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    DDLogVerbose(@"response code: %d", [response statusCode]);
    DDLogInfo(@"response is: %@", [response bodyAsString]);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    DDLogVerbose(@"objects[%d]", [objects count]);
    
    DDLogVerbose(@"Completed object load in task detail");
    
}

-(void)objectLoaderDidFinishLoading:(RKObjectLoader *)objectLoader
{
    DDLogVerbose(@"Completed loading in task detail");
    [self.delegate taskDetailCompleted:self];
}


-(void)sendTask:(Task *)task withMethod:(RKRequestMethod)method {
    
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 task.title, @"title",
                                 task.creator, @"creator",
                                 task.status, @"status",
                                 task.completor, @"completor",
                                 task.taskID, @"taskID",
                                 task.taskDescription, @"taskDescription",
                                 task.dueDate, @"dueDate",
                                 task.completedDate, @"completedDate",
                                 nil];
    NSString *resourcePath = [TASK_PATH stringByAppendingQueryParameters:queryParams];
    DDLogInfo(@"%@", resourcePath);
    [objectManager loadObjectsAtResourcePath:resourcePath usingBlock:^(RKObjectLoader *loader) {
        loader.delegate = self;
        loader.method = method;
        loader.targetObject = task;
        
        if((image!=nil) && (task.beforePhotoUrl==nil))
        {
            DDLogInfo(@"Trying to send image");
            RKParams *params = [RKParams params];
            NSData *data = UIImagePNGRepresentation(image);
            [params setData:data MIMEType:@"image/png" forParam:@"beforeimage"];
            loader.params = params;
        }
    }];
    
}


#pragma Utility Methods / UI Setup

-(void)showImage
{
    if(image!=nil)
    {
        self.imageView.image = image;
        self.imageView.hidden = NO;
        self.imageView.frame = CGRectMake(10, 10, 260, 260);
        self.photoLabel.hidden = YES;
    }
}

-(void)configUI
{
    if(taskToEdit != nil) {
        
        
        
        if([taskToEdit isComplete])
        {
            self.title = @"View Completed Task";
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                     initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
            self.doneBarButton.enabled = FALSE;
            self.assignCell.textLabel.text = self.taskToEdit.completor;
            [self.assignCell setAccessoryType:UITableViewCellAccessoryNone];
            [self.titleField setEnabled:FALSE];
            [self.descriptionTextView setEditable:FALSE];
        }
        else if([taskToEdit isAssigned]) {
            self.title = @"View Task";
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                     initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                      initWithTitle:@"Complete!" style:UIBarButtonItemStyleBordered target:self action:@selector(complete:)];
            self.assignCell.textLabel.text = completor;
            [self.assignCell setAccessoryType:UITableViewCellAccessoryNone];
            [self.titleField setEnabled:FALSE];
            [self.descriptionTextView setEditable:FALSE];
        }
        else {
            self.title =@"Edit Task";
            self.doneBarButton.enabled = YES;
        }
    }
    else {
        status = [[NSString alloc] initWithFormat:@"new"];
    }
    
    self.titleField.text = taskTitle;
    self.descriptionTextView.text = taskDescription;
    
    NSAssert(self.userEmail!=nil, @"In task detail without valid user");
    user = self.userEmail;
    
    if(completor==nil)
    {
        completor = user;
    }
    
    [self showImage];
    
    [self updateDueDateLabel];
    
    
    
}

-(void)updateDueDateLabel
{
    if(dueDate!=nil)
    {
        self.dueDateLabel.text = [self getDateString:dueDate];
    }
}

-(void)configGestures {
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
}

-(void)setTaskToEdit:(Task *)task
{
    DDLogInfo(@"Setting task to edit");
    
    if(self.taskToEdit != task) {
        taskToEdit = task;
        taskTitle = taskToEdit.title;
        taskDescription = taskToEdit.taskDescription;
        dueDate = taskToEdit.dueDate;
        completedDate = taskToEdit.completedDate;
        completor = taskToEdit.completor;
        beforePhotoId = taskToEdit.beforePhotoId;
        status = taskToEdit.status;
        
        if([taskToEdit hasBeforePhoto]) {
            UIImage *existingImage = [taskToEdit photoImage:taskToEdit.beforePhotoId];
            if(existingImage!=nil) {
                existingImage = [existingImage resizedImageWithBounds:CGSizeMake(260, 260)];
                image = existingImage;
            }
        }
        
    }
    else {
        DDLogWarn(@"TasktoEdit set to existing value");
    }
}

@end
