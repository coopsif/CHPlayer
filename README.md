播放器设定了三种类型：

1.仿爱奇艺,芒果,优酷播放器(无导航栏)

2.带导航栏

3.直接全屏

类型1:

![image](https://github.com/coopsif/CHPlayer/blob/master/CHPlayer/CHPlayer/gif/noNavigation1.gif)

支持双击旋转屏幕, 支持左右滑动快进退,(左半部分)上下滑动调节屏幕亮度,(右半部分)上下滑动调节音量。（真机调试才能看到调节系统声音控件）

![image](https://github.com/coopsif/CHPlayer/blob/master/CHPlayer/CHPlayer/gif/noNavigation2.gif)

支持拖动进度条播放

![image](https://github.com/coopsif/CHPlayer/blob/master/CHPlayer/CHPlayer/gif/noNavigation3.gif)

支持自动旋转屏幕

自动旋转条件：app应用设置支持横屏旋转，将iPhone自动旋转设置打开。

类型2：

![image](https://github.com/coopsif/CHPlayer/blob/master/CHPlayer/CHPlayer/gif/navigation1.gif)

带导航栏

![image](https://github.com/coopsif/CHPlayer/blob/master/CHPlayer/CHPlayer/gif/navigation2.gif)

带导航自动旋转

类型3：

![image](https://github.com/coopsif/CHPlayer/blob/master/CHPlayer/CHPlayer/gif/fullScreen.gif)

直接全屏

当然，tabbar控制器下 播放器也完美运行。这里就不演示了。



用法:


  1.info.plist 文件中 加入
  
     <key>NSAppTransportSecurity</key>
	   <dict>
		 <key>NSAllowsArbitraryLoads</key>
		 <true/>
	   </dict>
	   <key>UIViewControllerBasedStatusBarAppearance</key>
	   <false/>
	
2.工程中 Device Orientation 默认勾选三个旋转方向(Portrait,Landscape Left,landscape Right)
	
3.本工程需要用到 Masonry 自动布局 请将 Masonry包导入本工程 github地址:https://github.com/SnapKit/Masonry
	
4.工程内部所有的导航控制器均要继承于AutorotateNavigaVC,工程内部所有的tab控制器均要继承于AutorotateTabbarVC
	
5.工程中不需要自动旋转的控制器请这样设置
	
    // 设置是否支持自动旋转 默认开启
  
    - (BOOL)shouldAutorotate{
     return YES;
    }
    
    // 支持旋转的方向

    - (UIInterfaceOrientationMask)supportedInterfaceOrientations{
     return UIInterfaceOrientationMaskPortrait;
    }

  6.创建播放器

     NSString *strUrl = @"http://he.yinyuetai.com/uploads/videos/common/080A01550943F9C13EED24FBF1933A39.flv?sc=aabb162ef563e9b2&br=3106&rd=iOS";
     //创建播放器 设置播放器类型playerType 是否自动播放autoPlay
     CHPlayerView * playerView = [[CHPlayerView alloc] initWithFrame:rect playerType:self.type autoPlay:YES];
     [self.view addSubview:playerView];
     self.playerView = playerView;
     //设置播放链接
     playerView.playerUrl = strUrl;
     //设置播放器标题
     playerView.videoTitle = @"惊天魔盗团主题曲";
     //设置播放器额外属性
     playerView.playedColor   = [UIColor greenColor];
     playerView.cacheBarColor = [UIColor cyanColor];
     //设置播放移动小圆点 在 CHPlayerHeader.h 文件中修改对应的图片名称 并放入图片资源即可
     //非全屏返回
     playerView.backClickBlock = ^(){
          [weakSelf backAction];
     };
     //非全屏更多选项
     playerView.moreClickBlock = ^(){
          weakSelf.playerView.playerUrl = @"http://hd.yinyuetai.com/uploads/videos/common/B47E013A6407D27C66A5DF307657F2B3.flv?sc=741fb0d8a9b7028c&br=1099&rd=iOS";
          weakSelf.playerView.videoTitle = @"2010超时代演唱会";
     };
     //播放结束回调
     playerView.playerEndBlock = ^(){
          weakSelf.playerView.playerUrl = @"http://he.yinyuetai.com/uploads/videos/common/080A01550943F9C13EED24FBF1933A39.flv?sc=aabb162ef563e9b2&br=3106&rd=iOS";
          weakSelf.playerView.videoTitle = @"Taylor Swift style!!";
     };

更多详情 请参考demo.
如有疑问 请issues.
