//
//  AppDelegate.m
//  ThermoWallpaper
//
//  Created by Simon Støvring on 29/07/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "AppDelegate.h"
#import "SnapshotCamera.h"
#import "NSImage+SaveJPEG.h"

#define kUpdateInterval 60 * 30
#define kCameraSnapshotDelay 10.0f
#define kTwitterUsername @"simonbs"
#define kTweetbotAppBundleId "com.tapbots.TweetbotMac" // osascript -e 'id of app "Tweetbot"'

@interface AppDelegate ()
@property (nonatomic, strong) SnapshotCamera *snapshotCamera;
@property (nonatomic, strong) NSTimer *snapshotTimer;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSURL *defaultDesktopImageURL;
@end

@implementation AppDelegate

#pragma mark -
#pragma mark Lifecycle

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Store default background image so we can reset to it when app terminates
    self.defaultDesktopImageURL = [[NSWorkspace sharedWorkspace] desktopImageURLForScreen:[NSScreen mainScreen]];
    
    // Update the background to the current temperature
    [self updateBackground];
    
    // Set a timer for updating
    self.snapshotTimer = [NSTimer scheduledTimerWithTimeInterval:kUpdateInterval target:self selector:@selector(updateBackground) userInfo:nil repeats:YES];
    
    // Create status item
    NSString *quitMenuItemTitle = NSLocalizedStringFromTable(@"Quit", @"AppDelegate", @"Title for quit menu item");
    NSString *creditsMenuItemTitle = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Developed by @%@", @"AppDelegate", @"Title for credits menu item. %@ is replaced with the Twitter username."), kTwitterUsername];
    
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:quitMenuItemTitle action:@selector(quitApp:) keyEquivalent:@"Q"];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:creditsMenuItemTitle action:@selector(openTwitter:) keyEquivalent:@""];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.image = [NSImage imageNamed:@"MenuBarIcon"];
    self.statusItem.alternateImage = [NSImage imageNamed:@"MenuBarIconHighlighted"];
    self.statusItem.menu = menu;
    self.statusItem.highlightMode = YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    // Set background image to the one from launch
    [[NSWorkspace sharedWorkspace] setDesktopImageURL:self.defaultDesktopImageURL forScreen:[NSScreen mainScreen] options:nil error:nil];
}

- (void)dealloc
{
    if (self.snapshotTimer)
    {
        [self.snapshotTimer invalidate];
    }
    
    self.snapshotCamera = nil;
    self.snapshotTimer = nil;
    self.statusItem = nil;
}

#pragma mark -
#pragma mark Private Methods

- (void)updateBackground
{
    NSSize screenSize = [NSScreen mainScreen].frame.size;
    NSURL *url = [NSURL URLWithString:@"http://thermo.me?loc"];
    self.snapshotCamera = [[SnapshotCamera alloc] init];
    [self.snapshotCamera takeSnapshotOfWebPageAtURL:url size:screenSize delay:kCameraSnapshotDelay completion:^(NSImage *image) {
        NSString *imageName = [NSString stringWithFormat:@"capture-%f.jpg", [[NSDate date] timeIntervalSince1970]];
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:imageName];
        [image saveAsJPEGAtPath:filePath];
                
        NSError *error = nil;
        [[NSWorkspace sharedWorkspace] setDesktopImageURL:[NSURL fileURLWithPath:filePath] forScreen:[NSScreen mainScreen] options:nil error:&error];
        if (error)
        {
            NSLog(@"Could not set desktop wallpaper: %@", error);
        }
    } failure:^(NSError *error) {
        NSLog(@"An error occurred capturing the image: %@", error);
    }];
}

- (void)quitApp:(id)sender
{
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0f];
}

- (void)openTwitter:(id)sender
{
    OSStatus result = LSFindApplicationForInfo(kLSUnknownCreator, CFSTR(kTweetbotAppBundleId), NULL, NULL, NULL);
    switch (result) {
        case noErr:
            [self openTwitterInTweetbot];
            break;
        case kLSApplicationNotFoundErr:
            [self openTwitterInBrowser];
            break;
        default:
            break;
    }
}

- (void)openTwitterInTweetbot
{
    NSString *urlString = [NSString stringWithFormat:@"tweetbot:///user_profile/%@", kTwitterUsername];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
}

- (void)openTwitterInBrowser
{
    NSString *urlString = [NSString stringWithFormat:@"http://twitter.com/%@", kTwitterUsername];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
}

@end
