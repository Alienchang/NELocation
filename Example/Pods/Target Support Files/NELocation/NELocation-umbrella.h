#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NELocation.h"
#import "NELocationInfo.h"
#import "NELocationManager.h"

FOUNDATION_EXPORT double NELocationVersionNumber;
FOUNDATION_EXPORT const unsigned char NELocationVersionString[];

