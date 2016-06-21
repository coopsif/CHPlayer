//
//  VideoModel.h
//  CHPlayer
//
//  Created by Cher on 16/6/16.
//  Copyright © 2016年 Hxc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHPlayerView.h"

@interface VideoModel : NSObject

@property(nonatomic,copy)  NSString *title;
@property(nonatomic,assign)CHPlayerType type;

@end
