//
//  UINavigationController+JXDBarViewOpacity.h
//  JxdEimV2
//
//  Created by 金现代 on 2018/12/13.
//  Copyright © 2018 山东金现代. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (JXDBarViewOpacity)<UINavigationBarDelegate, UINavigationControllerDelegate>
@property (copy, nonatomic) NSString *cloudox;
- (void)setNeedsNavigationBackground:(CGFloat)alpha;
@end

NS_ASSUME_NONNULL_END
