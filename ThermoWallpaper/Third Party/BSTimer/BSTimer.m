//
//  BSTimer.m
//  BSTimer
//
//  Created by Simon Støvring on 16/05/12.
//  Copyright (c) 2012 intuitaps. All rights reserved.
//

#import "BSTimer.h"

@interface BSTimer ()
@property (nonatomic, strong) void (^completionBlock)(void);
@property (nonatomic, strong) BOOL (^repeatingCompletionBlock)(void);
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign, getter = isRepeating) BOOL repeating;
@end

@implementation BSTimer

#pragma mark -
#pragma mark Lifecycle

- (id)initWithDelay:(NSTimeInterval)delay completion:(id)completion repeats:(BOOL)repeats
{
    if (self = [super init])
    {
        if (repeats)
        {
            self.repeatingCompletionBlock = completion;
        }
        else
        {
            self.completionBlock = completion;
        }
        
        self.repeating = repeats;
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(done) userInfo:nil repeats:repeats];
    }
    
    return self;
}

- (void)dealloc
{
    self.completionBlock = nil;
    self.repeatingCompletionBlock = nil;
    self.timer = nil;
}

#pragma mark -
#pragma mark Public Methods

+ (void)timerWithDelay:(NSTimeInterval)delay completion:(void(^)(void))completion
{
    (void) [[[self class] alloc] initWithDelay:delay completion:completion repeats:NO];
}

+ (void)repeatingTimerWithDelay:(NSTimeInterval)delay completion:(BOOL(^)(void))completion
{
    (void) [[[self class] alloc] initWithDelay:delay completion:completion repeats:YES];
}

#pragma mark -
#pragma mark Private Methods

- (void)done
{
    if (self.isRepeating)
    {
        BOOL repeat = self.repeatingCompletionBlock();
        if (!repeat)
        {
            [self.timer invalidate];
        }
    }
    else
    {
        self.completionBlock();
    }
}

@end
