//
//  CHPlayerView.h
//  CHPlayer
//
//  Created by Cher on 16/6/12.
//  Copyright © 2016年 Hxc. All rights reserved.
//



//  github  https://github.com/coopsif/CHPlayer
//  简书     http://www.jianshu.com/p/232c16ad1da6



#import <UIKit/UIKit.h>

typedef void(^BackClickBlock)();
typedef void(^MoreClickBlock)();
typedef void(^CHPlayerEndBlock)();
typedef void(^CHPlayerFullEndToBackBlock)();

/*
  播放器存在的情况下，可以使用下面这2个通知 [暂停] 或者 [继续播放] 注意发送通知请带上播放器对象,否则引起bug。(参考demo)
 */

/**
 *  继续播放通知
 */
static NSString *const CHPlayerContinuePlayNotification = @"CHPlayerContinuePlayNotification";

/**
 *  暂停播放通知
 */
static NSString *const CHPlayerStopPlayNotification     = @"CHPlayerStopPlayNotification";


typedef NS_ENUM(NSInteger, CHPlayerType){
     
     PlayerTypeOfNoNavigationBar = 0,       // 无导航栏
     PlayerTypeOfNavigationBar   = 1,      // 有导航栏
     PlayerTypeOfFullScreen      = 2,     // 全屏
};

@interface CHPlayerView : UIView

/**
 *  非全屏(全屏)返回回调
 */
@property (nonatomic, copy)   BackClickBlock backClickBlock;
/**
 *  更多选项回调
 */
@property (nonatomic, copy)   MoreClickBlock moreClickBlock;

/**
 *  播放结束后回调
 */
@property (nonatomic, copy)   CHPlayerEndBlock playerEndBlock;

/**
 *  全屏播放结束后PoP返回回调 该回调只对PlayerTypeOfFullScreen有效
 */
@property (nonatomic, copy)   CHPlayerFullEndToBackBlock playerFullEndToBackBlock;

/***** 注意: PlayerTypeOfFullScreen类型下 playerEndBlock  playerFullEndToBackBlock 两者不能并存 根据需求选择其中回调 参考请看demo ********/

/**
 *  播放url
 */
@property (nonatomic, copy)   NSString *playerUrl;

/**
 *  视频标题
 */
@property (nonatomic, copy)   NSString *videoTitle;

/**
 *  缓存条颜色
 */
@property (nonatomic, strong) UIColor *cacheBarColor;

/**
 *  播放条颜色
 */
@property (nonatomic, strong) UIColor *playedColor;

/**
 *  创建播放器对象
 *
 *  @param frame 播放器frame
 *  @param Type  播放器类型
 *  @param autoPlay  是否自动播放
 *
 *  @return 播放器对象
 */
- (instancetype)initWithFrame:(CGRect)frame playerType:(CHPlayerType)type autoPlay:(BOOL)aotoPlay;

#pragma mark - Initializer
// 这三个方法不能使用，因为实例化对象时要有初始化type、aotoPlay
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;


@end



