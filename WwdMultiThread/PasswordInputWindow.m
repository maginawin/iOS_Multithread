//
//  PasswordInputWindow.m
//  WwdMultiThread
//
//  Created by maginawin on 15-1-14.
//  Copyright (c) 2015年 mycj.wwd. All rights reserved.
//

#import "PasswordInputWindow.h"

@implementation PasswordInputWindow {
    UITextField* mTextField;
}

+ (PasswordInputWindow*)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        sharedInstance = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    });
    return sharedInstance;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 200, 20)];
        label.text = @"请输入密码";
        [self addSubview:label];
        
        UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 80, 200, 20)];
        textField.backgroundColor = [UIColor whiteColor];
        textField.secureTextEntry = YES;
        [self addSubview:textField];
        
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(10, 110, 200, 44)];
        [button setBackgroundColor:[UIColor blueColor]];
        button.titleLabel.textColor = [UIColor blackColor];
        [button setTitle:@"确定" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(completeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        self.backgroundColor = [UIColor purpleColor];
        mTextField = textField;
    }
    return self;
}

// 如果 UIWindow 要处理键盘事件, 需要合理将其设置为 keyWindow, 可以通过 makeKeyWindow 和 resignKeyWindow 方法将创建的实例 UIWindow 设置成 keyWindow
//
- (void)show {
    self.windowLevel = 1000.000000;
    mTextField.text = @"";
    [self makeKeyWindow];
    self.hidden = NO;
}

- (void)completeButtonPressed:(id)sender {
    if ([mTextField.text isEqualToString:@"abcd"]) {
        [mTextField resignFirstResponder];
        [self resignKeyWindow];
        self.hidden = YES;
    } else {
        [self showErrorAlertView];
    }
}

- (void)showErrorAlertView {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"密码错误! 请输入正确密码..." delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

@end
