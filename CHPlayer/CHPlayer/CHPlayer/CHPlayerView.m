//
//  CHPlayerView.m
//  CHPlayer
//
//  Created by Cher on 16/6/12.
//  Copyright © 2016年 Hxc. All rights reserved.
//

#import "CHPlayerView.h"
#import "NSString+CH_stringWidthAndHeight.h"
#import "NSTimer+Ch_helper.h"
#import "CHPlayerHeader.h"
#import "UIView+CH_GestureRecognizer.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

typedef NS_ENUM(NSInteger, GestureType){
     GestureTypeOfNone = 0,     //
     GestureTypeOfVolume,      //右屏上下滑动 -- 音量
     GestureTypeOfBrightness, // 左屏上下滑动 -- 亮度
     GestureTypeOfProgress,  // 左右滑动 -- 快进退
};

@interface CHPlayerView()

//播放类模块
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, copy)   NSString *totalTime;//视频总时间
@property (nonatomic, strong) NSObject *playbackTimeObserver;
@property (nonatomic, strong) MPMusicPlayerController* musicController;

/** == 手势类型 == **/
@property (nonatomic) GestureType gestureType;
@property (nonatomic, strong) UIView *container;//容器视图
@property (nonatomic, strong) UIView *cellContainer;//单元格容器视图
@property (nonatomic, strong) UIImageView* playImgView;//单元格容器播放视图

/** == 头部模块 == **/
@property (nonatomic, strong) UIView *topView;//头部视图

//未全屏
@property (nonatomic ,strong) UIImageView *backView;//返回按钮
@property (nonatomic ,strong) UIImageView *moreView;//更多操作

//全屏才展示
@property (nonatomic, strong) UILabel *titleLabel;//视频标题
@property (nonatomic, strong) UIView *backImageButton;//返回 -- 全屏才显示
/// 屏幕锁定按钮
@property (nonatomic, strong) UIButton *lockButton;

@property (nonatomic, strong) UIView *downImageButton;//下载视频

/** == 快进模块 == **/
@property (nonatomic, strong) UIImageView *fastBgView;//快进/快退 视图
@property (nonatomic, strong) UIImageView *fastImgView;//快进/快退 子视图
@property (nonatomic, strong) UILabel *fastLabel;//快进/快退 子视图
@property (nonatomic, strong) NSTimer *fastTimer;//定时器 -- 1/2 秒后快进视图

@property (nonatomic, assign) NSInteger fastTimerCount;//定时器 -- 1/2 秒后快进视图
@property (nonatomic, assign) CGFloat   timeLength;//时间Label宽度


/** == 中间提示模块 == **/
@property (nonatomic, strong) UILabel *playerCenterLabel;//视频器播放失败提示
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;//加载
@property (nonatomic, strong) UIView *tapView;//点击视图

/** == 底部模块 == **/
@property (nonatomic, strong) UIView *bottomView;//底部视图
@property (nonatomic, strong) UIButton *playerButton;//播放按钮
@property (nonatomic, strong) UIProgressView *progressView;//缓存进度
@property (nonatomic, strong) UISlider *playerSlier;//播放进度
@property (nonatomic, strong) UILabel *timeLabel;//播放时间
@property (nonatomic, strong) UIView *zoneView;//全屏放大--返回
//** 全屏显示 **//
@property (nonatomic, strong) UILabel *highLabel;//高清
@property (nonatomic, strong) UILabel *selectLabel;//选集

/** == 功能模块 == **/
@property (nonatomic, strong) NSTimer *timer;//定时器 -- 5 秒后隐藏 头部/底部视图
@property (nonatomic, assign) NSInteger timerNub;//定时器计数
@property (nonatomic, assign) BOOL isDarw;//是否拖拽
@property (nonatomic, assign) BOOL tapShow;//点击显示 ？隐藏
@property (nonatomic, assign) BOOL isFullScreen;//是否是全屏
@property (nonatomic, assign) CGFloat cMTimeRange;//缓存数值

@property (nonatomic, readonly) CGFloat currentValue;//当前播放进度值
@property (nonatomic, assign) CGRect orgFrame;//未旋转屏幕的Frame
@property (nonatomic, assign) CGPoint originalLocation;//原始触点

@property (nonatomic, assign)UIInterfaceOrientation orientation;//检测播放时横屏过来 还是竖屏
@property (nonatomic, strong) NSTimer *suViewTimer;//定时器(检测self父视图是否存在)
@property (nonatomic, strong) NSTimer *suViewDestroytimer;//定时器(检测self父视图是否已经销毁)

@property (nonatomic, assign) CHPlayerType playerType; //播放器类型
@property (nonatomic, assign) BOOL autoPlay;  //是否自动播放

@end


@implementation CHPlayerView

//同时也要在.m文件中写一个返回类类型的方法，不然使用者（viewController）还是会认为这只是CALayer
+ (Class)layerClass{
     return [AVPlayerLayer class];
}

- (AVPlayer *)player {
     return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
     [(AVPlayerLayer *)[self layer] setPlayer:player];
     AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
     playerLayer.videoGravity = AVLayerVideoGravityResize;//视频填充模式
}

