//
//  NELocationManager.m
//
//  Created by Chang Liu on 10/18/17.
//  Copyright © 2017 Chang Liu. All rights reserved.
//

#import "NELocationManager.h"
#import <UIKit/UIKit.h>
#import "MSWeakTimer.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)    ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface NELocationManager()<CLLocationManagerDelegate>{
    CLLocation          *_currentLocation;
}
@property (nonatomic ,strong) CLLocationManager   *locationManager;
@property (nonatomic ,copy)   LocationUpdateBlock locationCompletionBlock;
@property (nonatomic ,strong) MSWeakTimer         *timer;
@property (nonatomic ,strong) dispatch_queue_t    locationUpdateQueue;


@end

@implementation NELocationManager

+ (instancetype)sharedManager {
    static NELocationManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [NELocationManager new];
        [sharedMyManager setDistanceFilter:0];
    });
    return sharedMyManager;
}

+ (instancetype)defaultManager {
    return [NELocationManager new];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _locationManager = [CLLocationManager new];
        [_locationManager setDelegate:self];
    }
    return self;
}

- (void)setUpdateLocationInterval:(NSTimeInterval)updateLocationInterval {
    _updateLocationInterval = updateLocationInterval;
    if (updateLocationInterval > 0) {
        self.locationUpdateQueue = dispatch_get_main_queue();
        self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:updateLocationInterval target:self selector:@selector(updateLocatin) userInfo:nil repeats:YES dispatchQueue:self.locationUpdateQueue];
        [self.timer fire];
    }else{
        [self.timer invalidate];
        [self setLocationUpdateQueue:nil];
        [self setTimer:nil];
    }
}

- (void)updateLocatin {
    __weak typeof(self) weakSelf = self;
    [self startLocate:^(BOOL success, NELocationInfo *locationInfo, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf setLocationInfo:locationInfo];
        });
    }];
}

+ (BOOL)locationPermission{
    BOOL isPermitted = YES;
    
    if(![CLLocationManager locationServicesEnabled]) {
        return NO;
    }
    
    CLAuthorizationStatus locationPermission = [CLLocationManager authorizationStatus];
    if ((locationPermission == kCLAuthorizationStatusRestricted) || (locationPermission == kCLAuthorizationStatusDenied)) {
        isPermitted = NO;
    }
    
    if (isPermitted && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") && locationPermission == kCLAuthorizationStatusNotDetermined) {
        isPermitted = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"] || [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] || [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysAndWhenInUseUsageDescription"];
    }
    return isPermitted;
}

