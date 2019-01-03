//
//  NEViewController.m
//  NELocation
//
//  Created by 1217493217@qq.com on 06/12/2018.
//  Copyright (c) 2018 1217493217@qq.com. All rights reserved.
//

#import "NEViewController.h"
#import <NELocation/NELocation.h>
@interface NEViewController ()

@end

@implementation NEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // 地理位置授权   需要放在设置rootViewController之后，否则无法弹出权限提示
    [[NELocationManager sharedManager] setCancelText:NSLocalizedString(@"guide5", nil)];
    [[NELocationManager sharedManager] setSettingText:NSLocalizedString(@"setting_topic", nil)];
    [[NELocationManager sharedManager] setAlertTitleText:@""];
    [[NELocationManager sharedManager] setAlertMessageText:NSLocalizedString(@"authority_location", nil)];
    [[NELocationManager sharedManager] setToSettingBlock:^{
        NSURL *settingUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:settingUrl]) {
            [[UIApplication sharedApplication] openURL:settingUrl];
        }
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NELocationManager sharedManager] setUpdateLocationInterval:300];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
