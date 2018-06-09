//
//  FinderSync.m
//  SyncExtension
//
//  Created by Jens Restemeier on 09.06.18.
//  Copyright © 2018 Jens Restemeier. All rights reserved.
//

#import "FinderSync.h"
#import <sys/xattr.h>
#import <pwd.h>

@interface FinderSync ()

@property NSURL *myFolderURL;

@end

@implementation FinderSync

- (instancetype)init {
    self = [super init];

    NSLog(@"%s launched from %@ ; compiled at %s", __PRETTY_FUNCTION__, [[NSBundle mainBundle] bundlePath], __TIME__);

    // Set up the directory we are syncing. As this is just a test we request the user's non-sandboxed home directory.
    // yes, this is the same naughty mistake that Dropbox makes, but this is just a test.
    struct passwd * pwuid = getpwuid(getuid());
    NSString * homeDirectory = [NSString stringWithUTF8String:pwuid->pw_dir];
    self.myFolderURL = [NSURL fileURLWithPath:homeDirectory];
    [FIFinderSyncController defaultController].directoryURLs = [NSSet setWithObject:self.myFolderURL];

    // Set up images for our badge identifiers. For demonstration purposes, this uses off-the-shelf images.
    [[FIFinderSyncController defaultController] setBadgeImage:[NSImage imageNamed: NSImageNameColorPanel] label:@"Status One" forBadgeIdentifier:@"One"];
    [[FIFinderSyncController defaultController] setBadgeImage:[NSImage imageNamed: NSImageNameCaution] label:@"Status Two" forBadgeIdentifier:@"Two"];
    
    return self;
}

#pragma mark - Primary Finder Sync protocol methods

- (void)beginObservingDirectoryAtURL:(NSURL *)url {
    // The user is now seeing the container's contents.
    // If they see it in more than one view at a time, we're only told once.
    NSLog(@"beginObservingDirectoryAtURL:%@", url.filePathURL);
}


- (void)endObservingDirectoryAtURL:(NSURL *)url {
    // The user is no longer seeing the container's contents.
    NSLog(@"endObservingDirectoryAtURL:%@", url.filePathURL);
}

// This is not called if DropBox is active, because I assume it gets ownership of the home directory.
- (void)requestBadgeIdentifierForURL:(NSURL *)url {
    NSLog(@"requestBadgeIdentifierForURL:%@", url.filePathURL);
    
    const char *filePath = [url.filePathURL fileSystemRepresentation];
    
    const char *name = "com.apple.TextEncoding";
    char value[256];
    NSInteger length = getxattr(filePath, name, value, sizeof(value), 0, 0);
    if (length > 0)
    {
        NSString * str = [[NSString alloc] initWithBytes:value length:length encoding:NSUTF8StringEncoding];
        NSLog(@"%@", str);
    }
    if (length < 0)
    {
        char errbuf[1024];
        strerror_r(errno, errbuf, sizeof(errbuf));
        NSLog(@"error: %i %s", errno, errbuf);
    }
    
    // For demonstration purposes, this picks one of our two badges, or no badge at all, based on the filename.
    NSInteger whichBadge = [url.filePathURL hash] % 3;
    NSString* badgeIdentifier = @[@"", @"One", @"Two"][whichBadge];
    [[FIFinderSyncController defaultController] setBadgeIdentifier:badgeIdentifier forURL:url];
}

#pragma mark - Menu and toolbar item support

- (NSString *)toolbarItemName {
    return @"SyncExtension";
}

- (NSString *)toolbarItemToolTip {
    return @"SyncExtension: Click the toolbar item for a menu.";
}

- (NSImage *)toolbarItemImage {
    return [NSImage imageNamed:NSImageNameCaution];
}

- (NSMenu *)menuForMenuKind:(FIMenuKind)whichMenu {
    // Produce a menu for the extension.
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    [menu addItemWithTitle:@"Example Menu Item" action:@selector(sampleAction:) keyEquivalent:@""];

    return menu;
}

- (IBAction)sampleAction:(id)sender {
    NSURL* target = [[FIFinderSyncController defaultController] targetedURL];
    NSArray* items = [[FIFinderSyncController defaultController] selectedItemURLs];

    NSLog(@"sampleAction: menu item: %@, target = %@, items = ", [sender title], [target filePathURL]);
    [items enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"    %@", [obj filePathURL]);
    }];
}

@end