- (void)dealloc{
     
     [self removeObserver];
     [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
     [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
     [[NSNotificationCenter defaultCenter] removeObserver:self];
     
     NSLog(@"| CHPlayer | I - [CHPlayer]\
           ------------------------- CHPlayer Log -------------------------\
           --------------------Thanks for using CHPlayer-------------------\
           ----------------------- QQ group: xxxxxxxxx --------------------\
           ------------------------- Make By Cher -------------------------");

}



- (instancetype)initWithFrame:(CGRect)frame playerType:(CHPlayerType)type autoPlay:(BOOL)aotoPlay
{
     self = [super initWithFrame:frame];
     if (self) {
          self.playerType      = type;
          self.autoPlay        = aotoPlay;
          _cacheBarColor       = CH_Rgb(248,195,72);
          _playedColor         = CH_Rgb(248,195,72);
          self.backgroundColor = CH_Rgb(48, 49, 57);
          self.orgFrame        = frame;
          self.layer.masksToBounds = YES;
          [self initialization];
          [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:CHPlayer_LockScreen];//设置默认不锁屏
          if (self.playerType == PlayerTypeOfFullScreen) {//全屏
               self.isFullScreen = YES;
               [self deviceOrientation:UIInterfaceOrientationLandscapeRight annimation:YES];
          }
          UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
          self.orientation = orientation;
          [self suViewtimerWork];
          [self addCHPlayerNotification];
          
     }
     return self;
}

//判断初始化的旋转方向
- (void)orientationView{
     
     [self removeSuViewtimer];
     CGFloat w = self.orientation == UIInterfaceOrientationPortrait?self.orgFrame.size.width:CHPlayer_W;
     [self mas_remakeConstraints:^(MASConstraintMaker *make) {
          make.left.equalTo(@(self.orgFrame.origin.x));
          make.top.equalTo(@(self.orgFrame.origin.y));
          make.width.equalTo(@(w));
          make.height.equalTo(@(self.orgFrame.size.height));
     }];
     
     if (self.playerType == PlayerTypeOfFullScreen) {
          [self statusBarOrientationChange];
     }else{
          if (self.orientation == UIInterfaceOrientationLandscapeRight ||self.orientation == UIInterfaceOrientationLandscapeLeft) [self statusBarOrientationChange];
     }
}

#pragma mark ------- 检测父控制器,父视图定时器以及事件
//检测self=>父视图 父控制器
- (void)suViewtimerWork{
    
     [self registerSuViewtimer];
     if (self.playerType == PlayerTypeOfNavigationBar) {
          [self registerSuViewDestroytimer];
     }

}

//检测父视图
- (void)registerSuViewtimer{
      WS(weakSelf);
     self.suViewTimer = [NSTimer ch_scheduledTimerWithTimeInterval:0.1 block:^{
          weakSelf.superview?[weakSelf orientationView]:nil;
     } repeats:YES];
}


- (void)removeSuViewtimer{
     if (self.suViewTimer) {
          [self.suViewTimer invalidate];
          self.suViewTimer = nil;
     }
}

//检测父控制器
- (void)registerSuViewDestroytimer{
     WS(weakSelf);
     self.suViewDestroytimer = [NSTimer ch_scheduledTimerWithTimeInterval:0.1 block:^{
          if (![weakSelf ViewController]) {
               [weakSelf removeSuViewDestroytimer];
               [self removeAllTimer];
          }
     } repeats:YES];
}

- (void)removeSuViewDestroytimer{
     if (self.suViewDestroytimer) {
          [self.suViewDestroytimer invalidate];
          self.suViewDestroytimer = nil;
     }
}



/////////////////////////////////////////////////////通知区域////////////////////////////////////////////////////////////

#pragma mark -------- 通知以及旋转处理区域
- (void)addCHPlayerNotification{
     //app活跃通知 == 继续播放
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActiveAction:) name:UIApplicationDidBecomeActiveNotification object:nil];
     //屏幕旋转通知
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
     //暂停播放通知
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActiveAction:) name:CHPlayerContinuePlayNotification object:nil];
     //继续播放通知
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActive:) name:CHPlayerStopPlayNotification object:nil];
}

