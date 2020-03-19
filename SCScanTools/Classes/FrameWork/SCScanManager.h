//
//  SCScanManager.h
//  fasdfasd
//
//  Created by guohq on 2020/3/15.
//  Copyright © 2020 guohq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SCVideoPreviewProtocol.h"

typedef NS_ENUM(NSUInteger,InitType){
    InitType_SYNC = 1000,
    InitType_ASYNC,
};

NS_ASSUME_NONNULL_BEGIN
@protocol SCScanManagerDelegate <NSObject>

- (void)captureOutputMetaData:(NSString *)codeString metaData:(id)data;

@end

@interface SCScanManager : NSObject
// 扫码是否抖动
@property (nonatomic, assign)   BOOL                           isShake;
// 是否连扫 默认不支持
@property (nonatomic, assign)   BOOL                           isContinuity;
// 是否支持缩放
@property (nonatomic, assign)   BOOL                           isScaleZoom;
@property (nonatomic, assign)   id<SCScanManagerDelegate>      delegate;


+ (void)createScanManagerWith:(UIView <SCVideoPreviewProtocol>*)previewView initType:(InitType)type completion:(void(^)(SCScanManager *scanManager))completion;
+ (void)createScanMnanger:(UIView <SCVideoPreviewProtocol>*(^)(void))viewBack initType:(InitType)type completion:(void(^)(SCScanManager *scanManager))completion;;

- (instancetype)initWithPreviewViewDispatchAsync:(UIView <SCVideoPreviewProtocol>*)previewView completion:(void(^)(void))completion;
- (instancetype)initWithPreviewView:(UIView <SCVideoPreviewProtocol>*)previewView;

- (void)startScanning;
- (void)startScanningResetZoomFactor:(BOOL)reset;

- (void)stopScanning;

// 光学放大复原
+ (void)resetZoomFactor;



@end

NS_ASSUME_NONNULL_END
