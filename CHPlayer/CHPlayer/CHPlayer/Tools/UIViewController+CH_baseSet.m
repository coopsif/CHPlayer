//
//  UIViewController+CH_baseSet.m
//  CHPlayer
//
//  Created by Cher on 16/6/14.
//  Copyright © 2016年 Hxc. All rights reserved.
//

#import "UIViewController+CH_baseSet.h"
#import <objc/runtime.h>
@implementation UIViewController (CH_baseSet)

+(void)load{
     
     static dispatch_once_t onceToken;
     dispatch_once(&onceToken, ^{
          
          Class cla = [self class];
          SEL orgSel = @selector(viewDidLoad);
          SEL newSel = @selector(cher_viewDidLoad);
          Method orgMethod = class_getInstanceMethod(cla, orgSel);
          Method newMethod = class_getInstanceMethod(cla, newSel);
          BOOL didAddMethod = class_addMethod(cla, orgSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
          if (didAddMethod) {
               class_replaceMethod(cla, newSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
          }else{
               method_exchangeImplementations(orgMethod, newMethod);
          }
     });
}

#pragma mark - Method Swizzling
- (void)cher_viewDidLoad{
     //设置横屏 显示状态栏
     [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
     [[UIApplication sharedApplication] setStatusBarHidden: NO withAnimation:UIStatusBarAnimationNone];
     //关闭自动适应ScrollViewInsets 如果部分控制器需要开启  请将该设置需要开启的控制器即可 
     self.automaticallyAdjustsScrollViewInsets = NO;
     [self cher_viewDidLoad];
}

@end
