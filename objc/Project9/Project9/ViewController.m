//
//  ViewController.m
//  Project9
//
//  Created by Jinwoo Kim on 1/3/21.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self runBackgroundCode1];
//    [self runBackgroundCode2];
//    [self runBackgroundCode3];
//    [self runBackgroundCode4];
//    [self runSynchronousCode];
//    [self runDelayedCode];
//    [self runMultiprocessing1];
    [self runMultiprocessingWithUsingGCD:NO];
//    [self runMultiprocessingWithUsingGCD:YES];
}

- (void)log:(NSString *)message {
    NSLog(@"Printing message: %@", message);
}

- (void)runBackgroundCode1 {
    [self performSelector:@selector(log:) withObject:@"Hello world 1"];
    [self performSelectorInBackground:@selector(log:) withObject:@"Hello world 2"];
    [self performSelectorOnMainThread:@selector(log:) withObject:@"Hello world 3" waitUntilDone:NO];
}

- (void)runBackgroundCode2 {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf log:@"On background thread"];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf log:@"On main thread"];
        });
    });
}

- (void)runBackgroundCode3 {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:@"https://www.apple.com"];
        if (url == nil) return;
        NSError *error = nil;
        NSStringEncoding encoding = 0;
        NSString *str = [[NSString alloc] initWithContentsOfURL:url usedEncoding:&encoding error:&error];
        if (str == nil) return;
        NSLog(@"%@", str);
    });
}

// qos의 순위가 높을 수록 빠르게 처리한다
- (void)runBackgroundCode4 {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        [weakSelf log:@"This is high priority"];
    });
}

- (void)runSynchronousCode {
    __weak typeof(self) weakSelf = self;
    
    // asynchronous!
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf log:@"Background thread 1"];
    });
    
    NSLog(@"Main thread 1");
    
    // synchronous
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:3.0];
        [weakSelf log:@"Background thread 2"];
    });
    
    NSLog(@"Main thread 2");
}

- (void)runDelayedCode {
    __weak typeof(self) weakSelf = self;
    
    // 둘이 같다
    [self performSelector:@selector(log:) withObject:@"Hi, it's with some delay!" afterDelay:3];
    
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{ // async이다.
        [weakSelf log:@"Hello world 2"];
    });
    
    //
    
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf log:@"Hello world 3"];
    });
}

- (void)runMultiprocessing1 {
    for (NSUInteger i = 0; i < 10; ++i) {
        dispatch_async(dispatch_queue_create("concurrent", DISPATCH_QUEUE_CONCURRENT), ^{
            NSLog(@"%lu, %hhd", i, [NSThread isMainThread]);
        });
    }
}

- (void)runMultiprocessingWithUsingGCD:(BOOL)useGCD {
    NSMutableArray<NSNumber *> *array = [@[] mutableCopy];
    for (NSUInteger i = 0; i < 42; ++i) {
        [array addObject:[NSNumber numberWithInteger:i]];
    }
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    
    if (useGCD) {
//        for (NSUInteger i = 0; i < array.count; i++) {
//            dispatch_sync(dispatch_queue_create("gcd", DISPATCH_QUEUE_CONCURRENT_WITH_AUTORELEASE_POOL), ^{
//                array[i] = [NSNumber numberWithInteger:[self fibonacciOf:i]];
//            });
//        }
        // NO API FOR OBJECTIVE-C; maybe have to use dispatch group?
    } else {
        for (NSUInteger i = 0; i < 42; i++) {
            array[i] = [NSNumber numberWithInteger:[self fibonacciOf:i]];
        }
    }
    
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent() - start;
    NSLog(@"Took %f seconds", end);
}

- (NSUInteger)fibonacciOf:(NSUInteger)num {
    if (num < 2) {
        return num;
    } else {
        return [self fibonacciOf:num - 1] + [self fibonacciOf:num - 2];
    }
}

@end
