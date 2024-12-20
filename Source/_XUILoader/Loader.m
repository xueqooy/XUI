//
//  Loader.m
//  XUI
//
//  Created by xueqooy on 2023/4/19.
//

#import "Loader.h"
#import <objc/runtime.h>

@implementation Loader

+ (void)load {
    [self load_uiviewController_viewstate];
    [self load_uiviewController_viewsizetransition];
    [self load_uicontrol_selectable];
    [self load_uibaritem_viewhook];
    [self load_uiview_safeareainsetspublisher];
}

/// UIViewController+ViewState
+ (void)load_uiviewController_viewstate {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL sel = @selector(XUI_load_uiviewController_viewstate);
    #pragma clang diagnostic pop
    
    Class cls = NSClassFromString(@"UIViewController");
    Method method = class_getClassMethod(cls, sel);
    if (method != NULL) {
        IMP imp = method_getImplementation(method);
        ((id (*)(Class, SEL))imp)(cls, sel);
    }
}

/// UIViewController+ViewSizeTransition
+ (void)load_uiviewController_viewsizetransition {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL sel = @selector(XUI_load_uiviewController_viewsizetransition);
    #pragma clang diagnostic pop
    
    Class cls = NSClassFromString(@"UIViewController");
    Method method = class_getClassMethod(cls, sel);
    if (method != NULL) {
        IMP imp = method_getImplementation(method);
        ((id (*)(Class, SEL))imp)(cls, sel);
    }
}


/// SingleSelectionGroup
+ (void)load_uicontrol_selectable {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL sel = @selector(XUI_load_uicontrol_selectable);
    #pragma clang diagnostic pop

    Class cls = NSClassFromString(@"UIControl");
    Method method = class_getClassMethod(cls, sel);
    if (method != NULL) {
        IMP imp = method_getImplementation(method);
        ((id (*)(Class, SEL))imp)(cls, sel);
    }
}

/// UIBarItem+ViewHook
+ (void)load_uibaritem_viewhook {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL sel = @selector(XUI_load_uibaritem_viewhook);
    #pragma clang diagnostic pop

    Class cls = NSClassFromString(@"UIBarItem");
    Method method = class_getClassMethod(cls, sel);
    if (method != NULL) {
        IMP imp = method_getImplementation(method);
        ((id (*)(Class, SEL))imp)(cls, sel);
    }
}

/// UIView+SafeAreaInsetsPublisher
+ (void)load_uiview_safeareainsetspublisher {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL sel = @selector(XUI_load_uiview_safeareainsetspublisher);
    #pragma clang diagnostic pop

    Class cls = NSClassFromString(@"UIView");
    Method method = class_getClassMethod(cls, sel);
    if (method != NULL) {
        IMP imp = method_getImplementation(method);
        ((id (*)(Class, SEL))imp)(cls, sel);
    }
}

@end
