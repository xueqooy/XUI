//
//  llp_ui_iOSHelper.m
//  llp_ui_iOS
//
//  Created by Chen Qingming on 2024/1/3.
//

#import "llp_ui_iOSHelper.h"

@implementation llp_ui_iOSHelper

+ (NSBundle *)resourceBundle:(Class)classtype {
    static NSBundle *uiModuleBaseBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uiModuleBaseBundle = [NSBundle bundleForClass:classtype];
        if (uiModuleBaseBundle) {
            NSString *resourceBundlePath = [uiModuleBaseBundle pathForResource:@"llp_ui_iOSBundle" ofType:@"bundle"];
            if (resourceBundlePath && [[NSFileManager defaultManager] fileExistsAtPath:resourceBundlePath]) {
                uiModuleBaseBundle = [NSBundle bundleWithPath:resourceBundlePath];
            }
        }
    });
    return uiModuleBaseBundle;
}

@end
