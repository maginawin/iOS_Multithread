//
//  ViewController.m
//  WwdMultiThread
//
//  Created by maginawin on 15-1-12.
//  Copyright (c) 2015年 mycj.wwd. All rights reserved.
//

#import "ViewController.h"
#import "WwdNSOperation.h"
#import "PasswordInputWindow.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView* imageVIew2;
@property (weak, nonatomic) IBOutlet UIImageView* imageView3;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ViewController
// 定义两个队列
dispatch_queue_t serialQueue; // 串行队列
dispatch_queue_t concurrentQueue; // 并发队列
NSOperationQueue* operationQueue; // 执行并发队列

UIWindow* mUIWindow;

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化 scrollView
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 600.0);
    
    // 创建串行队列
    serialQueue = dispatch_queue_create("fkjava.queue", DISPATCH_QUEUE_SERIAL);
    // 创建并发队列
    concurrentQueue = dispatch_queue_create("fkjava.quque", DISPATCH_QUEUE_CONCURRENT);
    
    // 使用默认的通知中心监听应用程序转入后台的过程
    // 应用转入后台时会向通知中心发送 UIApplicationDidEnterBackgroundNotification
    // 从而激发 enterBack: 方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackForPasswordWindow:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    
    // 初始化 operationQueue
    operationQueue = [[NSOperationQueue alloc] init];
    // 设置最大并行的线程 10 个
    operationQueue.maxConcurrentOperationCount = 10;
    
    // 测试循环引用, 相互引用, 对象不会释放
    NSMutableArray* first = [NSMutableArray array];
    NSMutableArray* second = [NSMutableArray array];
    [first addObjectsFromArray:first];
    [second addObjectsFromArray:second];
}

#pragma mark - GCD & NSOperation

// 测试 Serial (串行)
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

// 测试 Concurrent (并发)
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

// 使用 GCD 下载图片
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

// 同步提交任务
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

// 多次提交的任务
- (IBAction)applyTash:(id)sender{
    // 控制代码块执行 5 次
    dispatch_apply(5, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   // time 形参代表当前正在执行第几次
                   ^(size_t time){
                       NSLog(@"==== 执行 [%lu] 次 ==== %@", time, [NSThread currentThread]);
    });
}

// 只执行一次的任务, 后面再次点击这个按钮, 将不会触发进程块
- (IBAction)onceTask:(id)sender{
    // dispatch_once() 函数执行时需要传入一个 dispatch_once_t 类型 (本质就是 long 型整数) 的指针, 即 predicate 参数, 该指针变量用于判断该代码块是否已经执行过
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@">>>> 执行代码 ");
        // 线程暂停 3 秒
        [NSThread sleepForTimeInterval:3.0];
    });
}

// 延迟 10 秒执行
- (IBAction)delayTask:(id)sender {
    double delayInSeconds = 10;
    NSDate* now = [NSDate date];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^ {
        NSInteger interval = -[now timeIntervalSinceNow];
        NSLog(@"%ld 秒后才会运行", (long)interval);
    });
}

// 让后台两个线程并行执行, 然后等两个线程都结束后, 再汇总执行结果, 用 dispatch_group, dispatch_group_async 和 dispatch_path_group_notify 来实现
- (IBAction)groupTask:(id)sender {
    // 默认情况下, block 访问变量是复制过去的, 修改变量的值是不能改变的
    // 但是若在前面加了 __block 关键字, 则修改等操作可以生效
    __block int a, b;
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        NSLog(@"并行执行的线程1");
        a = 100;
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        NSLog(@"并行执行的线程2");
        b = 200;
    });
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        // 汇总结果
        NSLog(@"结果是: %d", a + b);
    });
}

// 请求更多的后台时间
// 以applicaitonDidEnterBackground: 为平台, 告诉系统进入后台还有更多的任务需要完成, 从而向系统申请更多的后台时间
// 1. 调用 UIApplication 对象的 beginBackgroundTaskWithExpirationHandler: 方法请求获取更多的后台执行时间, 该方法默认请求 10 分钟后台时间. 该方法需要传入一个代码块作为参数, 如果请求获取后台执行时间失败, 将会执行该代码块. 该方法将会返回一个 UIBackgroundTaskIdentifier 类型的变量, 该变量可作为后台任务的标识符.
// 2. 调用 dispatch_aysnc() 的方法 (异步) 将指定代码块提交给后台执行.
// 3. 后台任务执行完成时, 执行 UIApplication 的 endBackgroundTask: 方法结束后台任务.

