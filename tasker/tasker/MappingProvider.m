//
//  MappingProvider.m
//  tasker
//
//  Created by Thomas Gamble on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//
//  RKGHMappingProvider.m
//  RKGithub
//
//  Created by Blake Watters on 2/16/12.
//  Copyright (c) 2012 RestKit. All rights reserved.
//

#import "MappingProvider.h"
#import "Task.h"

@implementation MappingProvider

@synthesize objectStore;

+ (id)mappingProviderWithObjectStore:(RKManagedObjectStore *)objectStore {
    return [[self alloc] initWithObjectStore:objectStore];    
}

- (id)initWithObjectStore:(RKManagedObjectStore *)theObjectStore {
    self = [super init];
    if (self) {
        self.objectStore = theObjectStore;
        
        [self setObjectMapping:[self taskObjectMapping] forResourcePathPattern:@"/tasker/task" withFetchRequestBlock:^NSFetchRequest *(NSString *resourcePath) {
            NSFetchRequest *fetchRequest = [Task fetchRequest];
            fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dueDate" ascending:YES]];
            return fetchRequest;
        }];

    }

    return self;
}

- (RKManagedObjectMapping *)taskObjectMapping
{
    NSLog(@"creating taskMapping");
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[Task class] 
                                                         inManagedObjectStore:self.objectStore];
    mapping.primaryKeyAttribute = @"taskID";
    [mapping mapKeyPath:@"taskID" toAttribute:@"taskID"];
    [mapping mapKeyPath:@"title" toAttribute:@"title"];
    [mapping mapKeyPath:@"creator" toAttribute:@"creator"];
    [mapping mapKeyPath:@"createDate" toAttribute:@"createDate"];
    [mapping mapKeyPath:@"completedDate" toAttribute:@"completedDate"];
    [mapping mapKeyPath:@"dueDate" toAttribute:@"dueDate"];
    [mapping mapKeyPath:@"status" toAttribute:@"status"];
    [mapping mapKeyPath:@"taskDescription" toAttribute:@"taskDescription"];
    [mapping mapKeyPath:@"completor" toAttribute:@"completor"];
    [mapping mapKeyPath:@"beforePhotoUrl" toAttribute:@"beforePhotoUrl"];
    [mapping mapKeyPath:@"afterPhotoUrl" toAttribute:@"afterPhotoUrl"];
    
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    [dateFormatter  setDateFormat:@"MM dd, yy HH:mm:ss a"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"EST"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    mapping.dateFormatters = [NSArray arrayWithObject: dateFormatter]; 
    
    return mapping;
}


/* Relationship example
- (RKManagedObjectMapping *)issueObjectMapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[RKGHIssue class] 
                                                         inManagedObjectStore:self.objectStore];
    mapping.primaryKeyAttribute = @"number";
    [mapping mapAttributes:@"state", @"number", @"title", @"body", nil];
    [mapping mapKeyPathsToAttributes:
     @"url", @"issueURLString",
     @"html_url", @"htmlURLString",
     @"comments", @"commentsNumber",
     @"closed_at", @"closedAt",
     @"created_at", @"createdAt",
     @"updated_at", @"updatedAt",
     nil];
    
    // Relationships
    [mapping mapKeyPath:@"user" toRelationship:@"user" withMapping:[self userObjectMapping]];
    [mapping mapKeyPath:@"assignee" toRelationship:@"assignee" withMapping:[self userObjectMapping]];
    [mapping mapKeyPath:@"milestone" toRelationship:@"milestone" withMapping:[self milestoneObjectMapping]];
    
    return mapping;    
}
 */

/* Non-managed example
 * add this to init //        [self setObjectMapping:[self pullRequestObjectMapping] forResourcePathPattern:@"/repos/:user/:repo/pulls"];
- (RKObjectMapping *)pullRequestObjectMapping {
    RKObjectMapping *mapping =  [RKObjectMapping mappingForClass:[RKGHPullRequest class]];
    [mapping mapAttributes:@"number", @"state", @"title", @"body", nil];
    [mapping mapKeyPathsToAttributes:
     @"url", @"selfURL",
     @"diff_url", @"diffURL",
     @"patch_url", @"patchURL",
     @"issue_url", @"issueURL",
     @"created_at", @"createdAt",
     @"updated_at", @"updatedAt",
     @"closed_at", @"closedAt",
     @"merged_at", @"mergedAt",
     nil];
    
    return mapping;
}
*/

@end