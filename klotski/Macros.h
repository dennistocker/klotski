
#ifndef Macros_h
#define Macros_h

// 屏幕分辨率
#define kMainScreenFrame        ([[UIScreen mainScreen] bounds])
#define kMainScreenSize         ([[UIScreen mainScreen] bounds].size)
#define kMainScreenWidth        ([[UIScreen mainScreen] bounds].size.width)
#define kMainScreenHeight       ([[UIScreen mainScreen] bounds].size.height)

#define kNavigationBarHeight    44
#define kAppFrameHeight         ([[UIScreen mainScreen] applicationFrame].size.height)
#define kStatusBarHeight        ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define kViewHeight             (kMainScreenHeight - kNavigationBarHeight - kStatusBarHeight)

// 系统
#define IDFV            ([[[UIDevice currentDevice] identifierForVendor] UUIDString])
#define DEVICE_NAME     ([[UIDevice currentDevice] model])
#define SYSTEM_NAME     ([[UIDevice currentDevice] systemName])
#define SYSTEM_VERSION  ([[UIDevice currentDevice] systemVersion])
#define APP_ID          ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"])
#define APP_BUILD       ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"])
#define APP_VERSION     ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"])
#define APP_NAME        ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"])

// 设备
#define IPHONE4         (fabs(kMainScreenHeight - 480) < DBL_EPSILON)
#define IPHONE5         (fabs(kMainScreenHeight - 568) < DBL_EPSILON)
#define IPHONE6         (fabs(kMainScreenHeight - 667) < DBL_EPSILON)
#define IPHONE6P        (fabs(kMainScreenHeight - 736) < DBL_EPSILON)

// 系统版本
#define IOS5_OR_LATER   ([SYSTEM_VERSION doubleValue] >= 5.0)
#define IOS6_OR_LATER   ([SYSTEM_VERSION doubleValue] >= 6.0)
#define IOS7_OR_LATER   ([SYSTEM_VERSION doubleValue] >= 7.0)
#define IOS8_OR_LATER   ([SYSTEM_VERSION doubleValue] >= 8.0)
#define IOS9_OR_LATER   ([SYSTEM_VERSION doubleValue] >= 9.0)
#define IOS10_OR_LATER   ([SYSTEM_VERSION doubleValue] >= 10.0)
#define IOS11_OR_LATER   ([SYSTEM_VERSION doubleValue] >= 11.0)

#endif /* Macros_h */
