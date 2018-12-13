//
//  UINavigationController+JXDBarViewOpacity.m
//  JxdEimV2
//
//  Created by 金现代 on 2018/12/13.
//  Copyright © 2018 山东金现代. All rights reserved.
//

#import "UINavigationController+JXDBarViewOpacity.h"
#import "UIViewController+JXDAlapa.h"
#import <objc/runtime.h>

@implementation UINavigationController (JXDBarViewOpacity)
- (void)setNeedsNavigationBackground:(CGFloat)alpha {
    // 导航栏背景透明度设置
    UIView *barBackgroundView = [[self.navigationBar subviews] firstObject];// _UIBarBackground
    UIImageView *backgroundImageView = [[barBackgroundView subviews] firstObject];// UIImageView
    if (self.navigationBar.isTranslucent) {
        if (backgroundImageView != nil && backgroundImageView.image != nil) {
            barBackgroundView.alpha = alpha;
        } else {
            if ([barBackgroundView subviews].count >= 1) {
                UIView *backgroundEffectView = [[barBackgroundView subviews] objectAtIndex:1];
                backgroundEffectView.alpha = alpha;
            }
        }
    } else {
        barBackgroundView.alpha = alpha;
    }
    self.navigationBar.clipsToBounds = alpha == 0.0;
}

+ (void)initialize {
    if (self == [UINavigationController self]) {
        // 交换方法
        SEL originalSelector = NSSelectorFromString(@"_updateInteractiveTransition:");
        SEL swizzledSelector = NSSelectorFromString(@"et__updateInteractiveTransition:");
        Method originalMethod = class_getInstanceMethod([self class], originalSelector);
        Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
- (void)et__updateInteractiveTransition:(CGFloat)percentComplete {
    [self et__updateInteractiveTransition:(percentComplete)];
    UIViewController *topVC = self.topViewController;
    if (topVC != nil) {
        id<UIViewControllerTransitionCoordinator > coor = topVC.transitionCoordinator;
        if (coor != nil) {
            // 随着滑动的过程设置导航栏透明度渐变
            CGFloat fromAlpha = [[coor viewControllerForKey:UITransitionContextFromViewControllerKey].navBarBgAlpha floatValue];
            CGFloat toAlpha = [[coor viewControllerForKey:UITransitionContextToViewControllerKey].navBarBgAlpha floatValue];
            CGFloat nowAlpha = fromAlpha + (toAlpha - fromAlpha) * percentComplete;
            NSLog(@"from:%f, to:%f, now:%f",fromAlpha, toAlpha, nowAlpha);
            [self setNeedsNavigationBackground:nowAlpha];
        }
    }
}
#pragma mark - UINavigationController Delegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *topVC = self.topViewController;
    if (topVC != nil) {
        id<UIViewControllerTransitionCoordinator> coor = topVC.transitionCoordinator;
        if (coor != nil) {
            //            [coor notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context){
            //                [self dealInteractionChanges:context];
            //            }];
            
            // notifyWhenInteractionChangesUsingBlock是10.0以后的api，换成notifyWhenInteractionEndsUsingBlock
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [coor notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context){
                [self dealInteractionChanges:context];
#pragma clang diagnostic pop
            }];
        }
    }
}

- (void)dealInteractionChanges:(id<UIViewControllerTransitionCoordinatorContext>)context {
    if ([context isCancelled]) {// 自动取消了返回手势
        NSTimeInterval cancelDuration = [context transitionDuration] * (double)[context percentComplete];
        UIViewController *toVC = [context viewControllerForKey:
                                  UITransitionContextFromViewControllerKey];
        CGFloat nowAlpha;
        if (toVC.isHiddenNavBar) {
            nowAlpha = 0;
        }else nowAlpha = 1;
        [UIView animateWithDuration:cancelDuration animations:^{
            NSLog(@"自动取消返回到alpha：%f", nowAlpha);
            [self setNeedsNavigationBackground:nowAlpha];
        }];
    } else {// 自动完成了返回手势
        NSTimeInterval finishDuration = [context transitionDuration] * (double)(1 - [context percentComplete]);
        UIViewController *toVC = [context viewControllerForKey:
                                  UITransitionContextToViewControllerKey];
        CGFloat nowAlpha;
        if (toVC.isHiddenNavBar) {
            nowAlpha = 0;
        }else nowAlpha = 1;
        [UIView animateWithDuration:finishDuration animations:^{
            NSLog(@"自动完成返回到alpha：%f", nowAlpha);
            [self setNeedsNavigationBackground:nowAlpha];
        }];
    }
}

- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item {
    if (self.viewControllers.count >= navigationBar.items.count) {// 点击返回按钮
        UIViewController *popToVC = self.viewControllers[self.viewControllers.count - 1];
        if (popToVC.isHiddenNavBar) {
            [self setNeedsNavigationBackground:0];
        }else [self setNeedsNavigationBackground:1];
        //        [self popViewControllerAnimated:YES];
    }
}

- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item {
    // push到一个新界面
    if (self.topViewController.isHiddenNavBar) {
        [self setNeedsNavigationBackground:0];
    }else [self setNeedsNavigationBackground:1];
    
}


static char *CloudoxKey = "CloudoxKey";
-(void)setCloudox:(NSString *)cloudox{
    objc_setAssociatedObject(self, CloudoxKey, cloudox, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)cloudox{
    return objc_getAssociatedObject(self, CloudoxKey);
}
@end