- (void)setDistanceFilter:(double)distanceFilter {
    _distanceFilter = distanceFilter;
    if (_distanceFilter == 0) {
        [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    } else {
        [self.locationManager setDistanceFilter:distanceFilter];
    }
}

- (void)setDesiredAccuracy:(double)desiredAccuracy {
    _desiredAccuracy = desiredAccuracy;
    if(desiredAccuracy < 50.0f) {
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    } else if(desiredAccuracy >= 50.0f && desiredAccuracy < 100.0f) {
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    } else if(desiredAccuracy >= 100.0f && desiredAccuracy < 500.0f) {
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    } else if(desiredAccuracy >= 500.0f && desiredAccuracy <= 1000.0f) {
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
    } else {
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
    }
}

- (void)getPermissionForStartUpdatingLocation {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    // Ref: https://developer.apple.com/documentation/corelocation/choosing_the_authorization_level_for_location_services#topics
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0"))
    {
        if ((status == kCLAuthorizationStatusNotDetermined) && ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]))
        {
            if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysAndWhenInUseUsageDescription"]) { //https://developer.apple.com/documentation/corelocation/choosing_the_authorization_level_for_location_services/request_always_authorization
                if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                    [self.locationManager performSelector:@selector(requestAlwaysAuthorization)];
                }
                else{
                    [[NSException exceptionWithName:@"[BBLocationManager] Fix needed for location permission key" reason:@"Your app's info.plist need both NSLocationWhenInUseUsageDescription and NSLocationAlwaysAndWhenInUseUsageDescription keys for asking 'Always usage of location' in iOS 11" userInfo:nil] raise];
                }
                
            } else if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) { //https://developer.apple.com/documentation/corelocation/choosing_the_authorization_level_for_location_services/requesting_when_in_use_authorization
                [self.locationManager performSelector:@selector(requestWhenInUseAuthorization)];
            } else {
                [[NSException exceptionWithName:@"[BBLocationManager] Fix needed for location permission key" reason:@"Your app's info.plist does not contain NSLocationWhenInUseUsageDescription and/or NSLocationAlwaysAndWhenInUseUsageDescription key required for iOS 11" userInfo:nil] raise];
            }
        }
        else if(status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted){
            NSLog(@"[BBLocationManager] Location Permission Denied by user, prompt user to allow location permission.");
            NSString *title, *message;
            if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysAndWhenInUseUsageDescription"]) {
                title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
                message = @"To use background location you must turn on 'Always' in the Location Services Settings";
            } else if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Location Service is not enabled";
                message = @"To use location you must turn on 'While Using the App' in the Location Services Settings";
            }
            
            
            __weak typeof(self) weakSelf = self;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.alertTitleText message:self.alertMessageText preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:self.cancelText style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if (weakSelf.cancelSettingBlock) {
                    weakSelf.cancelSettingBlock();
                }
            }];
            UIAlertAction *settingAction = [UIAlertAction actionWithTitle:self.settingText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (weakSelf.toSettingBlock) {
                    weakSelf.toSettingBlock();
                }
            }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:settingAction];
            [[self topViewController] presentViewController:alertController animated:YES completion:^{
                
            }];
        }
    }
    //before iOS 8, no permission was needed to access location
    else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        if ((status == kCLAuthorizationStatusNotDetermined) && ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]))
        {
            if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]) {
                [self.locationManager performSelector:@selector(requestAlwaysAuthorization)];
            } else if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                [self.locationManager performSelector:@selector(requestWhenInUseAuthorization)];
            } else {
                [[NSException exceptionWithName:@"[BBLocationManager] Location Permission Error" reason:@"Info.plist does not contain NSLocationWhenUse or NSLocationAlwaysUsageDescription key required for iOS 8" userInfo:nil] raise];
            }
        } else if(status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted){
            NSLog(@"[BBLocationManager] Location Permission Denied by user, prompt user to allow location permission.");
            NSString *title, *message;
            if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]) {
                title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
                message = @"To use background location you must turn on 'Always' in the Location Services Settings";
            } else if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Location Service is not enabled";
                message = @"To use location you must turn on 'While Using the App' in the Location Services Settings";
            }
            
            __weak typeof(self) weakSelf = self;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.alertTitleText message:self.alertMessageText preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:self.cancelText style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if (weakSelf.cancelSettingBlock) {
                    weakSelf.cancelSettingBlock();
                }
            }];
            UIAlertAction *settingAction = [UIAlertAction actionWithTitle:self.settingText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (weakSelf.toSettingBlock) {
                    weakSelf.toSettingBlock();
                }
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:settingAction];
            [[self topViewController] presentViewController:alertController animated:YES completion:^{
                
            }];
        }
    }
}

- (void)endLocate {
    [self.locationManager stopUpdatingLocation];
}

- (void)startLocate:(LocationUpdateBlock)locationUpdateBlock {
    [self setLocationCompletionBlock:locationUpdateBlock];
    if ([NELocationManager locationPermission]) {
        //iOS 11以后需要在获取地理位置前调用这个方法
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager startUpdatingLocation];
    }else{
        [self getPermissionForStartUpdatingLocation];
    }
}

