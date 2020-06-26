//
//  ZAGCDTimer.m
//  ZAGCDTimer
//
//  Created by songzhanao on 2020/6/26.
//  Copyright © 2020 guiqulaixi. All rights reserved.
//

#import "ZAGCDTimer.h"

@interface ZAGCDTimer ()

@property (nonatomic) BOOL repeat;

@property (nonatomic) NSTimeInterval duration;

@property (nonatomic, copy) ZATimerFireBlock block;

@property (nonatomic, strong) dispatch_queue_t timerQueue;

@property (nonatomic, strong) dispatch_source_t timerSource;

@property (nonatomic) BOOL isRunning;

@end

static NSUInteger za_timer_queue_num = 0;


@implementation ZAGCDTimer


+ (instancetype)scheduleTimerWithDuration:(NSTimeInterval)duration
                                   repeat:(BOOL)repeat
                                    block:(ZATimerFireBlock)block {
    ZAGCDTimer *timer = [[self alloc] initWithDuration:duration
                                             repeat:repeat
                                              block:block];
    [timer fire];
    return timer;
}


- (instancetype)initWithDuration:(NSTimeInterval)duration
                          repeat:(BOOL)repeat
                           block:(ZATimerFireBlock)block {
    if (self == [super init]) {
        self.duration = duration;
        self.repeat = repeat;
        self.block = block;
        // label
        za_timer_queue_num++;
        NSString *label = [NSString stringWithFormat:@"com.ZAGCDTimer.queue%lu", za_timer_queue_num];
        self.timerQueue = dispatch_queue_create(label.UTF8String, DISPATCH_QUEUE_SERIAL);
        self.timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.timerQueue);
        dispatch_source_set_timer(self.timerSource,
                                  DISPATCH_TIME_NOW,
                                  (uint64_t)(self.duration * NSEC_PER_SEC),
                                  0);
        __weak typeof(self) weakself = self;
        dispatch_source_set_event_handler(self.timerSource, ^{
            [weakself excute];
        });
    }
    return self;
}

- (void)suspend {
    if (self.isRunning) {
        dispatch_suspend(self.timerSource);
        self.isRunning = NO;
    }
}

- (void)resume {
    if (!self.isRunning) {
        dispatch_resume(self.timerSource);
        self.isRunning = YES;
    }
}

- (void)fire {
    if (self.isRunning) {
        return;
    }

    if (NO == self.repeat) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(self.duration * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [self excute];
        });
        return;
    }

    dispatch_resume(self.timerSource);
    self.isRunning = YES;
}

- (void)invalidate {
    if (self.isRunning) {
        dispatch_cancel(self.timerSource);
    }
    self.block = nil;
    self.isRunning = NO;
}

- (void)excute {
    if (self.block != nil) {
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakself.block(self);
        });
        return;
    }
}


@end
