//
//  SecondViewController.m
//  WwdMultiThread
//
//  Created by maginawin on 15-1-16.
//  Copyright (c) 2015年 mycj.wwd. All rights reserved.
//

#import "SecondViewController.h"
#import "VerticalProgressBar.h"

@interface SecondViewController ()
@property (weak, nonatomic) IBOutlet VerticalProgressBar *verticalProgressBar;

@end

@implementation SecondViewController
CGFloat progressValue;

- (void)viewDidLoad {
    [super viewDidLoad];

//    [_verticalProgressBar initWithBackImage:[UIImage imageNamed:@"progress2"] andFrontImage:nil andButton:nil];
}

- (void)viewWillAppear:(BOOL)animated {
//    [_verticalProgressBar setProgress:0.5 withName:[NSString stringWithFormat:@"%lf", progressValue]];
    progressValue = 0.0;
}

- (IBAction)addProgress:(id)sender {
    progressValue += 0.1;
    if (progressValue > 1.0) {
        progressValue = 1.0;
    }
    [_verticalProgressBar setProgress:progressValue withName:[NSString stringWithFormat:@"%.1f", progressValue]];
}

- (IBAction)minusProgress:(id)sender {
    progressValue -= 0.1;
    if (progressValue < 0) {
        progressValue = 0.0;
    }
    [_verticalProgressBar setProgress:progressValue withName:[NSString stringWithFormat:@"%.1f", progressValue]];
}

@end