// 在 viewDidLoad 方法注册了通知中心监听应用转入后台, 此下为它的 selector 方法
- (void)enterBack:(NSNotification*)notification {
    UIApplication* app = [UIApplication sharedApplication];
    // 定义一个 UIBackgroundTaskIdentifier 类型 (本质就是 NSUInteger) 的变量
    // 该变量将作为后台任务的标识符
    __block UIBackgroundTaskIdentifier backTaskId;
    backTaskId = [app beginBackgroundTaskWithExpirationHandler:^ {
        NSLog(@"在额外申请的时间内依然没有完成任务");
        // 结束后台任务
        [app endBackgroundTask:backTaskId];
    }];
    if (backTaskId == UIBackgroundTaskInvalid) {
        NSLog(@"iOS版本过低, 后台任务启动失败!");
        return;
    }
    // 将代码块以异步方式提交给系统的全局并发队列
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        NSLog(@"额外申请的后台任务时间为: %f", app.backgroundTimeRemaining);
        // 其他内存清理的代码也可在此完成
        for (int i = 0; i < 100; i++) {
            NSLog(@"下载任务完成了%d%%", i);
            // 暂停 4 秒模拟正在执行后台下载
            [NSThread sleepForTimeInterval:0.1];
        }
        NSLog(@"剩余的后台任务时间为: %f", app.backgroundTimeRemaining);
        // 结束后台任务
        [app endBackgroundTask:backTaskId];
    });
}

- (void)enterBackForPasswordWindow:(NSNotification*)notification {
    UIApplication* app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier backTaskId;
    backTaskId = [app beginBackgroundTaskWithExpirationHandler:^ {
        [app endBackgroundTask:backTaskId];
    }];
    if (backTaskId == UIBackgroundTaskInvalid) {
        // failed
    }
        
}

// 使用 NSBlockOperation 作为 NSOperation 添加到 operationQueue
- (IBAction)blockOperation:(id)sender {
    NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^ {
        NSString* url = @"http://mymcuapp.com/images/mywatchapp.png";
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        UIImage* image = [UIImage imageWithData:data];
        if (image != nil) {
            // 更新 UI 应该由主线程完成
            dispatch_async(dispatch_get_main_queue(), ^ {
                _imageView.image = image;
            });
        } else {
            NSLog(@"下载图片出错");
        }
    }];
    [operationQueue addOperation:operation];
}

// 使用 NSInvocationOperation 作为 NSOperation 添加到 operationQueue
- (IBAction)invocationOperation:(id)sender {
    NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImageURL) object:nil];
    [operationQueue addOperation:operation];
}

- (void)downloadImageURL {
    NSString* url = @"http://mymcuapp.com/images/mywatchapp.png";
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    UIImage* image = [UIImage imageWithData:data];
    //在 UI 线程中更新 UI
    if (image != nil){
        [self performSelectorOnMainThread:@selector(updateImage2:) withObject:image waitUntilDone:YES];
    } else {
        NSLog(@"下载图片2出错");
    }
}

- (void)updateImage2:(UIImage*)image{
    self.imageVIew2.image = image;
}

// 使用自定义的 NSOperation (重写了 main 方法) 来实现给 imageView3 附图
- (IBAction)wwdOperation:(id)sender {
    WwdNSOperation* operation = [[WwdNSOperation alloc] initWithUIImage:_imageView3 fromURL:[NSURL URLWithString:@"http://mymcuapp.com/images/mywatchapp.png"]];
    [operationQueue addOperation:operation];
}

// 手工创建 UIView
// UIWindow 和创建 UIView 不同, 一旦被创建就自动被添加到整个界面上
// UIWindow WindowLevel {
// UIKIT_EXTERN const UIWindowLevel UIWindowLevelNormal (0.000000), UIWindowLevelAlert (1000.000000), UIWindowLevelStatusBar (2000.000000), 可以自定义
// }
- (IBAction)createUIWindow:(id)sender {
    mUIWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    mUIWindow.windowLevel = UIWindowLevelNormal;
    mUIWindow.backgroundColor = [UIColor redColor];
    mUIWindow.hidden = NO;
    
    // 添加点击手势
    UIGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] init];
    [gesture addTarget:self action:@selector(hideMyUIWindow:)];
    [mUIWindow addGestureRecognizer:gesture];
}

- (void)hideMyUIWindow:(UIGestureRecognizer*)gesture {
    mUIWindow.hidden = YES;
    mUIWindow = nil;
}

// PasswordInputWindow
// 在 AppDelegate 的 applicationDidEnterBackground: application 中使用


@end
