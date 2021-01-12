//
//  Target.h
//  Project14
//
//  Created by Jinwoo Kim on 1/12/21.
//

#import <SpriteKit/SpriteKit.h>

@interface Target : SKNode
@property SKSpriteNode *target;
@property SKSpriteNode *stick;

- (void)setup;
- (void)hit;
@end
