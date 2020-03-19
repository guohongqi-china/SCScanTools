//
//  SCScanManager.m
//  fasdfasd
//
//  Created by guohq on 2020/3/15.
//  Copyright © 2020 guohq. All rights reserved.
//

#import "SCScanManager.h"
#import <CoreImage/CoreImage.h>
#import <AVFoundation/AVFoundation.h>
@interface SCScanManager()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong)  AVCaptureSession                     *session;
@property (nonatomic, weak)    AVCaptureVideoPreviewLayer           *previewLayer;
@property (nonatomic, weak)    AVCaptureMetadataOutput              *metadaOutput;


@end

@implementation SCScanManager

// 当前放大状态
BOOL       currentState;

+ (void)createScanManagerWith:(UIView <SCVideoPreviewProtocol>*)previewView initType:(InitType)type completion:(void(^)(SCScanManager *scanManager))completion
{

    if (type == InitType_SYNC)
    {
        [SCScanManager initLizeSyncSelft:previewView completion:completion];
    }
    else
    {
        [SCScanManager initLizeAsyncSelft:previewView completion:completion];
    }
}

+ (void)createScanMnanger:(UIView <SCVideoPreviewProtocol>*(^)(void))viewBack initType:(InitType)type completion:(void(^)(SCScanManager *scanManager))completion{
    UIView <SCVideoPreviewProtocol>* previewView = viewBack();
    if (type == InitType_SYNC)
    {
        [SCScanManager initLizeSyncSelft:previewView completion:completion];
    }
    else
    {
        [SCScanManager initLizeAsyncSelft:previewView completion:completion];
    }
}


- (instancetype)initWithPreviewView:(UIView <SCVideoPreviewProtocol>*)previewView{
    if (self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        __weak typeof(self) weakself = self;
        __weak typeof(previewView) weakPreview = previewView;
        [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
            weakself.metadaOutput.rectOfInterest = [weakself.previewLayer metadataOutputRectOfInterestForRect:weakPreview.effectiveRect];
        }];
        
        [self initlizeCaptureSetting];

        // 预览图层
        AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        previewLayer.frame                       = [UIScreen mainScreen].bounds;
        previewLayer.videoGravity                = AVLayerVideoGravityResizeAspectFill;
        [previewView.layer insertSublayer:previewLayer atIndex:0];
        self.previewLayer                        = previewLayer;
        
        // 设置扫码区域
        self.metadaOutput.rectOfInterest = previewView.effectiveRect;

        
        // 缩放手势
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
        [previewView addGestureRecognizer:pinchGesture];
        
    }
    return self;
}

- (instancetype)initWithPreviewViewDispatchAsync:(UIView <SCVideoPreviewProtocol>*)previewView completion:(void(^)(void))completion{
    if (self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        __weak typeof(self) weakself = self;
        __weak typeof(previewView) weakPreview = previewView;
        [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
            weakself.metadaOutput.rectOfInterest = [weakself.previewLayer metadataOutputRectOfInterestForRect:weakPreview.effectiveRect];

        }];
        
        // 在全局队列开启新线程，异步初始化AVCaptureSession（比较耗时）
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self initlizeCaptureSetting];
            // 回主线程更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                        
                // 预览图层
                AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
                previewLayer.frame                       = [UIScreen mainScreen].bounds;
                previewLayer.videoGravity                = AVLayerVideoGravityResizeAspectFill;
                self.previewLayer                        = previewLayer;
                
                [previewView.layer insertSublayer:previewLayer atIndex:0];

                // 设置扫码区域
                self.metadaOutput.rectOfInterest = previewView.effectiveRect;

                
                // 缩放手势
                UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
                [previewView addGestureRecognizer:pinchGesture];
                completion();
            
            });
        });
    }
    return self;
}

#pragma mark --  Init Methods
+ (void)initLizeSyncSelft:(UIView <SCVideoPreviewProtocol>*)previewView completion:(void(^)(SCScanManager *scanManager))completion{
    __block SCScanManager *manager;
    manager = [[SCScanManager alloc] initWithPreviewView:previewView];
    completion(manager);
}

+ (void)initLizeAsyncSelft:(UIView <SCVideoPreviewProtocol>*)previewView completion:(void(^)(SCScanManager *scanManager))completion{
    __block SCScanManager *manager;
    manager = [[SCScanManager alloc] initWithPreviewViewDispatchAsync:previewView completion:^{
        completion(manager);
    }];
}

- (void)initlizeCaptureSetting{
    // 初始化采集器
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if ([device lockForConfiguration:nil])
    {
        //自动白平衡
        if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
        {
            [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        //自动对焦
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
        {
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        //自动曝光
        if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
        {
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [device unlockForConfiguration];
    }

    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    
    if (error) {
        NSLog(@"初始化input失败,%@",error);
    }
    // 添加输入源
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    // 添加输出源
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
    }

    
    // 设置扫码支持的编码格式
    // AVMetadataObjectTypeQRCode 二维码
    [output setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code,nil]];

    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.metadaOutput = output;
    
}

#pragma mark --  Interface Methods

- (void)startScanning{
    if (_session && !_session.isRunning) {
        [_session startRunning];
    }
}
- (void)startScanningResetZoomFactor:(BOOL)reset{
    if (reset && currentState) {
        [SCScanManager resetZoomFactor];
    }
    [self startScanning];
}


- (void)stopScanning{
    if (_session && _session.isRunning) {
        [_session stopRunning];
    }
}


+ (void)resetZoomFactor {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    device.videoZoomFactor = 1.0;
    [device unlockForConfiguration];
    currentState = NO;
}

#pragma mark - Notification functions

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self startScanning];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self stopScanning];
}



#pragma mark - 缩放手势

- (void)pinch:(UIPinchGestureRecognizer *)gesture {
    if (!_isScaleZoom) {
        return;
    }
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    CGFloat minZoomFactor = 1.0;
    CGFloat maxZoomFactor = device.activeFormat.videoMaxZoomFactor;
    
    if (@available(iOS 11.0, *)) {
        minZoomFactor = device.minAvailableVideoZoomFactor;
        maxZoomFactor = device.maxAvailableVideoZoomFactor;
    }
    
    static CGFloat lastZoomFactor = 1.0;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        lastZoomFactor = device.videoZoomFactor;
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat zoomFactor = lastZoomFactor * gesture.scale;
        zoomFactor = fmaxf(fminf(zoomFactor, maxZoomFactor), minZoomFactor);
        [device lockForConfiguration:nil];
        device.videoZoomFactor = zoomFactor;
        [device unlockForConfiguration];
    }
    currentState = YES;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

}
#pragma mark --  AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSLog(@"come:%@",metadataObjects);
    
    if (_isShake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
    
    if (!_isContinuity) {
        [self.session stopRunning];
    }

          
    AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects lastObject];
    if (!metadataObject.stringValue.length) {
        return;
    }
       
    if (self.delegate && [self.delegate respondsToSelector:@selector(captureOutputMetaData:metaData:)]) {
        [self.delegate captureOutputMetaData:metadataObject.stringValue metaData:metadataObjects];
    }    
}


- (void)dealloc {
    
    NSLog(@"%s", __func__);
    [self deallocCaptureSession];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deallocCaptureSession{
    [self.session stopRunning];
    for (AVCaptureDeviceInput *input in self.session.inputs) {
        [self.session removeInput:input];
    }
    for (AVCaptureMetadataOutput *output in self.session.outputs) {
        [self.session removeOutput:output];
    }
    self.session       = nil;
    self.metadaOutput  = nil;
    self.previewLayer = nil;
}

@end
