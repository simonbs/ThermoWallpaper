//
//  BSTimer.h
//  BSTimer
//
//  Created by Simon Støvring on 16/05/12.
//  Copyright (c) 2012 intuitaps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSTimer : NSObject

+ (void)timerWithDelay:(NSTimeInterval)delay completion:(void(^)(void))completion;
+ (void)repeatingTimerWithDelay:(NSTimeInterval)delay completion:(BOOL(^)(void))completion;

@end
