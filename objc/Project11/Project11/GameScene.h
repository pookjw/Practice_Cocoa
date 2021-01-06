//
//  GameScene.h
//  Project11
//
//  Created by Jinwoo Kim on 1/6/21.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene
@property NSArray<SKTexture *> *bubbleTextures;
@property NSUInteger currentBubbleTexture;
@property NSUInteger maximumNumber;
@property NSMutableArray<SKSpriteNode *> *bubbles;
@property NSTimer *bubbleTimer;
@end
