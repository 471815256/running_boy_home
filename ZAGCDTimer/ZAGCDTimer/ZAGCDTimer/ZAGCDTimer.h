//
//  ZAGCDTimer.h
//  ZAGCDTimer
//
//  Created by songzhanao on 2020/6/26.
//  Copyright © 2020 guiqulaixi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ZAGCDTimer;

typedef void(^ZATimerFireBlock)(ZAGCDTimer *timer);

@interface ZAGCDTimer : NSObject


+ (instancetype)scheduleTimerWithDuration:(NSTimeInterval)duration
                                   repeat:(BOOL)repeat
                                    block:(ZATimerFireBlock)block;


- (instancetype)initWithDuration:(NSTimeInterval)duration
                          repeat:(BOOL)repeat
                           block:(ZATimerFireBlock)block;

- (void)fire;

- (void)invalidate;

- (void)suspend;

- (void)resume;

@end

NS_ASSUME_NONNULL_END
