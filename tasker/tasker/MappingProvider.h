//
//  MappingProvider.h
//  tasker
//
//  Created by Thomas Gamble on 7/22/12 - Based on RKGHMappingProvider.h by Blake Waters
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RKObjectMappingProvider.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>


@interface MappingProvider : RKObjectMappingProvider


@property (nonatomic, strong) RKManagedObjectStore *objectStore;

+ (id)mappingProviderWithObjectStore:(RKManagedObjectStore *)objectStore;
- (id)initWithObjectStore:(RKManagedObjectStore *)objectStore;
- (RKManagedObjectMapping *)taskObjectMapping;

/*  Non-maanged example
- (RKObjectMapping *)pullRequestObjectMapping;
*/

@end