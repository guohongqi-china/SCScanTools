//
//  SCVideoPreview.h
//  fasdfasd
//
//  Created by guohongqi on 2020/3/16.
//  Copyright © 2020 guohq. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SCVideoPreviewProtocol <NSObject>
// 扫码有效区域
@property (nonatomic, assign)  CGRect           effectiveRect;

/**
 
 @param frame  the view show in parent view of frame
 @param scanFrame effective frame
 */
+ (instancetype)createMaskView:(CGRect)frame scanRect:(CGRect)scanFrame;


@end

NS_ASSUME_NONNULL_END
