//
//  RightViewController.m
//  CHPlayer
//
//  Created by Cher on 16/6/12.
//  Copyright © 2016年 Hxc. All rights reserved.
//

#import "RightViewController.h"
#import "CHPlayerView.h"
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self


@interface RightViewController ()

@property (strong, nonatomic) CHPlayerView * playerView;

@end

@implementation RightViewController

- (void)viewWillAppear:(BOOL)animated{
     [super viewWillAppear:animated];
     [[NSNotificationCenter defaultCenter] postNotificationName:CHPlayerContinuePlayNotification object:self.playerView];
}

- (void)viewWillDisappear:(BOOL)animated{
     [super viewWillDisappear:animated];
     [[NSNotificationCenter defaultCenter] postNotificationName:CHPlayerStopPlayNotification object:self.playerView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     
     NSString *strUrl = @"http://he.yinyuetai.com/uploads/videos/common/080A01550943F9C13EED24FBF1933A39.flv?sc=aabb162ef563e9b2&br=3106&rd=iOS";
     CGRect rect = CGRectMake((self.view.frame.size.width-300)/2.0f, 100, 300, 200);
     CHPlayerView * playerView = [[CHPlayerView alloc] initWithFrame:rect playerType:PlayerTypeOfNavigationBar autoPlay:YES];
     [self.view addSubview:playerView];
     self.playerView = playerView;
     playerView.playerUrl = strUrl;
     playerView.videoTitle = @"Taylor Swift";
     
     WS(weakSelf);

     //可选 ===
     playerView.playerEndBlock = ^(){
          weakSelf.playerView.playerUrl = @"http://hc.yinyuetai.com/uploads/videos/common/5B04015509380A6B14588BC77BAC7BC8.flv?sc=fa826f4ffca022e1&br=769&rd=iOS";
          weakSelf.playerView.videoTitle = @"Taylor Swift style!!";
     };
}

- (void)backAction{
     [self.navigationController popViewControllerAnimated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//设置是否支持自动旋转 默认开启 == 配合锁屏
- (BOOL)shouldAutorotate{
     NSNumber *lock = [[NSUserDefaults standardUserDefaults] objectForKey:CHPlayer_LockScreen];
     return ![lock boolValue];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
