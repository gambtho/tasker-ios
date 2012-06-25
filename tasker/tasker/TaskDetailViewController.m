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

@implementation TaskDetailViewController{
    NSDate *dueDate;
    NSNumber *beforePhotoId;
    UIImage *image;
    NSString *title;
    NSString *description;
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


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)showImage:(UIImage *)theImage
{
    self.imageView.image = theImage;
    self.imageView.hidden = NO;
    self.imageView.frame = CGRectMake(10, 10, 260, 260);
    self.photoLabel.hidden = YES;
}

-(void)updateNavBar 
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
            self.assignCell.textLabel.text = self.taskToEdit.completor;
            [self.assignCell setAccessoryType:UITableViewCellAccessoryNone];
            [self.titleField setEnabled:FALSE];
            [self.descriptionTextView setEditable:FALSE];
        }
        else {
            self.title =@"Edit Task";
            self.doneBarButton.enabled = YES;
        }
    } 
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    [TestFlight passCheckpoint:@"LOADED TASK DETAIL"];
    user = [[NSString alloc] initWithFormat:@"Current User"];
    status = [[NSString alloc] initWithFormat:@"new"];
    if(taskToEdit!=nil)
    {
        [self updateNavBar];
        status = taskToEdit.status;
    }
    
    if(image != nil) {
        [self showImage:image];
    }
    
    self.titleField.text = title;
    self.descriptionTextView.text = description;
    
    if(dueDate != nil) {
        [self updateDueDateLabel];
    }
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
}

-(void)setTaskToEdit:(Task *)theTaskToEdit
{
    if(taskToEdit != theTaskToEdit) {
        taskToEdit = theTaskToEdit;
        
        title = taskToEdit.title;
        description = taskToEdit.taskDescription;
        if([taskToEdit hasBeforePhoto]) {
            UIImage *existingImage = [taskToEdit photoImage:[taskToEdit.beforePhotoId intValue]];
            if(existingImage!=nil) {
                existingImage = [existingImage resizedImageWithBounds:CGSizeMake(260, 260)];
                image = existingImage;
            }
        }
        dueDate = taskToEdit.dueDate;
    } 
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

-(void)updateDueDateLabel
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    self.dueDateLabel.text = [formatter stringFromDate:dueDate];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)complete:(id)sender
{
    status = [[NSString alloc] initWithFormat:@"complete"];
    
    taskToEdit.completedDate = [NSDate date];
    
    [TestFlight passCheckpoint:@"COMPLETED TASK"];
    
    [self done:sender];
}

-(void)assign
{
    status = [[NSString alloc] initWithFormat:@"assigned"];
    completor = user;
    
    [TestFlight passCheckpoint:@"ASSIGNED TASK"];
    
    [self done:self];
}

-(IBAction)cancel:(id)sender
{
//    [self.delegate addTaskViewControllerDidCancel:self];
    [self.presentingViewController  dismissViewControllerAnimated:YES completion:nil];
    
    [TestFlight passCheckpoint:@"CANCELLED TASK DETAIL"];
    
}

- (int)nextPhotoId
{
    int photoId = [[NSUserDefaults standardUserDefaults] integerForKey:@"PhotoID"];
    [[NSUserDefaults standardUserDefaults] setInteger:photoId+1 forKey:@"PhotoID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return photoId;
}

-(IBAction)done:(id)sender
{
    Task *task = nil;
        
    if(self.taskToEdit !=nil) {
        task = self.taskToEdit;
    } else {
        task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:managedObjectContext];
        task.createDate = [NSDate date];
        task.beforePhotoId = [NSNumber numberWithInt:-1];
        task.status = status;
        [TestFlight passCheckpoint:@"ADDED TASK"];
    }
    
    task.title = self.titleField.text;
    task.taskDescription = self.descriptionTextView.text;
    task.dueDate = dueDate;
    task.status = status;
    task.completor = completor;
        
    if(image != nil) {
        if(![task hasBeforePhoto]){
            task.beforePhotoId = [NSNumber numberWithInt:[self nextPhotoId]];
        }
                                  
      NSData *data = UIImagePNGRepresentation(image);
      NSError *error;
    if (![data writeToFile:[task photoPath:[task.beforePhotoId intValue]] options:NSDataWritingAtomic error:&error]) {
          NSLog(@"Error writing file: %@", error);
      }                          
    }
    
    NSError *error;
    if(![self.managedObjectContext save:&error]) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    
    [self.presentingViewController  dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)textDone:(id)sender
{
    [sender resignFirstResponder];
}


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

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *tempText = [titleField.text stringByReplacingCharactersInRange:range withString:string];
    self.doneBarButton.enabled = ([tempText length] > 0);
    return YES;
}

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
        [self showImage:image];
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

#pragma mark - Seque
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   
    if([segue.identifier isEqualToString:@"PickDate"]) {
        DatePickerViewController *controller = segue.destinationViewController;
        controller.delegate = self;
        controller.date = [NSDate date];
    }
    
/*    
    if([segue.identifier isEqualToString:@"AssignTask"]) {
        AssignmentViewController *controller = segue.destinationViewController;
        controller.delegate = self;
        controller.assignment = taskAssignee;
    }
 */
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
            [self assign];
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

@end