#pragma mark --CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *newLocation = locations.lastObject;
    
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    
    if (newLocation.horizontalAccuracy < 0) return;
    
    CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
    CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    double distance = [loc1 distanceFromLocation:loc2];
    _currentLocation = newLocation;
    
    if(distance > 20) {
        if (locations && [locations count] >= 1) {
            CLLocation *location = [locations lastObject];
            [self getLocationInfoAdLocation:location];
            [self.locationManager stopUpdatingLocation];
        }
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (self.locationCompletionBlock) {
        self.locationCompletionBlock(NO ,self.locationInfo ,nil);
    }
}
#pragma mark -- accessor
- (NSString *)alertTitleText{
    if (!_alertTitleText) {
        _alertTitleText = @"Title";
    }
    return _alertTitleText;
}
- (NSString *)alertMessageText{
    if (!_alertMessageText) {
        _alertMessageText = @"Message";
    }
    return _alertMessageText;
}
- (NSString *)settingText{
    if (!_settingText) {
        _settingText = @"Setting";
    }
    return _settingText;
}
- (NSString *)cancelText{
    if (!_cancelText) {
        _cancelText = @"Cancel";
    }
    return _cancelText;
}
#pragma mark --private func
/**
 * 获取top viewController
 */
- (UIViewController *)topViewController {
    UIViewController *resultViewController;
    resultViewController = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultViewController.presentedViewController) {
        resultViewController = [self _topViewController:resultViewController.presentedViewController];
    }
    return resultViewController;
}

- (UIViewController *)_topViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)viewController topViewController]];
    } else if ([viewController isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)viewController selectedViewController]];
    } else {
        return viewController;
    }
    return nil;
}

- (void)getLocationInfoAdLocation:(CLLocation *)location {
    CLGeocoder *geocoder = [CLGeocoder new];
    __weak typeof(self) weakSelf = self;
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray* placemarks, NSError* error){
        NELocationInfo *locationInfo = nil;
        if ([placemarks count] > 0) {
            CLPlacemark *placemark = (CLPlacemark*)[placemarks objectAtIndex:0];
            locationInfo = [self generateLocationInfoWithPlacemark:placemark location:location];
        }
        if (weakSelf.locationCompletionBlock) {
            weakSelf.locationCompletionBlock(!error ,locationInfo ,error);
        }
    }];
}

- (void)fetchLocationInfoWithLongitude:(CGFloat)longitude
                              latitude:(CGFloat)latitude
                   locationUpdateBlock:(LocationUpdateBlock)locationUpdateBlock {
    CLGeocoder *geoCoder = [CLGeocoder new];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [geoCoder reverseGeocodeLocation:location completionHandler: ^(NSArray *placemarks,NSError *error) {
        NELocationInfo *locationInfo = nil;
        if ([placemarks count] > 0) {
            CLPlacemark *placemark = (CLPlacemark*)[placemarks objectAtIndex:0];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            locationInfo = [self generateLocationInfoWithPlacemark:placemark location:location];
        }
        if (locationUpdateBlock) {
            locationUpdateBlock(!error ,locationInfo ,error);
        }
    }];
}

- (NELocationInfo *)generateLocationInfoWithPlacemark:(CLPlacemark *)placemark location:(CLLocation *)location{
    NELocationInfo *locationInfo = [NELocationInfo new];
    NSString *name = placemark.name ? placemark.name : @"";
    NSString *thoroughfare = placemark.thoroughfare ? placemark.thoroughfare : @"";
    NSString *locality = placemark.locality ? placemark.locality : @"";
    NSString *subAdministrativeArea = placemark.subAdministrativeArea ? placemark.subAdministrativeArea : @"";
    NSString *postalcode = placemark.postalCode ? placemark.postalCode : @"";
    NSString *country = placemark.country ? placemark.country : @"";
    NSString *ISOcountryCode = placemark.ISOcountryCode ? placemark.ISOcountryCode : @"$";
    
    locationInfo.name        = name;
    locationInfo.latitude    = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
    locationInfo.longitude   = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
    locationInfo.altitude    = [NSString stringWithFormat:@"%f",location.altitude];
    locationInfo.city        = locality;
    locationInfo.street      = thoroughfare;
    locationInfo.county      = subAdministrativeArea;
    locationInfo.country     = country;
    locationInfo.zipCode     = postalcode;
    locationInfo.countryCode = ISOcountryCode;
    return locationInfo;
}

- (void)dealloc {
    [self.timer invalidate];
}
@end
