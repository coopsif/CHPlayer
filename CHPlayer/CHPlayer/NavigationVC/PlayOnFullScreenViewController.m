//
//  PlayOnFullScreenViewController.m
//  CHPlayer
//
//  Created by Cher on 16/6/17.
//  Copyright © 2016年 Hxc. All rights reserved.
//

#import "PlayOnFullScreenViewController.h"
#import "CHPlayerView.h"
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self

@interface PlayOnFullScreenViewController ()

@property (strong, nonatomic) CHPlayerView * playerView;

@end

@implementation PlayOnFullScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     
     
     NSString *strUrl = @"http://he.yinyuetai.com/uploads/videos/common/080A01550943F9C13EED24FBF1933A39.flv?sc=aabb162ef563e9b2&br=3106&rd=iOS";
     CHPlayerView * playerView = [[CHPlayerView alloc] initWithFrame:self.view.bounds playerType:PlayerTypeOfFullScreen autoPlay:YES];
     [self.view addSubview:playerView];
     self.playerView = playerView;
     
     playerView.playerUrl = strUrl;
     playerView.videoTitle = @"Taylor Swift";
     
     WS(weakSelf);
#warning 全屏必须调用 backClickBlock 否则无法pop（手动pop）
     playerView.backClickBlock = ^(){
          [weakSelf backAction];
     };

     //播放结束 可选 === 该回调适合播放结束继续播放下个链接 不允许pop返回
     playerView.playerEndBlock = ^(){
//          weakSelf.playerView.playerUrl = @"http://hc.yinyuetai.com/uploads/videos/common/5B04015509380A6B14588BC77BAC7BC8.flv?sc=fa826f4ffca022e1&br=769&rd=iOS";
//          weakSelf.playerView.videoTitle = @"Taylor Swift style!!";
          [weakSelf backAction];//错误的写法！
     };

     //播放结束pop返回 该回调只允许pop返回（自动pop）
     playerView.playerFullEndToBackBlock = ^(){
          [weakSelf backAction];
     };

#warning playerEndBlock playerFullEndToBackBlock 两者不能并存 根据需求选择其中回调
     
     
}

- (void)backAction{
     [self.navigationController popViewControllerAnimated:YES];
}


/*************    默认全屏控制器 旋转配置  *************/

//默认开启自动旋转
- (BOOL)shouldAutorotate{
     return YES;
}

// 支持旋转的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
     return (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight);
}



@end
