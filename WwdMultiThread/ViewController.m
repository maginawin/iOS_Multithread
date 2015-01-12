//
//  ViewController.m
//  WwdMultiThread
//
//  Created by maginawin on 15-1-12.
//  Copyright (c) 2015年 mycj.wwd. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController
// 定义两个队列
dispatch_queue_t serialQueue; // 串行队列
dispatch_queue_t concurrentQueue; // 并发队列

- (void)viewDidLoad {
    [super viewDidLoad];
    // 创建串行队列
    serialQueue = dispatch_queue_create("fkjava.queue", DISPATCH_QUEUE_SERIAL);
    // 创建并发队列
    concurrentQueue = dispatch_queue_create("fkjava.quque", DISPATCH_QUEUE_CONCURRENT);
}

- (IBAction)serial:(id)sender{
    // 依次将两个代码块提交给串行队列
    // 必须等到第 1 个代码块完成后, 才能执行第 2 个代码块
    dispatch_async(serialQueue, ^(void){
        for (int i = 0; i < 100; i++) {
            NSLog(@"%@========%d", [NSThread currentThread], i);
        }
    });
    dispatch_async(serialQueue, ^(void){
        for (int i = 0; i < 100; i++) {
            NSLog(@"%@========%d", [NSThread currentThread], i);
        }
    });
}

- (IBAction)concurrent:(id)sender{
    // 依次将两个代码提交给并发队列
    // 两段代码将可以并发执行
    dispatch_async(concurrentQueue, ^(void){
        for (int i = 0; i < 100; i++) {
                    NSLog(@"%@======%d", [NSThread currentThread], i);
        }
    });
    dispatch_async(concurrentQueue, ^(void){
        for (int i = 0; i < 100; i++) {
            NSLog(@"%@======%d", [NSThread currentThread], i);
        }
    });
}

- (IBAction)downloadImage:(id)sender {
    // 将代码块提交给系统的全局并发队列
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString* url = @"http://www.crazyit.org/logo.jpg";
        // 从网络获取数据
        NSData* data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
        // 将网络数据转换为 Image 对象
        UIImage* image = [[UIImage alloc] initWithData:data];
        if (image != nil) {
            // 将代码块提交给主线程相关联的队列, 该代码块将会由主线程完成
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = image;
            });
        }else{
            NSLog(@"---下载图片出错!");
        }
    });
}

- (IBAction)syncTask:(id)sender{
    // 以同步方式先后提交两个代码块
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        for (int i = 1; i < 100; i++) {
            NSLog(@"%@>>>>%d", [NSThread currentThread], i);
            [NSThread sleepForTimeInterval:0.1];
        }
    });
    // 必须等上面一段代码完全执行完, 才会来执行这一个代码块, 这就是同步线程
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        for (int i = 1; i < 100; i++) {
            NSLog(@"%@>>>>%d", [NSThread currentThread], i);
            [NSThread sleepForTimeInterval:0.1];
        }
    });
}

@end