//app活跃通知  继续播放
- (void)becomeActiveAction:(NSNotification *)sender{
     //NSLog(@"===%@",sender.name);
     if (![sender.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
          id obj = sender.object;
          if (obj != self) return;
     }
     [self repeatsTimer];
     if (!self.player) return;
     self.playerButton.selected = NO;
     [self.player play];
     UIImage *img = [UIImage imageNamed:CH_pauseIcon];
     [self.playerButton setImage:img forState:UIControlStateNormal];
     self.playerButton.selected = !self.playerButton.selected;
}

//暂停播放
- (void)resignActive:(NSNotification *)sender{
     
     id obj = sender.object;
     if (obj != self) return;
     [self removeRepeatsTimer];
     if (!self.player) return;
     self.playerButton.selected = YES;
     [self.player pause];
     UIImage *img = [UIImage imageNamed:CH_playIcon];
     [self.playerButton setImage:img forState:UIControlStateNormal];
     [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
     [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
     self.playerButton.selected = !self.playerButton.selected;
}

//屏幕旋转通知
- (void)statusBarOrientationChange{

     UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
     
     if (orientation == UIInterfaceOrientationLandscapeRight ||orientation == UIInterfaceOrientationLandscapeLeft) // home键靠左右
     {
          self.isFullScreen = YES;
          [self vieWscrollEnabled:NO];
          [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
          //DLog(@" ==home键靠右== %ld",(long)orientation);
          [self mas_remakeConstraints:^(MASConstraintMaker *make) {
               make.left.top.equalTo(@(0));
               make.width.equalTo(@(CHPlayer_W));
               make.height.equalTo(@(CHPlayer_H));
          }];
          
          self.backView.hidden = self.moreView.hidden = self.zoneView.hidden = YES;
          self.topView.hidden  = /*self.highLabel.hidden = self.selectLabel.hidden = */[self.container viewWithTag:9999].hidden = NO;
          //全屏 隐藏导航栏
          if (self.playerType == PlayerTypeOfNavigationBar ||self.playerType == PlayerTypeOfFullScreen) [self setNavigationBarHidden:YES];
          
          if (self.playerType != PlayerTypeOfFullScreen) {
               [self showView];
               self.tapShow = NO;
          }
     }
     
     if (orientation == UIInterfaceOrientationPortrait)
     {
          //小屏 显示导航栏
          [self backNavigationBar];
          [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
          if (self.playerType == PlayerTypeOfFullScreen) return;
          
          self.isFullScreen = NO;
          [self vieWscrollEnabled:YES];

          CGFloat w = self.orientation == UIInterfaceOrientationPortrait?self.orgFrame.size.width:CHPlayer_W;
          [self mas_remakeConstraints:^(MASConstraintMaker *make) {
               make.left.equalTo(@(self.orgFrame.origin.x));
               make.top.equalTo(@(self.orgFrame.origin.y));
               make.width.equalTo(@(w));
               make.height.equalTo(@(self.orgFrame.size.height));
          }];
          self.backView.hidden = self.moreView.hidden = self.zoneView.hidden = NO;
          self.topView.hidden  = self.highLabel.hidden = self.selectLabel.hidden = [self.container viewWithTag:9999].hidden = YES;
          [UIView animateWithDuration:CH_annimationTime animations:^{
               self.lockButton.alpha = 0;
          }];
     }
     [self upTimeLabelWidth];
}

- (void)upTimeLabelWidth{
     
     [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
          !self.zoneView.hidden? make.right.equalTo(self.zoneView.mas_left).offset(-5):(self.highLabel.hidden?make.right.equalTo(self.bottomView.mas_right).offset(-10):make.right.equalTo(self.highLabel.mas_left).offset(-10));
          make.centerY.equalTo(self.bottomView.mas_centerY);
          make.width.equalTo(@([self returnTimeWidth]));
     }];
}

- (void)backNavigationBar{
     //小屏 显示导航栏
     if (self.playerType == PlayerTypeOfNavigationBar || self.playerType == PlayerTypeOfFullScreen) [self setNavigationBarHidden:NO];
}


- (void)setNavigationBarHidden:(BOOL)hidden{
     UIViewController *vc = [self ViewController];
     vc.navigationController.navigationBar.hidden = hidden;
     vc.tabBarController.tabBar.hidden = hidden;
}



- (UIViewController*)ViewController{
     id nextResponder = nil;
     nextResponder = [self nextResponder];
     while (nextResponder) {
          if ([nextResponder isKindOfClass:[UIViewController class]]){
               return nextResponder;
          }
          nextResponder = [nextResponder nextResponder];
     }
     return nil;
}


- (void)vieWscrollEnabled:(BOOL)enabled{
     
     id nextResponder = [self.superview nextResponder];
     while (nextResponder) {
          if ([nextResponder isKindOfClass:[UIScrollView class]]){
               UIScrollView *superTabview = (UIScrollView *)nextResponder;
               superTabview.scrollEnabled = enabled;
          }
          nextResponder = [nextResponder nextResponder];
     }
}


/////////////////////////////////////////////////////通知区域////////////////////////////////////////////////////////////

/**
 *  设置播放器地址
 *
 *  @param playerUrl 播放器URL地址
 */
#pragma mark ------- 设置对外属性区域
- (void)setPlayerUrl:(NSString *)playerUrl{
     
     _playerUrl = playerUrl;
     AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[self returnPalyerUrl] options:nil];
     
     if (self.autoPlay) {//自动播放
          [self prepareToPlayAsset:asset];
     }
}

- (void)prepareToPlayAsset:(AVURLAsset *)asset{

     [self orgSet];
     if (self.playerItem) {
          [self removeObserver];
          [self repeatsTimer];
     }
     self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
     if (!self.player) [self setPlayer:[AVPlayer playerWithPlayerItem:self.playerItem]];
     if (self.player.currentItem != self.playerItem)[self.player replaceCurrentItemWithPlayerItem:self.playerItem];
     
     //添加播放器观察者
     [self addPlayerObserver];
     self.playerButton.selected = NO;
     if ([self respondsToSelector:@selector(playerAction:)]) {
          [self playerAction:self.playerButton];
     }
     self.playerCenterLabel.hidden = YES;
     _activityIndicatorView.hidden = NO;
     [_activityIndicatorView startAnimating];
     
}

- (void)orgSet{
     
     self.cMTimeRange    = 0;
     self.timeLabel.text = @"00:00/00:00";
     [self.progressView setProgress:0 animated:NO];
     [self.playerSlier  setValue:0 animated:NO];
}

//播放视频
- (void)tapPlayAction{
     
     if (self.cellContainer) self.cellContainer.alpha = 0;
     AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[self returnPalyerUrl] options:nil];
     [self prepareToPlayAsset:asset];
}

- (NSURL *)returnPalyerUrl{
     return [NSURL URLWithString:self.playerUrl];
}


- (void)setCacheBarColor:(UIColor *)cacheBarColor{
     if (_cacheBarColor != cacheBarColor) {
          _cacheBarColor = cacheBarColor;
          self.progressView.tintColor = _cacheBarColor;
     }
}

- (void)setPlayedColor:(UIColor *)playedColor{
     
     if (_playedColor != playedColor) {
          _playedColor = playedColor;
          self.playerSlier.minimumTrackTintColor = _playedColor;
     }
}

/**
 *  视频标题
 *
 *  @param videoTitle 视频标题
 */
- (void)setVideoTitle:(NSString *)videoTitle{
     if (_videoTitle != videoTitle) {
          _videoTitle = videoTitle;
          self.titleLabel.text = _videoTitle;
     }
}

#pragma mark ------- 添加视图事件
/**
 *  添加视图事件
 */
- (void)addViewTapAction{
     
     //非全屏返回/更多
     self.backView.tag = 1001;
     self.moreView.tag = 1002;
     [self.backView addTapCallBack:self sel:@selector(nofunllAction:)];
     [self.moreView addTapCallBack:self sel:@selector(nofunllAction:)];
     
     //全屏 /返回 -- 非全屏
     self.zoneView.tag = 1003;
     self.backImageButton.tag = 1004;
     [self.zoneView addTapCallBack:self sel:@selector(zoneAction:)];
     [self.backImageButton addTapCallBack:self sel:@selector(zoneAction:)];
     
     //点击视图
     [self.tapView addTapCallBack:self sel:@selector(tapAction:)];
     //双击视图(旋转)
     if (self.playerType != PlayerTypeOfFullScreen) [self.tapView addDoubleTapCallBack:self sel:@selector(doubleTapAction)];
     //播放事件
     [self.playerButton addTarget:self action:@selector(playerAction:) forControlEvents:UIControlEventTouchUpInside];
     //拖动--快进/退
     [self.playerSlier addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
     [self.playerSlier addTarget:self action:@selector(sliderDown:) forControlEvents:UIControlEventTouchDown];
     //链接播放失败点击重新加载事件
     [self.playerCenterLabel addTapCallBack:self sel:@selector(tapAgainPlayAction)];
     //非自动播放 播放事件
     [self.playImgView addTapCallBack:self sel:@selector(tapPlayAction)];
     
     //锁屏事件
     [self.lockButton addTarget:self action:@selector(lockAction:) forControlEvents:UIControlEventTouchUpInside];

}

/////////////////////////////////////////////////////视图事件区域////////////////////////////////////////////////////////////
/**
 *  非全屏事件(返回/更多)
 *
 *  @param sender 手势对象
 */
- (void)nofunllAction:(UIGestureRecognizer *)sender{
     NSInteger tag = sender.view.tag;
     if (tag == 1001) {
          if (self.backClickBlock){
               [self removeAllTimer];
               self.backClickBlock();
          };
     }else{
          if (self.moreClickBlock) self.moreClickBlock();
     }
}

#pragma mark -------- 移除所有持有对象的定时器 不关掉 会出现 无法移除观察者严重bug
- (void)removeAllTimer{
     
     [self removeRepeatsTimer];//退出播放器界面 关掉单击显示工具栏定时器
     [self removeRepeatsFastTimer];//退出播放器界面 关掉快进显示工具栏定时器
     [self removeSuViewtimer];//退出播放器界面 关掉检测父视图定时器
     [self removeSuViewDestroytimer]; //退出播放器界面 关掉检测父视图消失定时器
}

/**
 *  双击旋转屏幕
 *
 *  @param sender 手势对象
 */
- (void)doubleTapAction{
     
     if (self.lockButton.selected) return;//锁屏 关闭双击旋转
     
     UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
     if (orientation == UIInterfaceOrientationLandscapeRight ||orientation ==UIInterfaceOrientationLandscapeLeft) // home键靠左右
     {
         [self deviceOrientation:UIInterfaceOrientationPortrait annimation:YES];
     }
     if (orientation == UIInterfaceOrientationPortrait){
         [self deviceOrientation:UIInterfaceOrientationLandscapeRight annimation:YES];
     }
     
}

/**
 *  手动旋转屏幕
 *
 *  @param sender 手势对象
 */
- (void)zoneAction:(UIGestureRecognizer *)sender{
     NSInteger tag = sender.view.tag;
     //1003全屏 1004非全屏
     [self repeatsTimer];
     if (tag == 1003) {
          
          [self deviceOrientation:UIInterfaceOrientationLandscapeRight annimation:YES];
     }else{
          
          [self deviceOrientation:UIInterfaceOrientationPortrait annimation:YES];
          if (self.playerType == PlayerTypeOfFullScreen) {
               if (self.backClickBlock){
                    [self removeAllTimer];
                    self.backClickBlock();
               };
          }
     }
     //tag == 1003?[self deviceOrientation:UIInterfaceOrientationLandscapeRight]:[self deviceOrientation:UIInterfaceOrientationPortrait];
}

- (void)deviceOrientation:(UIInterfaceOrientation)orientation annimation:(BOOL)annimation{
     
     NSTimeInterval an = annimation?CH_annimationTime:0;
     [UIView animateWithDuration:an
                      animations:^{
                           
                           NSNumber *value = [NSNumber numberWithInt:orientation];
                           [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
                      }];
}

#pragma mark -------- 单击播放器中间空白区域事件

- (void)tapAction:(UIGestureRecognizer *)sender{
     if (sender.numberOfTouches != 1) return;
     self.tapShow?[self showView]:[self hideView];
     self.tapShow = !self.tapShow;
}

- (void)showView{
     
     if (self.isFullScreen && self.lockButton.selected) {
          [self showLockButton];
          return;
     }
     [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoHideLockButton) object:nil];
     [UIView animateWithDuration:CH_annimationTime animations:^{
          self.bottomView.alpha = self.topView.alpha = 1;
          [self.container viewWithTag:9999].alpha = [self.container viewWithTag:9998].alpha = 0.7;
          if (self.playerType == PlayerTypeOfNoNavigationBar) {
               [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
          }
          self.backView.alpha =  self.moreView.alpha  = self.playerType == PlayerTypeOfNoNavigationBar?1:0;
          self.lockButton.alpha = self.isFullScreen?1:0;
     }];
     [self repeatsTimer];
}

- (void)hideView{
     
     [UIView animateWithDuration:CH_annimationTime animations:^{
          self.bottomView.alpha = self.topView.alpha = self.backView.alpha = self.moreView.alpha = [self.container viewWithTag:9999].alpha = [self.container viewWithTag:9998].alpha = self.lockButton.alpha = 0;
          if (self.playerType == PlayerTypeOfNoNavigationBar) {
               [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
          }
     }];
     [self getZeroData];
}

- (void)autoHideLockButton{
     
     self.tapShow = YES;
     [UIView animateWithDuration:CH_annimationTime animations:^{
          self.lockButton.alpha = 0;
     }];
}

- (void)showLockButton{
     
     [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoHideLockButton) object:nil];
     [UIView animateWithDuration:CH_annimationTime animations:^{
          self.lockButton.alpha = 1;
     }];
     [self performSelector:@selector(autoHideLockButton) withObject:nil afterDelay:CH_showViewTime];
}

/**
 *  初始化(滑动)手势类型
 */
- (void)getZeroData{
     _gestureType = GestureTypeOfNone;
     _originalLocation = CGPointZero;
}


- (void)repeatsTimer{
     [self removeRepeatsTimer];
     WS(weakSelf);
     self.timer = [NSTimer ch_scheduledTimerWithTimeInterval:1.0f block:^{
          _timerNub++;
          if (_timerNub == CH_showViewTime) {
               [weakSelf manualHideView];
          }
     } repeats:YES];
}

- (void)removeRepeatsTimer{
     if (self.timer) {
          [self.timer invalidate];
          self.timer = nil;
          self.timerNub = 0;
     }
}

- (void)manualHideView{
     
     [self hideView];
     self.tapShow = YES;
     [self removeRepeatsTimer];
}

#pragma mark ------- 播放事件
/**
 *  播放事件
 *
 *  @param sender UIButton对象
 */
- (void)playerAction:(UIButton *)sender{

     !sender.selected?[self.player play]:[self.player pause];
     UIImage *img = !sender.selected?[UIImage imageNamed:CH_pauseIcon]:[UIImage imageNamed:CH_playIcon];
     [self.playerButton setImage:img forState:UIControlStateNormal];
     sender.selected = !sender.selected;
     [self repeatsTimer];
}

#pragma mark ------- 滑动块事件
- (void)sliderDown:(UISlider *)sender{
     [self.player pause];
     [self.playerButton setImage:[UIImage imageNamed:CH_playIcon] forState:UIControlStateNormal];
     self.playerButton.selected = NO;
     [self repeatsTimer];
}

- (void)sliderAction:(UISlider *)sender{
     
     //[[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(setIsDarw) object:nil];
     _isDarw = YES;
     
     CGFloat value = sender.value;
     if (value>=sender.maximumValue) value -= 3;
     CMTime time = CMTimeMake(value, 1);
     _currentValue = value;
     if (self.player.status != AVPlayerStatusReadyToPlay) return;
     WS(weasSelf);
     //快进
     [self.player seekToTime:time toleranceBefore:CMTimeMake(1, 30) toleranceAfter:CMTimeMake(1, 30) completionHandler:^(BOOL finished) {
          if (finished) [weasSelf.player play];
     }];
     [self.playerButton setImage:[UIImage imageNamed:CH_pauseIcon] forState:UIControlStateNormal];
     self.playerButton.selected = YES;
     [self repeatsTimer];
}

/**
 *  失败 重新播放事件
 */
- (void)tapAgainPlayAction{
     self.playerUrl = _playerUrl;
//     AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[self returnPalyerUrl] options:nil];
//     [self prepareToPlayAsset:asset];
}

/**
 *  关闭播放器
 */
- (void)closeAction{
     
     if (self.cellContainer) self.cellContainer.alpha = 1;
     [self removeAllTimer];
     [self removeObserver];
     
}

- (void)lockAction:(UIButton *)sender{
     sender.selected = !sender.selected;
     sender.selected?[self manualHideView]:[self showView];
     [[NSUserDefaults standardUserDefaults] setObject:@(sender.selected) forKey:CHPlayer_LockScreen];
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////观察者区域////////////////////////////////////////////////////////////

#pragma mark -------- 添加观察者
/**
 *  添加观察者
 */
- (void)addPlayerObserver{
     
     [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
     [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
     [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];// 监听playbackBufferEmpty属性
     [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];// 监听playbackLikelyToKeepUp属性
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}

/**
 *  观察值变化处理
 *
 *  @param keyPath 观察路径
 *  @param object  观察对象
 *  @param change  变化的属性对象
 *  @param context 观察上下文
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
     
     if ([keyPath isEqualToString:@"status"]) {//观察播放状态
          AVPlayerItem *playerItem = (AVPlayerItem *)object;
          [_activityIndicatorView stopAnimating];
          _activityIndicatorView.hidden = YES;
          if ([playerItem status] == AVPlayerStatusReadyToPlay) {
               CMTime duration = self.playerItem.duration;// 获取视频总长度
               [self customVideoSlider:duration];// 自定义UISlider外观
               CGFloat  total = CMTimeGetSeconds(duration);
               _totalTime = [NSString stringWithFormat:@"%02d:%02d",(int) total / 60 , (int )total % 60];
               NSString *cuTime = [NSString stringWithFormat:@"00:00/%@",_totalTime];
               self.timeLabel.text = cuTime;
               self.timeLength     = [self returnTimeWidth];
               [self monitoringPlayback:self.playerItem];// 监听播放状态
          } else if ([playerItem status] == AVPlayerStatusFailed) {
               self.playerCenterLabel.hidden = NO;
          }
     }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {//缓存

          CMTime duration = self.playerItem.duration;
          CGFloat totalDuration = CMTimeGetSeconds(duration);
          double totalTime   = floor(totalDuration);
          
          if (self.cMTimeRange != totalTime) {
               self.cMTimeRange = floor([self availableDuration]);// 计算缓冲进度
               CGFloat value = self.cMTimeRange / totalDuration;
               [self.progressView setProgress:value animated:YES];
          }else{
               [self.progressView setProgress:1 animated:YES];
          }
          
     }else if([keyPath isEqualToString:@"playbackBufferEmpty"]){
          
          if (self.playerItem.playbackBufferEmpty) {//空缓存
               [_activityIndicatorView startAnimating];
               _activityIndicatorView.hidden = NO;
          }
     }else if([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
          
          if (self.playerItem.playbackLikelyToKeepUp) {//空缓存
               [_activityIndicatorView stopAnimating];
               _activityIndicatorView.hidden = YES;
          }
     }
}


/**
 *  移除观察者
 */
- (void)removeObserver{
     
     [self.playerItem removeObserver:self forKeyPath:@"status"];
     [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
     [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
     [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
     [self.player.currentItem cancelPendingSeeks];
     [self.player.currentItem.asset cancelLoading];
     [self.player replaceCurrentItemWithPlayerItem:nil];
     self.playerItem = nil;
     self.player     = nil;
     self.playbackTimeObserver = nil;
     
}


- (CGFloat)returnTimeWidth{
     
     NSDictionary *fontInfo   = @{NSFontAttributeName: [UIFont systemFontOfSize:11]};
     CGFloat timeWidth = [self.timeLabel.text widthWithStringAttribute:fontInfo];
     return timeWidth+2;
}

/**
 *  设置self.playerSlier最大值
 *
 *  @param duration maximumValue == 最大值
 */
- (void)customVideoSlider:(CMTime)duration {
     
     CGFloat maximumValue = CMTimeGetSeconds(duration);
     self.playerSlier.maximumValue = maximumValue == 0?1:maximumValue;
}

/**
 *  计算缓冲进度
 *
 *  @return 缓冲的进度值
 */
- (double)availableDuration {
     
     NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
     CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
     double startSeconds = CMTimeGetSeconds(timeRange.start);
     double durationSeconds = CMTimeGetSeconds(timeRange.duration);
     double result = startSeconds + durationSeconds;// 计算缓冲总进度
     return result;
}

//监测播放器播放进度
- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
     
     WS(weakSelf);
     if (!self.playbackTimeObserver) {
          
          self.playbackTimeObserver  = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
               CGFloat current = playerItem.currentTime.value/playerItem.currentTime.timescale;// 计算当前在第几秒
               if (weakSelf.isDarw) {
                    [weakSelf.playerSlier setValue:weakSelf.currentValue animated:YES];
                    [weakSelf performSelector:@selector(setIsDarw) withObject:nil afterDelay:CH_annimationTime];
               }else{
                    [weakSelf updateVideoSlider:current];
               }
               NSString *cuTime = [NSString stringWithFormat:@"%02d:%02d/%@",(int)current / 60,(int)current % 60,weakSelf.totalTime];
               weakSelf.timeLabel.text = cuTime;
               if ([weakSelf returnTimeWidth]>= weakSelf.timeLength) {
                    [weakSelf upTimeLabelWidth];
               }
          }];
     }
}

- (void)setIsDarw{
     _isDarw = NO;
}

- (void)updateVideoSlider:(CGFloat)currentSecond{
     [self.playerSlier setValue:currentSecond animated:YES];
     
}

#pragma mark ----------- 播放结束
- (void)moviePlayDidEnd:(NSNotification *)sender{
     WS(weakSelf);
     [self.player seekToTime:CMTimeMake(0, 1) completionHandler:^(BOOL finished) {
          [weakSelf.player pause];
          [weakSelf.playerButton setImage:[UIImage imageNamed:CH_playIcon] forState:UIControlStateNormal];
          if (weakSelf.playerEndBlock &&!weakSelf.playerFullEndToBackBlock) weakSelf.playerEndBlock();
          if (weakSelf.playerType == PlayerTypeOfFullScreen) {
               [self deviceOrientation:UIInterfaceOrientationPortrait annimation:YES];
               [self removeAllTimer];
               if (weakSelf.playerFullEndToBackBlock &&!weakSelf.playerEndBlock) weakSelf.playerFullEndToBackBlock();
          }
     }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////视图初始化//////////////////////////////////////////////////////////////
#pragma mark ----------- 视图初始化
- (void)initialization{
     
     //视图容器
     self.container = [UIView new];
     self.container.backgroundColor = [UIColor clearColor];
     [self addSubview:self.container];
     [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
          make.edges.equalTo(self);
     }];
     
     UIView *topAlphaBgView = [UIView new];
     topAlphaBgView.backgroundColor = [UIColor blackColor];
     topAlphaBgView.alpha = 0.7;
     topAlphaBgView.hidden = YES;
     topAlphaBgView.tag = 9999;
     [self.container addSubview:topAlphaBgView];
     [topAlphaBgView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.right.top.left.equalTo(self.container);
          make.height.equalTo(@(56));
     }];
     
     UIView *bottomAlphaBgView = [UIView new];
     bottomAlphaBgView.backgroundColor = [UIColor blackColor];
     bottomAlphaBgView.alpha = 0.7;
     bottomAlphaBgView.tag = 9998;
     [self.container addSubview:bottomAlphaBgView];
     [bottomAlphaBgView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.left.right.equalTo(self.container);
          make.height.equalTo(@(40));
          make.bottom.equalTo(self.container.mas_bottom);
     }];
     
     MASAttachKeys(bottomAlphaBgView);
     MASAttachKeys(self);
     
     //加载视图
     self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
     self.activityIndicatorView.hidden = YES;
     [self.container addSubview:self.activityIndicatorView];
     [self.activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.centerY.equalTo(self.container.mas_centerY);
          make.centerX.equalTo(self.container.mas_centerX);
          make.height.with.equalTo(@(20));
     }];
     
     //点击视图
     self.tapView = [UIView new];
     self.tapView.backgroundColor = [UIColor clearColor];
     [self.container addSubview:self.tapView];
     [self.tapView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.edges.equalTo(self.container);
     }];
     
     if (self.playerType != PlayerTypeOfFullScreen) {//全屏类型 无锁屏控件
          
          //锁屏 全屏才显示
          self.lockButton =[UIButton buttonWithType:UIButtonTypeCustom];
          [self.lockButton setImage:[UIImage imageNamed:CH_full_unLockIcon] forState:UIControlStateNormal];
          [self.lockButton setImage:[UIImage imageNamed:CH_full_lockIcon] forState:UIControlStateHighlighted];
          [self.lockButton setImage:[UIImage imageNamed:CH_full_lockIcon] forState:UIControlStateSelected];
          self.lockButton.contentEdgeInsets = UIEdgeInsetsMake(5, 0, -5, 0);
          [self.container addSubview:self.lockButton];
          self.lockButton.alpha = 0;
          [self.lockButton mas_makeConstraints:^(MASConstraintMaker *make) {
               make.left.equalTo(@(20));
               make.centerY.equalTo(self.container.mas_centerY);
               make.height.with.equalTo(@(70));
          }];

     }
     
     //头部模块
     self.topView = [UIView new];
     self.topView.hidden = YES;
     self.topView.backgroundColor = [UIColor clearColor];
     [self.container addSubview:self.topView];
     [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.edges.equalTo(topAlphaBgView);
     }];
     
     if (self.playerType == PlayerTypeOfNoNavigationBar) {
          CGFloat backViewWidth = 34;
          //非全屏返回
          self.backView = [UIImageView new];
          self.backView.alpha = 0.8;
          self.backView.layer.masksToBounds = YES;
          self.backView.layer.cornerRadius = backViewWidth/2.0f;
          self.backView.backgroundColor = [UIColor blackColor];
          [self.container addSubview:self.backView];
          [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
               make.top.equalTo(@(25));
               make.left.equalTo(@(13));
               make.width.height.equalTo(@(backViewWidth));
          }];
          UIImageView *imgIcon = [UIImageView new];
          imgIcon.image = [UIImage imageNamed:CH_nofull_backIcon];
          [self.backView addSubview:imgIcon];
          [imgIcon mas_makeConstraints:^(MASConstraintMaker *make) {
               make.top.left.equalTo(self.backView);
               make.width.height.equalTo(self.backView.mas_width);
          }];
          
          //非全屏更多
          self.moreView = [UIImageView new];
          self.backView.alpha = self.backView.alpha;
          self.moreView.layer.masksToBounds = YES;
          self.moreView.layer.cornerRadius = backViewWidth/2.0f;
          self.moreView.backgroundColor = [UIColor blackColor];
          [self.container addSubview:self.moreView];
          [self.moreView mas_makeConstraints:^(MASConstraintMaker *make) {
               make.top.equalTo(self.backView.mas_top);
               make.right.equalTo(self.container.mas_right).offset(-13);
               make.width.height.equalTo(self.backView.mas_width);
          }];
          UIImageView *moreIcon = [UIImageView new];
          moreIcon.image = [UIImage imageNamed:CH_nofull_moreIcon];
          [self.moreView addSubview:moreIcon];
          [moreIcon mas_makeConstraints:^(MASConstraintMaker *make) {
               make.top.left.equalTo(self.moreView);
               make.width.height.equalTo(self.moreView.mas_width);
          }];
     }
     
     //全屏的返回
     self.backImageButton = [UIImageView new];
     [self.topView addSubview:self.backImageButton];
     [self.backImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(self.topView);
          make.left.equalTo(@(10));
          make.width.height.equalTo(@(50));
     }];
     UIImageView *backImageButtons = [UIImageView new];
     backImageButtons.contentMode = UIViewContentModeScaleAspectFit;
     backImageButtons.image = [UIImage imageNamed:CH_full_backIcon];
     [self.backImageButton addSubview:backImageButtons];
     [backImageButtons mas_makeConstraints:^(MASConstraintMaker *make) {
          make.left.equalTo(@(10));
          make.top.equalTo(self.backImageButton.mas_centerY).offset(2);
          make.width.height.equalTo(@(22));
     }];
     
     //全屏标题
     self.titleLabel = [UILabel new];
     self.titleLabel.textColor = [UIColor whiteColor];
     self.titleLabel.font = [UIFont systemFontOfSize:15];
     [self.topView addSubview:self.titleLabel];
     [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.centerY.equalTo(backImageButtons.mas_centerY);
          make.left.equalTo(self.backImageButton.mas_right).offset(5);
          make.right.equalTo(self.topView.mas_right).offset(-20);
     }];
     

     //底部模块
     self.bottomView = [UIView new];
     self.bottomView.backgroundColor = [UIColor clearColor];
     [self.container addSubview:self.bottomView];
     [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.edges.equalTo(bottomAlphaBgView);
     }];
     //播放按钮
     self.playerButton = [UIButton buttonWithType:UIButtonTypeCustom];
     [self.playerButton setImage:[UIImage imageNamed:CH_playIcon] forState:UIControlStateNormal];
     [self.bottomView addSubview:self.playerButton];
     [self.playerButton mas_makeConstraints:^(MASConstraintMaker *make) {
          make.left.equalTo(@(5));
          make.top.equalTo(self.bottomView);
          make.width.height.equalTo(@(40));
     }];
     
     //全屏按钮
     self.zoneView = [UIView new];
     self.zoneView.backgroundColor = [UIColor clearColor];
     [self.bottomView addSubview:self.zoneView];
     [self.zoneView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.right.equalTo(self.bottomView.mas_right).offset(-2);
          make.top.equalTo(self.bottomView);
          make.width.height.equalTo(self.bottomView.mas_height);
     }];
     UIImageView *zoneImg = [UIImageView new];
     zoneImg.userInteractionEnabled = YES;
     zoneImg.contentMode = UIViewContentModeScaleAspectFit;
     zoneImg.image = [UIImage imageNamed:CH_nofull_zoomIcon];
     [self.zoneView addSubview:zoneImg];
     [zoneImg mas_makeConstraints:^(MASConstraintMaker *make) {
          make.left.equalTo(self.zoneView);
          make.centerY.equalTo(self.zoneView.mas_centerY);
          make.width.equalTo(self.zoneView.mas_width);
          make.height.equalTo(@(18));
     }];
     
     
     //选集
     self.selectLabel = [UILabel new];
     self.selectLabel.hidden = YES;
     self.selectLabel.textAlignment = NSTextAlignmentCenter;
     self.selectLabel.text = @"选集";
     self.selectLabel.textColor = [UIColor whiteColor];
     self.selectLabel.font = [UIFont systemFontOfSize:16];
     self.selectLabel.backgroundColor = [UIColor clearColor];
     [self.bottomView addSubview:self.selectLabel];
     [self.selectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.right.equalTo(self.bottomView.mas_right).offset(-10);
          make.top.equalTo(self.bottomView);
          make.width.height.equalTo(self.bottomView.mas_height);
     }];
     
     //高清
     self.highLabel = [UILabel new];
     self.highLabel.hidden = YES;
     self.highLabel.textAlignment = NSTextAlignmentCenter;
     self.highLabel.text = @"高清";
     self.highLabel.textColor = [UIColor whiteColor];
     self.highLabel.font = [UIFont systemFontOfSize:16];
     self.highLabel.backgroundColor = [UIColor clearColor];
     [self.bottomView addSubview:self.highLabel];
     [self.highLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.right.equalTo(self.selectLabel.mas_left).offset(-10);
          make.top.equalTo(self.bottomView);
          make.width.height.equalTo(self.selectLabel.mas_height);
     }];
     
     //播放时间
     self.timeLabel = [UILabel new];
     self.timeLabel.textAlignment = NSTextAlignmentRight;
     self.timeLabel.textColor = [UIColor whiteColor];
     self.timeLabel.font = [UIFont systemFontOfSize:11];
     self.timeLabel.text = @"00:00/00:00";
     //self.timeLabel.textAlignment = NSTextAlignmentCenter;
     [self.bottomView addSubview:self.timeLabel];
     [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.right.equalTo(self.zoneView.mas_left).offset(-5);
          make.centerY.equalTo(self.bottomView.mas_centerY);
     }];
     
     //播放缓存条
     self.progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
     self.progressView.tintColor = _cacheBarColor;
     self.progressView.backgroundColor = [UIColor clearColor];
     [self.bottomView addSubview:self.progressView];
     [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.right.equalTo(self.timeLabel.mas_left).offset(-12);
          make.left.equalTo(self.playerButton.mas_right).offset(5);
          make.centerY.equalTo(self.bottomView.mas_centerY);
          make.height.equalTo(@(2));
     }];
     
     //播放进度条(拖动)
     self.playerSlier = [[UISlider alloc] initWithFrame:CGRectZero];
     self.playerSlier.minimumTrackTintColor = _playedColor;
     self.playerSlier.maximumTrackTintColor = [UIColor clearColor];
     [self.playerSlier setThumbImage:[UIImage imageNamed:CH_sliderIcon] forState:UIControlStateNormal];
     self.playerSlier.minimumValue = 0.0;
     self.playerSlier.continuous = NO;
     [self.bottomView addSubview:self.playerSlier];
     [self.playerSlier mas_makeConstraints:^(MASConstraintMaker *make) {
          make.right.equalTo(self.progressView.mas_right);
          make.left.equalTo(self.progressView.mas_left);
          make.centerY.equalTo(self.bottomView.mas_centerY).offset(-1);
          make.height.equalTo(@(4));
     }];
     
     //播放器中间提示文本
     self.playerCenterLabel = [UILabel new];
     self.playerCenterLabel.textAlignment = NSTextAlignmentCenter;
     self.playerCenterLabel.font = [UIFont systemFontOfSize:17];
     self.playerCenterLabel.textColor = [UIColor whiteColor];
     self.playerCenterLabel.hidden = YES;
     self.playerCenterLabel.text = playFaileInfo;
     [self.container addSubview:self.playerCenterLabel];
     [self.playerCenterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.centerY.equalTo(self.container.mas_centerY);
          make.left.right.equalTo(self.container);
     }];
     
     //快进模块
     self.fastBgView = [UIImageView new];
     self.fastBgView.backgroundColor = [UIColor clearColor];
     self.fastBgView.layer.masksToBounds = YES;
     self.fastBgView.layer.cornerRadius = 5;
     self.fastBgView.alpha = 0;
     [self.container addSubview:self.fastBgView];
     [self.fastBgView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.centerX.equalTo(self.container.mas_centerX);
          make.centerY.equalTo(self.container.mas_centerY);
          make.width.equalTo(@(160));
          make.height.equalTo(@(110));
     }];
     
     //快进时间条
     self.fastImgView = [UIImageView new];
     self.fastImgView.backgroundColor = [UIColor clearColor];
     self.fastImgView.image = [UIImage imageNamed:CH_fastForwardIcon];
     [self.fastBgView addSubview:self.fastImgView];
     [self.fastImgView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(@(20));
          make.centerX.equalTo(self.fastBgView.mas_centerX);
          make.width.equalTo(@(55));
          make.height.equalTo(@(35));
     }];
     
     //快进时间文本
     self.fastLabel = [UILabel new];
     self.fastLabel.textAlignment = NSTextAlignmentCenter;
     self.fastLabel.textColor = [UIColor whiteColor];
     self.fastLabel.font = [UIFont systemFontOfSize:15];
     self.fastLabel.text = @"00:00/00:00";
     [self.fastBgView addSubview:self.fastLabel];
     [self.fastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(self.fastImgView.mas_bottom).offset(20);
          make.centerX.equalTo(self.fastBgView.mas_centerX);
          make.left.right.equalTo(self.fastBgView);
     }];

     if (!self.autoPlay) {//非自动播放
          //视图容器
          self.cellContainer = [UIView new];
          self.cellContainer.backgroundColor = [UIColor blackColor];
          self.cellContainer.alpha = 1;
          [self.container addSubview:self.cellContainer];
          [self.cellContainer mas_makeConstraints:^(MASConstraintMaker *make) {
               make.edges.equalTo(self.container);
          }];
          
          UIImageView* playImgView = [UIImageView new];
          playImgView.layer.masksToBounds = YES;
          playImgView.contentMode = UIViewContentModeScaleAspectFill;
          playImgView.image = [UIImage imageNamed:CH_cell_playIcon];
          [self.cellContainer addSubview:playImgView];
          [playImgView mas_makeConstraints:^(MASConstraintMaker *make) {
               make.centerX.equalTo(self.cellContainer.mas_centerX);
               make.centerY.equalTo(self.cellContainer.mas_centerY);
               make.width.height.equalTo(@(41.5));
          }];
          self.playImgView = playImgView;
          
          self.bottomView.alpha = self.topView.alpha = self.backView.alpha = self.moreView.alpha = [self.container viewWithTag:9999].alpha = [self.container viewWithTag:9998].alpha = 0;
          self.tapShow = YES;
          
          if (self.playerType == PlayerTypeOfNoNavigationBar) {
               CGFloat backViewWidth = 34;
               //非全屏返回
               UIImageView *backView = [UIImageView new];
               backView.alpha = 0.8;
               backView.tag = 1001;
               backView.layer.masksToBounds = YES;
               backView.layer.cornerRadius = backViewWidth/2.0f;
               backView.layer.borderWidth  = 1;
               backView.layer.borderColor  = [UIColor whiteColor].CGColor;
               backView.backgroundColor = [UIColor blackColor];
               [self.cellContainer addSubview:backView];
               [backView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(@(25));
                    make.left.equalTo(@(13));
                    make.width.height.equalTo(@(backViewWidth));
               }];
               UIImageView *imgIcon = [UIImageView new];
               imgIcon.image = [UIImage imageNamed:CH_nofull_backIcon];
               [backView addSubview:imgIcon];
               [imgIcon mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.left.equalTo(self.backView);
                    make.width.height.equalTo(self.backView.mas_width);
               }];
               [backView addTapCallBack:self sel:@selector(nofunllAction:)];
          }
     }
     
     //添加点击事件
     [self addViewTapAction];
}
/////////////////////////////////////////////////视图初始化//////////////////////////////////////////////////////////////

