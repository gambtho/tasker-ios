//
//  Constants.m
//  tasker
//
//  Created by Thomas Gamble on 8/2/12.
//
//

#import "Constants.h"

@implementation Constants

#ifdef DEBUG
    NSString * const HOST = @"http://localhost:8888";
#else
    NSString * const HOST @"http://ymtasker.appspot.com";
#endif

NSString * const TASK_PATH = @"/tasker/task";
NSString * const DB_NAME = @"Tasker.sqlite";
NSString * const TF_ID = @"bee96b8435ae376fc15786c7c99c64fe_OTgwMzIyMDEyLTA2LTI0IDE0OjQ1OjU4LjA5MDMzMw";

@end
