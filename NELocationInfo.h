//
//  NELocationInfo.h
//
//  Created by Chang Liu on 10/18/17.
//  Copyright © 2017 Chang Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface NELocationInfo : NSObject
@property (nonatomic ,copy) NSString *name;
@property (nonatomic ,copy) NSString *city;
@property (nonatomic ,copy) NSString *county;           //县
@property (nonatomic ,copy) NSString *country;          //国家
@property (nonatomic ,copy) NSString *countryCode;
@property (nonatomic ,copy) NSString *street;
@property (nonatomic ,copy) NSString *zipCode;
@property (nonatomic ,copy) NSString *longitude;        //经度
@property (nonatomic ,copy) NSString *latitude;         //纬度
@property (nonatomic ,copy) NSString *altitude;         //海拔
@end



