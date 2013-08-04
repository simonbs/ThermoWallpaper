//
//  SnapshotCamera.h
//  ThermoWallpaper
//
//  Created by Simon Støvring on 29/07/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnapshotCamera : NSObject

- (void)takeSnapshotOfWebPageAtURL:(NSURL *)url size:(NSSize)size completion:(void (^)(NSImage *))completion failure:(void (^)(NSError *))failure;
- (void)takeSnapshotOfWebPageAtURL:(NSURL *)url size:(NSSize)size delay:(CGFloat)delay completion:(void (^)(NSImage *))completion failure:(void (^)(NSError *))failure;

@end
