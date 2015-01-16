//
//  VerticalProgressBar.m
//  WwdMultiThread
//
//  Created by maginawin on 15-1-16.
//  Copyright (c) 2015年 mycj.wwd. All rights reserved.
//

#import "VerticalProgressBar.h"
#import <math.h>

#define BAR_HEIGHT (_height - 12) // bar 的高度  button 的实际可见高度为 12
#define BAR_ZERO_POSITION (_height - 15) // button 为 0 时的位置, 即在最低端
#define BAR_MAX_POSITION -3 // button 为 1.0 时的位置, 即在最顶端

@interface VerticalProgressBar()

@property (strong, nonatomic) UIImage* backImage;
@property (strong, nonatomic) UIImage* frontImage;
@property (strong, nonatomic) UIImage* buttonImage;

@property (strong, nonatomic) CALayer* backLayer;
@property (strong, nonatomic) CALayer* frontLayer;
@property (strong, nonatomic) CALayer* buttonLayer;
@property (strong, nonatomic) CALayer* nameLayer;
@property (strong, nonatomic) UILabel* nameLabel;

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;

@end

@implementation VerticalProgressBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setImagesAndLayers];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setImagesAndLayers];
    }
    return self;
}

- (void)initWithBackImage:(UIImage*)backImage andFrontImage:(UIImage*)frontImage andButton:(UIImage*)buttonImage {
    _backImage = backImage;
    _frontImage = frontImage;
    _buttonImage = buttonImage;

    [self setNeedsDisplay];
}



- (void)setProgress:(float)value withName:(NSString*)name {
    if (value > 1.0 || value < 0.0) {
        return;
    }
    CGFloat interval = BAR_ZERO_POSITION - (BAR_HEIGHT * value);
    CGFloat durationFloat = (_buttonLayer.frame.origin.y - interval) / BAR_HEIGHT;
    if (durationFloat < 0) {
        durationFloat = -durationFloat;
    }
//    _buttonLayer.frame = CGRectMake(0, interval, _width, 18.0);
//    NSLog(@"x:%lf, y:%lf,%lf, %lf",BAR_ZERO_POSITION, BAR_HEIGHT, BAR_HEIGHT * value, interval);
    
    CGRect fromRect1 = _frontLayer.frame;
    CGRect toRect1 = CGRectMake(0, interval + 12, _width, BAR_HEIGHT * value + 3);
    CABasicAnimation* animation1 = [CABasicAnimation animationWithKeyPath:@"frame"];
    animation1.fromValue = [NSValue valueWithCGRect:fromRect1];
    animation1.toValue = [NSValue valueWithCGRect:toRect1];
    animation1.duration = durationFloat;
    _frontLayer.frame = toRect1;
    animation1.removedOnCompletion = YES;

    CGRect fromRect = _buttonLayer.frame;
    CGRect toRect = CGRectMake(0, interval, _width, 18.0);
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"frame"];
    animation.fromValue = [NSValue valueWithCGRect:fromRect];
    animation.toValue = [NSValue valueWithCGRect:toRect];
    animation.duration = durationFloat;
    _buttonLayer.frame = toRect;
    animation.removedOnCompletion = YES;
    
    [_frontLayer addAnimation:animation1 forKey:nil];
    [_buttonLayer addAnimation:animation forKey:nil];
    _nameLabel.text = name;
    NSLog(@"%@name",name);
}

- (void)drawRect:(CGRect)rect {
    
}

- (void)setImagesAndLayers {
    _x = self.bounds.origin.x;
    _y = self.bounds.origin.y;
    _width = self.bounds.size.width;
    _height = self.bounds.size.height;
    
    _backImage = [UIImage imageNamed:@"progress1"];
    _frontImage = [UIImage imageNamed:@"progress2"];
    // progress3 为 button 图片, 大小为 54 * 36 @2x
    _buttonImage = [UIImage imageNamed:@"progress3"];
    
    _backLayer = [CALayer layer];
    _frontLayer = [CALayer layer];
    // buttonLayer 因为 buttonImage 周围有透明的关系, frame 中 Y 轴的值: y - 3 到顶, y + height - 15 到底
    // height - 12 为整个 bar 的高度
    _buttonLayer = [CALayer layer];
    _nameLayer = [CALayer layer];
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.frame = CGRectMake(0, 0, 27.0, 18.0);
    
    _backLayer.frame = self.bounds;
    _backLayer.contents = (id)_backImage.CGImage;
    
    _frontLayer.frame = CGRectMake(0, BAR_HEIGHT, _width, 0);
    _frontLayer.contents = (id)_frontImage.CGImage;
    
    _buttonLayer.frame = CGRectMake(0, -3 + BAR_HEIGHT, self.bounds.size.width, 18.0);
    _buttonLayer.contents = (id)_buttonImage.CGImage;
    
//    _nameLayer.frame = CGRectMake(0, -3, self.bounds.size.width, 18.0);
    [_buttonLayer addSublayer:_nameLabel.layer];
    _nameLabel.font = [UIFont systemFontOfSize:12.0];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
//    _nameLabel.textColor = [UIColor colorWithRed:231.0/255 green:76.0/255 blue:60.0/255 alpha:1.0];
    _nameLabel.textColor = [UIColor greenColor];
    _nameLabel.text = @"0.0";
    
    self.layer.masksToBounds = YES;
    [self.layer addSublayer:_backLayer];
    [self.layer addSublayer:_frontLayer];
    [self.layer addSublayer:_buttonLayer];
}


@end
