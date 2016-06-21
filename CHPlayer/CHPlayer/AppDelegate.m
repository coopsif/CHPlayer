//
//  AppDelegate.m
//  CHPlayer
//
//  Created by Cher on 16/6/12.
//  Copyright © 2016年 Hxc. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreMotion/CoreMotion.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     // Override point for customization after application launch.
     
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAction) name:@"CHANGEROOTVC" object:nil];
     return YES;
}

- (void)notificationAction{
     
     UIViewController *org_rootVC = self.window.rootViewController;
     UIViewController *tab_rootVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"AutorotateTabbarVC"];
     UIViewController *nav_rootVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"AutorotateNavigaVC"];
     self.window.rootViewController = [org_rootVC isMemberOfClass:[tab_rootVC class]]?nav_rootVC:tab_rootVC;
}

- (void)applicationWillResignActive:(UIApplication *)application {
     // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
     // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
     // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
     // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     
}

- (void)applicationWillTerminate:(UIApplication *)application {
     // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
