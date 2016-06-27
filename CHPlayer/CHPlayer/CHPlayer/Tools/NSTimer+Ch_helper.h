//
//  NSTimer+Ch_helper.h
//  OC_Tools
//
//  Created by Cher on 16/3/11.
//  Copyright © 2016年 Cher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Ch_helper)
/**
 *   自动添加到 RunLoop 中 定时器启动
 *
 *  @param inTimeInterval 定时时间
 *  @param inBlock        定时器回调block
 *  @param inRepeats      是否重复
 *
 *  @return 定时器对象
 */
+ (NSTimer *)ch_scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;

/**
 *  手动添加到 RunLoop 中 否则不启动定时器  ---- [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode]
 *
 *  @param inTimeInterval 定时时间
 *  @param inBlock        定时器回调block
 *  @param inRepeats      是否重复
 *
 *  @return 定时器对象
 */
+ (NSTimer *)ch_timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;

@end
