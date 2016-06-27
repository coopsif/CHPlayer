//
//  UIView+CH_tapAction.h
//  CHPlayer
//
//  Created by Cher on 16/6/14.
//  Copyright © 2016年 Hxc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CH_tapAction)

//添加单击手势事件
- (void)addTapCallBack:(id)target sel:(SEL)selector;

//添加双击手势事件
- (void)addDoubleTapCallBack:(id)target sel:(SEL)selector;

@end
