//
//  SCVideoPreview.m
//  fasdfasd
//
//  Created by guohongqi on 2020/3/16.
//  Copyright © 2020 guohq. All rights reserved.
//

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define COLOR_WITH_HEX(hexValue) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16)) / 255.0 green:((float)((hexValue & 0xFF00) >> 8)) / 255.0 blue:((float)(hexValue & 0xFF)) / 255.0 alpha:1.0f]


#import "SCVideoPreview.h"
#import "SCAnimation.h"

static CGFloat const angle_width = 3.0;
static CGFloat const angle_length = 23.0;
static NSString *const kExplain = @"请将扫描框对准条码";
@interface SCVideoPreview()

@property (nonatomic, assign)  CGRect          scanCropRect;


@property (nonatomic, strong)  SCAnimation     *animationScan;
@property (nonatomic, strong)  UIView          *animationView;

@end

@implementation SCVideoPreview


+ (instancetype)createMaskView:(CGRect)frame scanRect:(CGRect)scanFrame{
    SCVideoPreview *view = [[SCVideoPreview alloc]initWithFrame:frame scanRect:scanFrame];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame scanRect:(CGRect)scanFrame{
    if (self = [super initWithFrame:frame]) {
        
        _effectiveRect       = scanFrame;
        _scanCropRect        = scanFrame;
        [self drawScanBackgroundLayer];
        [self drawScanAngle];

        [self addSubview:self.animationView];
        
        [self.animationScan startAnimation:_scanCropRect.size.height];
    }
    return self;
}



#pragma mark --  Private Methods
// 绘制扫码框
- (void)drawScanBackgroundLayer {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height));
    CGPathAddRect(path, NULL, _scanCropRect);
    
    CAShapeLayer *scanLayer = [CAShapeLayer layer];
    scanLayer.frame = self.bounds;
    scanLayer.path = path;
    scanLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    scanLayer.fillRule = kCAFillRuleEvenOdd;
    CGPathRelease(path);
    
    [self.layer addSublayer:scanLayer];
}

// 添加扫码边界
- (void)drawScanAngle {
    CGFloat minX = CGRectGetMinX(self.scanCropRect);
    CGFloat minY = CGRectGetMinY(self.scanCropRect);
    CGFloat maxX = CGRectGetMaxX(self.scanCropRect);
    CGFloat maxY = CGRectGetMaxY(self.scanCropRect);
    
    CGSize size = CGSizeMake(angle_width, angle_length);
    // 左上角
    CGPoint leftUpPoint = CGPointMake(minX, minY);
    
    [self drawAngleLayerWithPosition:leftUpPoint
                 secondAnglePosition:leftUpPoint
                           angleSize:size];
    
    // 左下角
    CGPoint leftDownPoint = CGPointMake(minX, maxY - angle_length);
    CGPoint leftDownSecondPoint = CGPointMake(minX, maxY - angle_width);
    
    [self drawAngleLayerWithPosition:leftDownPoint
                 secondAnglePosition:leftDownSecondPoint
                           angleSize:size];
    
    // 右上角
    CGPoint rightUpPoint = CGPointMake(maxX- angle_width, minY);
    CGPoint rightUpSecondPoint = CGPointMake(maxX - angle_length, minY);
    
    [self drawAngleLayerWithPosition:rightUpPoint
                 secondAnglePosition:rightUpSecondPoint
                           angleSize:size];
    
    // 右下角
    CGPoint rightDownPoint = CGPointMake(maxX - angle_width, maxY - angle_length);
    CGPoint rightDownSecondPoint = CGPointMake(maxX - angle_length, maxY - angle_width);
    
    [self drawAngleLayerWithPosition:rightDownPoint
                 secondAnglePosition:rightDownSecondPoint
                           angleSize:size];
}

// 绘制圆角
- (void)drawAngleLayerWithPosition:(CGPoint)position
               secondAnglePosition:(CGPoint)secondAnglePosition
                         angleSize:(CGSize)angleSize {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(position.x, position.y, angleSize.width, angleSize.height));
    CGPathAddRect(path, NULL, CGRectMake(secondAnglePosition.x, secondAnglePosition.y, angleSize.height, angleSize.width));
    
    CAShapeLayer *scanLayer = [CAShapeLayer layer];
    scanLayer.path = path;
    scanLayer.fillColor = [UIColor colorWithRed:101/255.0 green:207/255.0  blue:253/255.0  alpha:1.0].CGColor; //EP_3B_95_FA_COLOR.CGColor;
    scanLayer.fillRule = kCAFillRuleNonZero;
    CGPathRelease(path);
    
    [self.layer addSublayer:scanLayer];
}

#pragma mark --  animation
- (SCAnimation *)animationScan{
    if (!_animationScan) {
        _animationScan = [[SCAnimation alloc]initWithFrame:CGRectMake(0, -(_scanCropRect.size.height / 3), _scanCropRect.size.width, _scanCropRect.size.height / 3)];
    }
    return _animationScan;
}

#pragma mark - getter && setter


- (UIView *)animationView{
    if (!_animationView) {
        _animationView                 = [[UIView alloc]initWithFrame:_scanCropRect];
        _animationView.clipsToBounds   = YES;
        [_animationView addSubview:self.animationScan];
    }
    return _animationView;
}


- (void)dealloc{
    NSLog(@"%s",__func__);
}


@end
