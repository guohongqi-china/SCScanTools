//
//  SCAnimation.m
//  fasdfasd
//
//  Created by guohongqi on 2020/3/16.
//  Copyright © 2020 guohq. All rights reserved.
//

#import "SCAnimation.h"
@interface SCAnimation()
@property (nonatomic, assign)  BOOL           isAnimation;

@end
@implementation SCAnimation

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self addAnamorphosisLayer];
        self.clipsToBounds = YES;
        self.isAnimation   = YES;
    }
    return self;
}

- (void)addAnamorphosisLayer{
    UIColor *startColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    UIColor *endColor   = [[SCAnimation colorWithHexString:@"34E3FF"] colorWithAlphaComponent:0.64];

    CAGradientLayer * gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.colors = @[(__bridge id)startColor.CGColor,(__bridge id)endColor.CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    gradientLayer.locations = @[@0,@1];
    [self.layer addSublayer:gradientLayer];
}

- (void)startAnimation:(CGFloat)maxH{
    if (!_isAnimation) {
        return;
    }
    __weak  typeof(self) weakself = self;
    [UIView animateWithDuration:1.8 animations:^{
        weakself.transform = CGAffineTransformTranslate(weakself.transform, 0, maxH + weakself.frame.size.height);
    } completion:^(BOOL finished) {
        // 还原初始状态
        weakself.transform = CGAffineTransformIdentity;
        [weakself startAnimation:maxH];
    }];
}

#pragma mark - 16进制颜色值转换
+ (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // 判断前缀
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    // 从六位数值中找到RGB对应的位数并转换
    NSRange range;
    range.location = 0;
    range.length = 2;
    //R、G、B
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}


- (void)deallocSelf{
    self.transform = CGAffineTransformIdentity;
    _isAnimation   = NO;
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}


@end