/////////////////////////////////////滑动手势(左右快进 上下调节音量)//////////////////////////////////////////////
#pragma mark ----------- 滑动手势处理
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
     _originalLocation = CGPointZero;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
     
     if (self.cellContainer.alpha != 0 && self.cellContainer)return;
     if (self.lockButton.selected) return;//锁屏
     
     UITouch *touch = [touches anyObject];
     CGPoint currentLocation = [touch locationInView:self];
     CGFloat offset_x = currentLocation.x - _originalLocation.x;
     CGFloat offset_y = currentLocation.y - _originalLocation.y;
     if (CGPointEqualToPoint(_originalLocation,CGPointZero)) {
          _originalLocation = currentLocation;
          return;
     }
     _originalLocation = currentLocation;
     CGRect frame = self.tapView.bounds;
     if (_gestureType == GestureTypeOfNone) {
          if ((currentLocation.x > frame.size.height*0.8) && (ABS(offset_x) <= ABS(offset_y))){            _gestureType = GestureTypeOfVolume;
          }else if ((currentLocation.x < frame.size.height*0.2) && (ABS(offset_x) <= ABS(offset_y))){            _gestureType = GestureTypeOfBrightness;
          }else if ((ABS(offset_x) > ABS(offset_y))) {
               _gestureType = GestureTypeOfProgress;
          }
     }
     if ((_gestureType == GestureTypeOfProgress) && (ABS(offset_x) > ABS(offset_y))) {//快进
          [self showFastView];
          offset_x > 0?[self fastPlay:YES]:[self fastPlay:NO];
     }else if ((_gestureType == GestureTypeOfVolume) && (currentLocation.x > frame.size.height*0.8) && (ABS(offset_x) <= ABS(offset_y))){//调节声音
          offset_y > 0?[self volumeAdd:-CH_brightnessStep]:[self volumeAdd:CH_brightnessStep];
     }else if ((_gestureType == GestureTypeOfBrightness) && (currentLocation.x < frame.size.height*0.2) && (ABS(offset_x) <= ABS(offset_y))){//调节亮度
          offset_y > 0?[self brightnessAdd:-CH_brightnessStep]:[self brightnessAdd:CH_brightnessStep];
     }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
     [self getZeroData];
}

