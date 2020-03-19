//
//  SCBarCodeImage.h
//  fasdfasd
//
//  Created by guohq on 2020/3/15.
//  Copyright © 2020 guohq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCBarCodeImage : UIImage

#pragma mark - 生成二维码/条形码

+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize)size;
+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize)size logo:(UIImage *)logo;

+ (UIImage *)generateCode128:(NSString *)code size:(CGSize)size;


@end

NS_ASSUME_NONNULL_END
