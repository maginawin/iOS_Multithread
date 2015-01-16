//
//  WwdNSOperation.m
//  WwdMultiThread
//
//  Created by maginawin on 15-1-13.
//  Copyright (c) 2015年 mycj.wwd. All rights reserved.
//

#import "WwdNSOperation.h"

@interface WwdNSOperation()

@end

@implementation WwdNSOperation

- (id)initWithUIImage:(UIImageView*)imageView fromURL:(NSURL*)url {
    self = [super init];
    if (self) {
        _url = url;
        _imageView = imageView;
    }
    return self;
    UIProgressView* a = nil;
}

// 重写 NSOperation 类主要重写 main 方法, NSOperationQueue 执行这个方法
- (void)main {
    NSData* data = [NSData dataWithContentsOfURL:_url];
    UIImage* image = [UIImage imageWithData:data];
    if (image) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            _imageView.image = image;
        });
    } else {
        NSLog(@"图片 3 加载错误");
    }
}

@end
