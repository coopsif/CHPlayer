//
//  NSTimer+Ch_helper.m
//  OC_Tools
//
//  Created by Cher on 16/3/11.
//  Copyright © 2016年 Cher. All rights reserved.
//

#import "NSTimer+Ch_helper.h"

@implementation NSTimer (Ch_helper)

+ (NSTimer *)ch_scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats{
     
     void (^block)() = [inBlock copy];
     NSTimer * timer = [self scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(ch_executeTimerBlock:) userInfo:block repeats:inRepeats];
     return timer;
}

+ (NSTimer *)ch_timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats{
     
     void (^block)() = [inBlock copy];
     NSTimer * timer = [self timerWithTimeInterval:inTimeInterval target:self selector:@selector(ch_executeTimerBlock:) userInfo:block repeats:inRepeats];
     return timer;
}


+ (void)ch_executeTimerBlock:(NSTimer*)sender{
     
     if ([sender userInfo]) {
          void (^block)() = (void (^)())[sender userInfo];
          block();
     }
}

@end
