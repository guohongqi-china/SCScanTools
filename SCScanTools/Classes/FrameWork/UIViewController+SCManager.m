//
//  UIViewController+SCManager.m
//  fasdfasd
//
//  Created by guohongqi on 2020/3/16.
//  Copyright © 2020 guohq. All rights reserved.
//

#import "UIViewController+SCManager.h"
#import <objc/runtime.h>

static const char SCManagerKey = '\2';
static const char SCPreviewKey = '\1';

@implementation UIViewController (SCManager)

#pragma mark --  getter setter

- (void)setScanManager:(SCScanManager *)scanManager{
    if (scanManager != self.scanManager) {
        
        // 存储新的
        objc_setAssociatedObject(self, &SCManagerKey,
                                 scanManager, OBJC_ASSOCIATION_RETAIN);
    }
}



- (SCScanManager *)scanManager{
    return objc_getAssociatedObject(self, &SCManagerKey);
}



@end
