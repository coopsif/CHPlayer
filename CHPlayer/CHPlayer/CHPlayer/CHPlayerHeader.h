//
//  CHPlayerHeader.h
//  CHPlayer
//
//  Created by Cher on 16/6/15.
//  Copyright © 2016年 Hxc. All rights reserved.
//

#ifndef CHPlayerHeader_h
#define CHPlayerHeader_h

#define  CHPlayer_W [[UIScreen mainScreen] bounds].size.width
#define  CHPlayer_H [[UIScreen mainScreen] bounds].size.height
#define  CH_Rgb(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define  WS(weakSelf)  __weak __typeof(&*self)weakSelf = self
//DUG输出
#ifdef DEBUG
# define DLog(format, ...) NSLog((@"[文件名:%s]" "[函数名:%s]" "[行号:%d]" format), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
# define DLog(...);
#endif

#import <Masonry.h>

static CGFloat const CH_annimationTime = 0.35f;//动画时间
static CGFloat const CH_brightnessStep = 0.02f;//亮度(声音)调节
static CGFloat const CH_fastSecond = 2.0f;   //快进的秒数
static CGFloat const CH_showViewTime = 5.0f;//顶部 底部栏 显示时间5s后自动隐藏

static NSString *const CHPlayer_LockScreen = @"CHPlayer_LockScreen";

static NSString *const playFaileInfo = @"播放链接出问题了,请点击重试";

/**
 *  图片资源
 */
static NSString *const CH_nofull_backIcon = @"CHPlayer_nofullBack";
static NSString *const CH_nofull_moreIcon = @"cat";
static NSString *const CH_playIcon = @"CHPlayer_play";
static NSString *const CH_pauseIcon = @"CHPlayer_pause";
static NSString *const CH_sliderIcon = @"CHPlayer_point";
static NSString *const CH_nofull_zoomIcon = @"CHPlayer_fullScreen";
static NSString *const CH_rewindIcon = @"CHPlayer_goback";
static NSString *const CH_fastForwardIcon = @"CHPlayer_award";
static NSString *const CH_full_backIcon = @"CHPlayer_fullBack";
static NSString *const CH_full_unLockIcon = @"CH_full_unLockIcon";
static NSString *const CH_full_lockIcon = @"CH_full_lockIcon";

static NSString *const CH_cell_closeIcon = @"CHPlayer_point";
static NSString *const CH_cell_playIcon = @"CHPlayer_noAuto";

#endif /* CHPlayerHeader_h */
