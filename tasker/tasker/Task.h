//
//  Task.h
//  tasker
//
//  Created by Thomas Gamble on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Task : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * taskDescription;
@property (nonatomic, retain) NSDate * dueDate;
@property (nonatomic, retain) NSDate * completedDate;
@property (nonatomic, retain) NSString * creator;
@property (nonatomic, retain) NSString * completor;
@property (nonatomic, retain) NSNumber * beforePhotoId;
@property (nonatomic, retain) NSNumber * afterPhotoId;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSDate * createDate;

-(BOOL)hasBeforePhoto;
-(NSString *)photoPath:(int)photoId;
-(UIImage *)photoImage:(int)photoId;
-(void)removePhotoFiles;

@end
