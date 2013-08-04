//
//  NSImage+SaveJPEG.h
//  ThermoWallpaper
//
//  Created by Simon Støvring on 29/07/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (SaveJPEG)

- (void)saveAsJPEGAtPath:(NSString *)path;

@end
