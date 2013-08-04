//
//  NSImage+SaveJPEG.m
//  ThermoWallpaper
//
//  Created by Simon Støvring on 29/07/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "NSImage+SaveJPEG.h"

@implementation NSImage (SaveJPEG)

#pragma mark 
#pragma mark Public Methods

- (void)saveAsJPEGAtPath:(NSString *)path
{
    NSData *imageData = [self TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    [imageData writeToFile:path atomically:NO];
}

@end
