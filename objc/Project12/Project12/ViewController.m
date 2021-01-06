//
//  ViewController.m
//  Project12
//
//  Created by Jinwoo Kim on 1/7/21.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentAnimation = 0;
    
    self.imageView = [NSImageView imageViewWithImage:[NSImage imageNamed:@"penguin"]];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.frame = CGRectMake(272, 172, 256, 256);
    self.imageView.wantsLayer = YES;
    self.imageView.layer.backgroundColor = NSColor.redColor.CGColor;
    [self.view addSubview:self.imageView];
    
    NSButton *button = [NSButton buttonWithTitle:@"Click Me" target:self action:@selector(animate)];
    button.frame = CGRectMake(10, 10, 100, 30);
    [self.view addSubview:button];
}

- (void)animate {
    switch (self.currentAnimation) {
        case 0: {
            [self.imageView animator].alphaValue = 0;
            break;
        }
        case 1: {
            [self.imageView animator].alphaValue = 1;
            break;
        }
        case 2: {
            NSAnimationContext.currentContext.allowsImplicitAnimation = YES;
            self.imageView.alphaValue = 0;
            break;
        }
        case 3: {
            self.imageView.alphaValue = 1;
            break;
        }
        case 4: {
            [self.imageView animator].frameCenterRotation = 90;
            break;
        }
        case 5: {
            NSAnimationContext.currentContext.allowsImplicitAnimation = YES;
            self.imageView.frameCenterRotation = 0;
            break;
        }
        case 6: {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            animation.fromValue = [NSNumber numberWithFloat:1.0];
            animation.toValue = [NSNumber numberWithFloat:0.0];
            [self.imageView.layer addAnimation:animation forKey:nil];
            //            [animation setRemovedOnCompletion:NO];
            /*
             case 6의 경우 1에서 0으로 갔다가 애니메이션이 끝나면 다시 1이 된다. 이를 해결하기 위해 [animation setRemovedOnCompletion:NO]을 쓰지 말자.
             이걸 쓸 경우 직접 sublayer를 지우지 않는 한, 애니메이션이 절대 끝나지 않는다.
             */
            break;
        }
        case 7: {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            animation.fromValue = [NSNumber numberWithFloat:1.0];
            animation.toValue = [NSNumber numberWithFloat:0.0];
            self.imageView.layer.opacity = 0;
            [self.imageView.layer addAnimation:animation forKey:nil];
            break;
        }
        case 8: {
            [self.imageView animator].alphaValue = 1;
            break;
        }
        case 9: {
            self.imageView.layer.opacity = 1;
            break;
        }
        case 10: {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            animation.fromValue = @1;
            animation.toValue = @1.1;
            animation.autoreverses = YES;
            animation.repeatCount = 5;
            [self.imageView.layer addAnimation:animation forKey:nil];
            break;
        }
        case 11: {
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
            animation.values = @[@0, @200, @0];
            animation.keyTimes = @[@0, @0.2, @1];
            animation.duration = 2;
            [animation setAdditive:YES];
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [self.imageView.layer addAnimation:animation forKey:nil];
            break;
        }
        case 12: {
            __weak typeof(self) weakSelf = self;
            [NSAnimationContext
             runAnimationGroup:^(NSAnimationContext * _Nonnull context){
                context.duration = 1;
                [[weakSelf.imageView animator] setHidden:YES];
            }
             completionHandler:^{
                self.view.layer.backgroundColor = NSColor.redColor.CGColor;
            }];
            break;
        }
        case 13: {
            [self.imageView setHidden:NO];
            self.view.layer.backgroundColor = nil;
            break;
        }
        default: {
            self.currentAnimation = 0;
            [self animate];
            break;
        }
    }
    
    self.currentAnimation += 1;
}

@end
