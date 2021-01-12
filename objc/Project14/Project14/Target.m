//
//  Target.m
//  Project14
//
//  Created by Jinwoo Kim on 1/12/21.
//

#import "Target.h"

@implementation Target

- (void)setup {
    NSInteger stickType = arc4random_uniform(3);
    NSInteger targetType = arc4random_uniform(4);
    
    self.stick = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"stick%ld", (long)stickType]];
    self.target = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"target%ld", (long)targetType]];
    
    self.target.name = @"target";
    self.target.position = CGPointMake(self.target.position.x, self.target.position.y + 116);
    
    [self addChild:self.stick];
    [self addChild:self.target];
}

- (void)hit {
    [self removeAllActions];
    self.target.name = nil;
    
    CGFloat animationTime = 0.2;
    [self.target runAction:[SKAction colorizeWithColor:NSColor.blackColor
                                      colorBlendFactor:1
                                              duration:animationTime]];
    [self.stick runAction:[SKAction colorizeWithColor:NSColor.blackColor
                                      colorBlendFactor:1
                                             duration:animationTime]];
    
    [self runAction:[SKAction fadeOutWithDuration:animationTime]];
    [self runAction:[SKAction moveByX:0 y:-30 duration:animationTime]];
    
//    [self runAction:[SKAction scaleXBy:0.8 y:0.7 duration:animationTime]];
    [self runAction:[SKAction sequence:@[
        [SKAction scaleXBy:0.7 y:0.8 duration:animationTime],
        [SKAction removeFromParent]
    ]]];
}

@end
