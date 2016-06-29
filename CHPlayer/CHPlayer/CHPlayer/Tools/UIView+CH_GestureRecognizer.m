//
//  UIView+CH_GestureRecognizer.m
//  CHPlayer
//
//  Created by Cher on 16/6/29.
//  Copyright © 2016年 Hxc. All rights reserved.
//

#import "UIView+CH_GestureRecognizer.h"

@implementation UIView (CH_GestureRecognizer)

//单击事件
- (void)addTapCallBack:(id)target sel:(SEL)selector
{
     self.userInteractionEnabled = YES;
     UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
     [self addGestureRecognizer:tap];
}

//双击事件
- (void)addDoubleTapCallBack:(id)target sel:(SEL)selector{
     
     self.userInteractionEnabled = YES;
     UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
     tap.numberOfTapsRequired = 2;
     [self addGestureRecognizer:tap];
}

//清扫手势
- (void)addSwipeCallBack:(id)target sel:(SEL)selector{
     
     self.userInteractionEnabled = YES;
     UISwipeGestureRecognizer *tap = [[UISwipeGestureRecognizer alloc] initWithTarget:target action:selector];
     [self addGestureRecognizer:tap];
}

@end
