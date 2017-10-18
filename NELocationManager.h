//
//  NELocationManager.h
//
//  Created by Chang Liu on 10/18/17.
//  Copyright © 2017 Chang Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NELocationInfo.h"

typedef void(^LocationUpdateBlock)(BOOL success, NELocationInfo *locationInfo, NSError *error);

@interface NELocationManager : NSObject

@property (nonatomic ,assign) double distanceFilter;        //最小更新距离
@property (nonatomic ,assign) double desiredAccuracy;       //期望精度
/*
 * 单例
 */
+ (instancetype)sharedManager;

/*
 * 非单例
 */
+ (instancetype)defaultManager;

/*
 * 开始定位，默认定位完成就会关闭定位
 * 调用startLocate方法时会默认进行权限判断和提示，如果需要自定义UI，用+(BOOL)locationPermission进行判断
 */
- (void)startLocate:(LocationUpdateBlock)locationUpdateBlock;

/*
 * 停止定位
 */
- (void)endLocate;

//************************************************** 授权 **********************************
@property (nonatomic ,copy) void(^toSettingBlock)(void);    //授权时点击授权按钮动作
@property (nonatomic ,copy) void(^cancelSettingBlock)(void);//授权时点击取消按钮动作

/*
 * alertController显示的信息
 */
@property (nonatomic ,copy) NSString *alertTitleText;
@property (nonatomic ,copy) NSString *alertMessageText;
@property (nonatomic ,copy) NSString *settingText;
@property (nonatomic ,copy) NSString *cancelText;

/*
 * 是否有访问位置权限
 */
+ (BOOL)locationPermission;

/*
 * 获取位置权限
 */
- (void)getPermissionForStartUpdatingLocation;
@end
