#import "BootpayFlutterPlugin.h"
#if __has_include(<bootpay_flutter/bootpay_flutter-Swift.h>)
#import <bootpay_flutter/bootpay_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "bootpay_flutter-Swift.h"
#endif

@implementation BootpayFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBootpayFlutterPlugin registerWithRegistrar:registrar];
}
@end
