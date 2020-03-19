//
//  SCAnimation.h
//  fasdfasd
//
//  Created by guohongqi on 2020/3/16.
//  Copyright © 2020 guohq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCAnimation : UIView
- (instancetype)initWithFrame:(CGRect)frame;
- (void)startAnimation:(CGFloat)maxH;
- (void)deallocSelf;
@end

NS_ASSUME_NONNULL_END
