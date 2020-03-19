//
//  SCVideoPreview.h
//  fasdfasd
//
//  Created by guohongqi on 2020/3/16.
//  Copyright © 2020 guohq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCVideoPreviewProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface SCVideoPreview : UIView<SCVideoPreviewProtocol>
@property (nonatomic, assign, readwrite)  CGRect           effectiveRect;
+ (instancetype)createMaskView:(CGRect)frame scanRect:(CGRect)scanFrame;

@end

NS_ASSUME_NONNULL_END
