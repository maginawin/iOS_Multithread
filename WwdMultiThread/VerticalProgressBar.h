//
//  VerticalProgressBar.h
//  WwdMultiThread
//
//  Created by maginawin on 15-1-16.
//  Copyright (c) 2015年 mycj.wwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerticalProgressBar : UIView

// 初始化 backImage : 背景图, frontImage : 前景图, buttonImage : 前景小图标
//- (void)initWithBackImage:(UIImage*)backImage andFrontImage:(UIImage*)frontImage andButton:(UIImage*)buttonImage;

// 设置 vlaue (0.0 ~ 1.0)
- (void)setProgress:(float)value withName:(NSString*)name;


@end