//亮度增加
- (void)brightnessAdd:(CGFloat)step{
     [UIScreen mainScreen].brightness += step;
}

#pragma mark ----------- 快进,快退
- (void)fastPlay:(BOOL)isFast{
     [self.player pause];
     NSInteger value = self.playerSlier.value;
     if (value<0) return;
     NSString *doSomething;
     doSomething = isFast?CH_fastForwardIcon:CH_rewindIcon;
     value       = isFast?(value+CH_fastSecond):(value-CH_fastSecond);
     self.fastImgView.image = [UIImage imageNamed:doSomething];
     CMTime time = CMTimeMake(value, 1);
     WS(weakSelf);
     if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
          [self.player seekToTime:time toleranceBefore:CMTimeMake(1, 30) toleranceAfter:CMTimeMake(1, 30) completionHandler:^(BOOL finished) {
               if (finished) {
                    [weakSelf.player play];
                    [weakSelf getZeroData];
               }
          }];
          [self.playerButton setImage:[UIImage imageNamed:CH_pauseIcon] forState:UIControlStateNormal];
          self.playerButton.selected = YES;
     }
}

- (void)repeatsFastTimer{
     [self removeRepeatsFastTimer];
     WS(weakSelf);
     self.fastTimer = [NSTimer ch_scheduledTimerWithTimeInterval:1.0f
                                                           block:^{
                                                                _fastTimerCount++;
                                                                if (_fastTimerCount == 1) {
                                                                     [weakSelf hiddenFastView];
                                                                     [weakSelf removeRepeatsFastTimer];
                                                                }
                                                           } repeats:YES];
}

- (void)removeRepeatsFastTimer{
     //DLog(@"移除快进计时器");
     if (self.fastTimer) {
          [self.fastTimer invalidate];
          self.fastTimerCount = 0;
          self.fastTimer = nil;
     }
}

- (void)showFastView{
     self.fastLabel.text = self.timeLabel.text;
     [UIView animateWithDuration:CH_annimationTime animations:^{
          self.fastBgView.alpha = 1;
     }];
     [self repeatsFastTimer];
}

- (void)hiddenFastView{
     [UIView animateWithDuration:CH_annimationTime animations:^{
          self.fastBgView.alpha = 0;
     }];
     [self getZeroData];
}

#pragma mark --------------- 增加音量
- (void)volumeAdd:(CGFloat)step{
     [MPMusicPlayerController applicationMusicPlayer].volume += step;
}
/////////////////////////////////////滑动手势(左右快进 上下调节音量)//////////////////////////////////////////////


@end



