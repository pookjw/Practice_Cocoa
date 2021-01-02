//
//  GameOverView.m
//  Project8
//
//  Created by Jinwoo Kim on 1/3/21.
//

#import "GameOverView.h"

@implementation GameOverView

- (void)mouseUp:(NSEvent *)event {
    [super mouseUp:event];
    NSLog(@"GameOverView: mouseUp");
}

- (void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];
    NSLog(@"GameOverView: mouseDown");
}

- (void)startEmitting {
    self.wantsLayer = YES;
    
    NSTextField *title = [NSTextField labelWithString:@"Game Over"];
    title.font = [NSFont systemFontOfSize:96 weight:NSFontWeightHeavy];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.textColor = NSColor.whiteColor;
    title.wantsLayer = YES;
    [self addSubview:title];
    
    title.layer.shadowOffset = CGSizeZero;
    title.layer.shadowOpacity = 1;
    title.layer.shadowRadius = 3;
    
    [[title.centerXAnchor constraintEqualToAnchor:self.centerXAnchor] setActive:YES];
    [[title.centerYAnchor constraintEqualToAnchor:self.centerYAnchor] setActive:YES];
    
    self.layer.backgroundColor = [[NSColor colorWithRed:0 green:0 blue:0 alpha:0.5] CGColor];
    
    [self createEmitter];
}

- (CAEmitterCell *)createEmitterCellWithColor:(NSColor *)color {
    CAEmitterCell *cell = [CAEmitterCell new];
    
    cell.birthRate = 3;
    cell.lifetime = 7;
    cell.lifetimeRange = 0;
    cell.color = color.CGColor;
    cell.velocity = 200;
    cell.velocityRange = 50;
    cell.emissionRange = M_PI / 4;
    cell.spin = 2;
    cell.spinRange = 3;
    cell.scaleRange = 0.5;
    cell.scaleSpeed = -0.05;
    
    NSImage *image = [NSImage imageNamed:@"particle_confetti"];
    CGImageRef img = [image CGImageForProposedRect:nil context:nil hints:nil];
    
    if (img != nil) {
        cell.contents = (__bridge id)(img);
    }
    
    return cell;
}

- (void)createEmitter {
    CAEmitterLayer *particleEmitter = [CAEmitterLayer new];
    particleEmitter.emitterPosition = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame));
    particleEmitter.emitterShape = kCAEmitterLayerLine;
    particleEmitter.emitterSize = CGSizeMake(self.frame.size.width / 100, 1);
    particleEmitter.beginTime = CACurrentMediaTime();
    
    CAEmitterCell *red = [self createEmitterCellWithColor:[NSColor colorWithRed:1 green:0.2 blue:0.2 alpha:1]];
    CAEmitterCell *green = [self createEmitterCellWithColor:[NSColor colorWithRed:0.3 green:1 blue:0.3 alpha:1]];
    CAEmitterCell *blue = [self createEmitterCellWithColor:[NSColor colorWithRed:0.2 green:0.2 blue:1 alpha:1]];
    CAEmitterCell *yellow = [self createEmitterCellWithColor:[NSColor colorWithRed:1 green:1 blue:0.3 alpha:1]];
    CAEmitterCell *cyan = [self createEmitterCellWithColor:[NSColor colorWithRed:0.3 green:1 blue:1 alpha:1]];
    CAEmitterCell *magenta = [self createEmitterCellWithColor:[NSColor colorWithRed:1 green:0.3 blue:1 alpha:1]];
    CAEmitterCell *white = [self createEmitterCellWithColor:[NSColor colorWithRed:1 green:1 blue:1 alpha:1]];
    
    particleEmitter.emitterCells = @[red, green, blue, yellow, cyan, magenta, white];
    
    [self.layer addSublayer:particleEmitter];
}

- (void)viewDidChangeEffectiveAppearance {
    [super viewDidChangeEffectiveAppearance];
}

@end
