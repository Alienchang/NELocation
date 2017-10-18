//
//  NELocationInfo.m
//
//  Created by Chang Liu on 10/18/17.
//  Copyright © 2017 Chang Liu. All rights reserved.
//

#import "NELocationInfo.h"
#import <objc/runtime.h>

@implementation NELocationInfo
- (NSString *)description{
    NSDictionary *propertiesDictionary = [self properties_aps];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:propertiesDictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        return nil;
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
}

- (NSDictionary *)properties_aps
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
    }
    free(properties);
    return props;
}
@end


//"address_city" = "San Francisco";
//"address_county" = "San Francisco";
//"address_full_dictionary" =     {
//    City = "San Francisco";
//    Country = "United States";
//    CountryCode = US;
//    FormattedAddressLines =         (
//                                     "1000 Stockton St",
//                                     "San Francisco, CA  94108",
//                                     "United States"
//                                     );
//    Name = "1000 Stockton St";
//    PostCodeExtension = 1110;
//    State = CA;
//    Street = "1000 Stockton St";
//    SubAdministrativeArea = "San Francisco";
//    SubLocality = "Union Square";
//    SubThoroughfare = 1000;
//    Thoroughfare = "Stockton St";
//    ZIP = 94108;
//};
//"address_name" = "1000 Stockton St";
//"address_state" = CA;
//"address_street" = "Stockton St";
//"address_zipcode" = 94108;
//altitude = 0;
//latitude = "37.785834";
//longitude = "-122.406417";

