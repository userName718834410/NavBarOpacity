//
//  UIViewController+JXDAlapa.m
//  JxdEimV2
//
//  Created by 金现代 on 2018/12/13.
//  Copyright © 2018 山东金现代. All rights reserved.
//

#import "UIViewController+JXDAlapa.h"
#import <objc/runtime.h>
#import "UINavigationController+JXDBarViewOpacity.h"

@implementation UIViewController (JXDAlapa)
static char *CloudoxKey = "CloudoxKey";
static char *hiddenKey = "hiddenKey";
-(void)setNavBarBgAlpha:(NSString *)navBarBgAlpha{
    objc_setAssociatedObject(self, CloudoxKey, navBarBgAlpha, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self.navigationController setNeedsNavigationBackground:[navBarBgAlpha floatValue]];
}
-(NSString *)navBarBgAlpha{
    return objc_getAssociatedObject(self, CloudoxKey);
}
- (void)setIsHiddenNavBar:(BOOL)isHiddenNavBar{
    objc_setAssociatedObject(self, hiddenKey, @(isHiddenNavBar), OBJC_ASSOCIATION_ASSIGN);
    if (isHiddenNavBar) {
        [self.navigationController setNeedsNavigationBackground:0];
    }else  [self.navigationController setNeedsNavigationBackground:1];
}
- (BOOL)isHiddenNavBar{
    return  [objc_getAssociatedObject(self, hiddenKey) boolValue];
}
@end
