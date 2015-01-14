//
//  PasswordInputWindow.h
//  WwdMultiThread
//
//  Created by maginawin on 15-1-14.
//  Copyright (c) 2015年 mycj.wwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasswordInputWindow : UIWindow

+ (PasswordInputWindow*)sharedInstance;

- (void)show;

@end
