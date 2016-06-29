//
//  AutorotateNavigaVC.m
//  CHPlayer
//
//  Created by Cher on 16/6/12.
//  Copyright © 2016年 Hxc. All rights reserved.
//

#import "AutorotateNavigaVC.h"

@interface AutorotateNavigaVC ()

@end

@implementation AutorotateNavigaVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL)shouldAutorotate{

     return [self.visibleViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
     return [self.visibleViewController supportedInterfaceOrientations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
