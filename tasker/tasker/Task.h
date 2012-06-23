//
//  Task.h
//  tasker
//
//  Created by Thomas Gamble on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Task : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSNumber *beforePhotoId;
@property (nonatomic, strong) NSDate *dueDate;
@property (nonatomic, strong) NSString * category;
@property (nonatomic, strong) NSString * assignedTo;

@end
