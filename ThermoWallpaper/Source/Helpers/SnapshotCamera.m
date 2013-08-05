//
//  SnapshotCamera.m
//  ThermoWallpaper
//
//  Created by Simon Støvring on 29/07/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "SnapshotCamera.h"
#import <WebKit/WebKit.h>
#import "BSTimer.h"

typedef enum {
    SnapshotCameraLoadingStateUnknown = -1,
    SnapshotCameraLoadingStateWebsite = 0,
    SnapshotCameraLoadingStateCustomHTML,
} SnapshotCameraLoadingState;

@interface SnapshotCamera ()
@property (nonatomic, strong) void (^completionBlock)(NSImage *);
@property (nonatomic, strong) void (^failureBlock)(NSError *);
@property (nonatomic, strong) WebView *webView;
@property (nonatomic, assign) CGFloat delay;
@property (nonatomic, assign) NSSize size;
@property (nonatomic, assign) SnapshotCameraLoadingState loadingState;
@property (nonatomic, strong) NSURL *url;
@end

@implementation SnapshotCamera

#pragma mark -
#pragma mark Lifecycle

- (id)init
{
    if (self = [super init])
    {
        self.loadingState = SnapshotCameraLoadingStateUnknown;
    }
    
    return self;
}

- (void)dealloc
{
	self.completionBlock = nil;
    self.failureBlock = nil;
    self.webView = nil;
    self.url = nil;
}

#pragma mark -
#pragma mark Public Methods

- (void)takeSnapshotOfWebPageAtURL:(NSURL *)url size:(NSSize)size completion:(void (^)(NSImage *))completion failure:(void (^)(NSError *))failure
{
    [self takeSnapshotOfWebPageAtURL:url size:size completion:completion failure:failure];
}

- (void)takeSnapshotOfWebPageAtURL:(NSURL *)url size:(NSSize)size delay:(CGFloat)delay completion:(void (^)(NSImage *))completion failure:(void (^)(NSError *))failure
{
    self.url = url;
    self.size = size;
    self.delay = delay;
    self.completionBlock = completion;
    self.failureBlock = failure;
    
    NSRect webViewFrame = NSZeroRect;
    webViewFrame.origin = NSZeroPoint;
    webViewFrame.size = size;
    self.webView = [[WebView alloc] initWithFrame:webViewFrame frameName:nil groupName:nil];
    self.webView.frameLoadDelegate = self;
    self.webView.mainFrameURL = [url absoluteString];
    self.loadingState = SnapshotCameraLoadingStateWebsite;
}

#pragma mark -
#pragma mark Private Methods

- (void)websiteDidLoad
{
    DOMDocument *domDocument = [[self.webView mainFrame] DOMDocument];
    DOMNodeList *htmlNodeList = [domDocument getElementsByTagName:@"html"];
    if ([htmlNodeList length] > 0)
    {
        DOMHTMLElement *htmlNode = (DOMHTMLElement *)[htmlNodeList item:0];
        
        DOMNodeList *contentNodeList = [htmlNode getElementsByClassName:@"content"];
        if ([contentNodeList length] > 0)
        {
            DOMHTMLElement *contentElement = (DOMHTMLElement *)[contentNodeList item:0];
        
            // Hide description
            DOMNodeList *descriptionNodeList = [contentElement getElementsByClassName:@"description"];
            if ([descriptionNodeList length] > 0)
            {
                DOMHTMLElement *descriptionElement = (DOMHTMLElement *)[descriptionNodeList item:0];
                [descriptionElement setAttribute:@"style" value:@"display:none;"];
            }
            
            // Hide App Store label
            DOMNodeList *appstoreNodeList = [contentElement getElementsByClassName:@"appstore"];
            if ([appstoreNodeList length] > 0)
            {
                DOMHTMLElement *appstoreElement = (DOMHTMLElement *)[appstoreNodeList item:0];
                [appstoreElement setAttribute:@"style" value:@"display:none;"];
            }
            
            // Hide Play Store plabel
            DOMNodeList *playstoreNodeList = [contentElement getElementsByClassName:@"playstore"];
            if ([playstoreNodeList length] > 0)
            {
                DOMHTMLElement *playstoreElement = (DOMHTMLElement *)[playstoreNodeList item:0];
                [playstoreElement setAttribute:@"style" value:@"display:none;"];
            }
        }
        
        NSString *html = [htmlNode outerHTML];
        [[self.webView mainFrame] loadHTMLString:html baseURL:self.url];
        
        self.loadingState = SnapshotCameraLoadingStateCustomHTML;
    }
    else
    {
        self.loadingState = SnapshotCameraLoadingStateUnknown;
    }
}

- (void)customHTMLDidLoad
{
    [BSTimer timerWithDelay:self.delay completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSView *webFrameViewDocView = [[[self.webView mainFrame] frameView] documentView];
            NSRect cacheRect = [webFrameViewDocView bounds];
            
            NSBitmapImageRep *imageRep = [webFrameViewDocView bitmapImageRepForCachingDisplayInRect:cacheRect];
            [webFrameViewDocView cacheDisplayInRect:cacheRect toBitmapImageRep:imageRep];
            
            NSRect srcRect = NSZeroRect;
            srcRect.size = self.size;
            srcRect.origin.y = cacheRect.size.height - self.size.height;
            
            NSRect destRect = NSZeroRect;
            destRect.size = self.size;
            
            NSImage *snapshot = [[NSImage alloc] initWithSize:self.size];
            [snapshot lockFocus];
            [imageRep drawInRect:destRect fromRect:srcRect operation:NSCompositeCopy fraction:1.0f respectFlipped:YES hints:nil];
            [snapshot unlockFocus];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.completionBlock)
                {
                    self.completionBlock(snapshot);
                }
            });
        });
    }];
    
    self.loadingState = SnapshotCameraLoadingStateUnknown;
}

#pragma mark -
#pragma mark Frame Load Delegate

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
	if (frame != [self.webView mainFrame])
	{
		return;
	}
    
    switch (self.loadingState) {
        case SnapshotCameraLoadingStateWebsite:
            [self websiteDidLoad];
            break;
        case SnapshotCameraLoadingStateCustomHTML:
            [self customHTMLDidLoad];
            break;
        default:
            break;
    }
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    if (self.failureBlock)
    {
        self.failureBlock(error);
    }
}

@end
