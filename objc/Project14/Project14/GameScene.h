//
//  GameScene.h
//  Project14
//
//  Created by Jinwoo Kim on 1/12/21.
//

#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>
#import "Target.h"

@interface GameScene : SKScene
@property SKSpriteNode *bulletsSprite;
@property NSArray<SKTexture *> *bulletsTextures;
@property (nonatomic) NSUInteger bulletsInClip;
@property SKLabelNode *scoreLabel;
@property (nonatomic) NSInteger score;
@property double targetSpeed;
@property double targetDelay;
@property NSUInteger targetsCreated;
@property BOOL isGameOver;
@end
