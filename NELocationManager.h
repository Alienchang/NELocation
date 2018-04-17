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
///最小更新距离
@property (nonatomic ,assign) double distanceFilter;
///期望精度
@property (nonatomic ,assign) double desiredAccuracy;
///每隔多长时间更新一次地址，并由当前对象保存，0为停止更新
@property (nonatomic ,assign) NSTimeInterval updateLocationInterval;
/// 如果调用了startLocate，回调后会立即更新此值。如果updateLocationInterval不为0，每次更新后都会更新此值
@property (nonatomic ,strong) NELocationInfo *locationInfo;
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

/**
 根据经纬度获取地理位置信息
 
 @param longitude 经度
 @param latitude 纬度
 @param locationUpdateBlock 地理位置信息回调
 */
- (void)fetchLocationInfoWithLongitude:(CGFloat)longitude
                              latitude:(CGFloat)latitude
                   locationUpdateBlock:(LocationUpdateBlock)locationUpdateBlock;

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
