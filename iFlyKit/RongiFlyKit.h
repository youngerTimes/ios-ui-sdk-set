//
//  RongiFlyKit.h
//  RongiFlyKit
//
//  Created by Sin on 16/11/15.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for RongiFlyKit.
FOUNDATION_EXPORT double RongiFlyKitVersionNumber;

//! Project version string for RongiFlyKit.
FOUNDATION_EXPORT const unsigned char RongiFlyKitVersionString[];

#if __has_include(<RongiFlyKit/RCiFlyKit.h>)
// iFlyKit核心类
#import <RongiFlyKit/RCiFlyKit.h>
#else
#import "RCiFlyKit.h"
#endif
