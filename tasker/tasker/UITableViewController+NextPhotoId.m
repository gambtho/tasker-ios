//
//  UITableViewController+NextPhotoId.m
//  tasker
//
//  Created by Thomas Gamble on 8/2/12.
//
//

#import "UITableViewController+NextPhotoId.h"

@implementation UITableViewController (NextPhotoId)

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

- (int) nextPhotoId {
    int photoId = [[NSUserDefaults standardUserDefaults] integerForKey:@"PhotoID"];
    DDLogVerbose(@"Photo Id is currently: %d", photoId);
    [[NSUserDefaults standardUserDefaults] setInteger:photoId+1 forKey:@"PhotoID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return photoId;
}

@end
