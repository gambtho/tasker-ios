//
//  Task.h
//  tasker
//
//  Created by Thomas Gamble on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>

@interface Task : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * taskDescription;
@property (nonatomic, retain) NSDate * dueDate;
@property (nonatomic, retain) NSDate * completedDate;
@property (nonatomic, retain) NSString * creator;
@property (nonatomic, retain) NSString * completor;
@property (nonatomic, retain) NSString * beforePhotoId;
@property (nonatomic, retain) NSString * afterPhotoId;
@property (nonatomic, retain) NSNumber * taskID;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSDate * createDate;

-(BOOL)hasBeforePhoto;
-(NSString *)photoPath:(NSString *)photoId;
-(UIImage *)photoImage:(NSString *)photoId;
-(void)removePhotoFiles;
-(BOOL)isComplete;
-(BOOL)isAssigned;

@end
