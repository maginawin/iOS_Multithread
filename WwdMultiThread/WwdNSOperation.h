//
//  WwdNSOperation.h
//  WwdMultiThread
//
//  Created by maginawin on 15-1-13.
//  Copyright (c) 2015年 mycj.wwd. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface WwdNSOperation : NSOperation
@property (strong, nonatomic) NSURL* url;
@property (strong, nonatomic) UIImageView* imageView;

- (id)initWithUIImage:(UIImageView*)imageView fromURL:(NSURL*)url;
@end
