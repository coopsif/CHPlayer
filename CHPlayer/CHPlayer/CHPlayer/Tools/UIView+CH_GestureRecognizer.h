//
//  UIView+CH_GestureRecognizer.h
//  CHPlayer
//
//  Created by Cher on 16/6/29.
//  Copyright © 2016年 Hxc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CH_GestureRecognizer)

//添加单击手势事件
- (void)addTapCallBack:(id)target sel:(SEL)selector;

//添加双击手势事件
- (void)addDoubleTapCallBack:(id)target sel:(SEL)selector;

//清扫手势
- (void)addSwipeCallBack:(id)target sel:(SEL)selector;

@end
