//
//  Task.m
//  tasker
//
//  Created by Thomas Gamble on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Task.h"


@implementation Task

@dynamic title;
@dynamic taskDescription;
@dynamic dueDate;
@dynamic completedDate;
@dynamic creator;
@dynamic completor;
@dynamic beforePhotoId;
@dynamic afterPhotoId;
@dynamic status;
@dynamic createDate;
@dynamic taskID;

-(BOOL)hasBeforePhoto
{
    return (self.beforePhotoId != nil) && ([self.beforePhotoId intValue] !=-1);
}

- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (NSString *)photoPath:(NSString *)photoId
{
    NSString *filename = [NSString stringWithFormat:@"Photo-%@.png", photoId];
    return [[self documentsDirectory] stringByAppendingPathComponent:filename];
}

- (UIImage *)photoImage:(NSString *)photoId
{
//    NSAssert(photoId != nil, @"No photo ID set");
    NSAssert(photoId != @"-1", @"Photo ID is -1");
    
    return [UIImage imageWithContentsOfFile:[self photoPath:photoId]];
}

-(void)removeFile:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error;
        if (![fileManager removeItemAtPath:path error:&error]) {
            NSLog(@"Error removing file: %@", error);
        }
    }
}

-(void)removePhotoFiles
{
    if([self hasBeforePhoto])
    {
        [self removeFile:[self photoPath:self.beforePhotoId]];
    }
//    [self removeFile:[self photoPath:[self.afterPhotoId intValue]]];
}

-(BOOL)isComplete
{
//    NSLog(@"status is: %@", self.status);
    if([self.status isEqualToString:@"complete"]) {
        return TRUE;
    }
    return FALSE;
}

-(BOOL)isAssigned
{
//    NSLog(@"status is: %@", self.status);
    if([self.status isEqualToString:@"assigned"]) {
        return TRUE;
    }
    return FALSE;
}

@end
